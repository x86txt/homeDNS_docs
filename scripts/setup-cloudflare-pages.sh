#!/usr/bin/env bash
# setup-cloudflare-pages.sh
#
# Creates the Cloudflare Pages project linked to x86txt/homeDNS_docs.
# Requires CLOUDFLARE_TOKEN to be exported in the current shell, e.g.:
#   export CLOUDFLARE_TOKEN="your_global_api_key"
#   bash scripts/setup-cloudflare-pages.sh
#
# Prerequisites:
#   - The Cloudflare Pages GitHub App must be installed on x86txt's GitHub account.
#     Install once at: https://github.com/apps/cloudflare-pages
#   - jq must be installed (brew install jq)
#   - CLOUDFLARE_TOKEN must be a Global API Key or have Pages:Edit + DNS:Edit scope.

set -euo pipefail

CF_API="https://api.cloudflare.com/client/v4"
GITHUB_OWNER="x86txt"
GITHUB_REPO="homeDNS_docs"
PAGES_PROJECT="homedns-docs"
PRODUCTION_BRANCH="main"
DOMAIN="docs.homedns.app"
BUILD_CMD="bun run build"
OUTPUT_DIR="dist"

# ── Validate token ──────────────────────────────────────────────────────────
if [[ -z "${CLOUDFLARE_TOKEN:-}" ]]; then
  echo "✗ CLOUDFLARE_TOKEN is not set. Export it first:" >&2
  echo "    export CLOUDFLARE_TOKEN=\"your_api_key\"" >&2
  exit 1
fi

AUTH_HEADER="Authorization: Bearer $CLOUDFLARE_TOKEN"

echo "▸ Verifying token …"
VERIFY=$(curl -sf -H "$AUTH_HEADER" "$CF_API/user/tokens/verify" 2>/dev/null || true)
if echo "$VERIFY" | grep -q '"status":"active"'; then
  echo "  ✓ Token is active"
else
  # Fall back to checking /user (Global API Keys report differently)
  USER_CHECK=$(curl -sf -H "$AUTH_HEADER" "$CF_API/user" 2>/dev/null || true)
  if echo "$USER_CHECK" | grep -q '"success":true'; then
    echo "  ✓ Global API Key accepted"
  else
    echo "✗ Token appears invalid. Check CLOUDFLARE_TOKEN." >&2
    exit 1
  fi
fi

# ── Resolve account ID ──────────────────────────────────────────────────────
echo "▸ Fetching Cloudflare account …"
ACCOUNTS=$(curl -sf -H "$AUTH_HEADER" "$CF_API/accounts")
ACCOUNT_ID=$(echo "$ACCOUNTS" | jq -r '.result[0].id')
ACCOUNT_NAME=$(echo "$ACCOUNTS" | jq -r '.result[0].name')

if [[ -z "$ACCOUNT_ID" || "$ACCOUNT_ID" == "null" ]]; then
  echo "✗ Could not resolve account ID. API response:" >&2
  echo "$ACCOUNTS" | jq . >&2
  exit 1
fi

echo "  ✓ Account: $ACCOUNT_NAME ($ACCOUNT_ID)"

# ── Create Pages project ─────────────────────────────────────────────────────
echo "▸ Creating Pages project '$PAGES_PROJECT' …"
CREATE_RESP=$(curl -sf -X POST \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  "$CF_API/accounts/$ACCOUNT_ID/pages/projects" \
  -d "{
    \"name\": \"$PAGES_PROJECT\",
    \"production_branch\": \"$PRODUCTION_BRANCH\",
    \"source\": {
      \"type\": \"github\",
      \"config\": {
        \"owner\": \"$GITHUB_OWNER\",
        \"repo_name\": \"$GITHUB_REPO\",
        \"production_branch\": \"$PRODUCTION_BRANCH\",
        \"pr_comments_enabled\": true,
        \"deployments_enabled\": true,
        \"preview_deployment_setting\": \"none\"
      }
    },
    \"build_config\": {
      \"build_command\": \"$BUILD_CMD\",
      \"destination_dir\": \"$OUTPUT_DIR\",
      \"root_dir\": \"\"
    }
  }")

if echo "$CREATE_RESP" | grep -q '"success":true'; then
  PAGES_URL=$(echo "$CREATE_RESP" | jq -r '.result.subdomain')
  echo "  ✓ Pages project created"
  echo "  ✓ Preview URL: https://$PAGES_URL"
else
  # Project may already exist — check
  if echo "$CREATE_RESP" | grep -qi "already exists"; then
    echo "  ℹ Project '$PAGES_PROJECT' already exists, skipping creation"
    PAGES_URL=$(curl -sf -H "$AUTH_HEADER" \
      "$CF_API/accounts/$ACCOUNT_ID/pages/projects/$PAGES_PROJECT" \
      | jq -r '.result.subdomain')
  else
    echo "✗ Pages project creation failed:" >&2
    echo "$CREATE_RESP" | jq . >&2
    exit 1
  fi
fi

# ── Find Zone for docs.homedns.app ──────────────────────────────────────────
echo "▸ Looking up zone for homedns.app …"
ZONES=$(curl -sf -H "$AUTH_HEADER" "$CF_API/zones?name=homedns.app")
ZONE_ID=$(echo "$ZONES" | jq -r '.result[0].id')

if [[ -z "$ZONE_ID" || "$ZONE_ID" == "null" ]]; then
  echo "  ⚠ Zone 'homedns.app' not found in this account."
  echo "    Add the CNAME manually in your DNS dashboard:"
  echo "    Name:    docs"
  echo "    Target:  $PAGES_URL"
  echo "    Proxied: yes"
else
  echo "  ✓ Zone ID: $ZONE_ID"

  # Check if CNAME already exists
  EXISTING=$(curl -sf -H "$AUTH_HEADER" \
    "$CF_API/zones/$ZONE_ID/dns_records?type=CNAME&name=$DOMAIN")
  EXISTING_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')

  if [[ -n "$EXISTING_ID" ]]; then
    echo "  ℹ CNAME already exists (id $EXISTING_ID), skipping"
  else
    echo "▸ Adding CNAME $DOMAIN → $PAGES_URL …"
    CNAME_RESP=$(curl -sf -X POST \
      -H "$AUTH_HEADER" \
      -H "Content-Type: application/json" \
      "$CF_API/zones/$ZONE_ID/dns_records" \
      -d "{
        \"type\": \"CNAME\",
        \"name\": \"docs\",
        \"content\": \"$PAGES_URL\",
        \"proxied\": true,
        \"ttl\": 1
      }")
    if echo "$CNAME_RESP" | grep -q '"success":true'; then
      echo "  ✓ CNAME created — $DOMAIN → $PAGES_URL"
    else
      echo "✗ CNAME creation failed:" >&2
      echo "$CNAME_RESP" | jq . >&2
      echo "  Add it manually in your DNS dashboard."
    fi
  fi
fi

# ── Custom domain on Pages ───────────────────────────────────────────────────
echo "▸ Attaching custom domain $DOMAIN to Pages project …"
CUSTOM_RESP=$(curl -sf -X POST \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  "$CF_API/accounts/$ACCOUNT_ID/pages/projects/$PAGES_PROJECT/domains" \
  -d "{\"name\": \"$DOMAIN\"}")

if echo "$CUSTOM_RESP" | grep -q '"success":true'; then
  echo "  ✓ Custom domain attached: https://$DOMAIN"
elif echo "$CUSTOM_RESP" | grep -qi "already"; then
  echo "  ℹ Custom domain already attached"
else
  echo "  ⚠ Custom domain attachment failed (may need manual step):"
  echo "$CUSTOM_RESP" | jq .
fi

echo ""
echo "┌─────────────────────────────────────────────────────────┐"
echo "│  Setup complete                                          │"
echo "│                                                          │"
echo "│  Pages project : $PAGES_PROJECT"
echo "│  Preview URL   : https://$PAGES_URL"
echo "│  Custom domain : https://$DOMAIN"
echo "│                                                          │"
echo "│  Push to main to trigger your first Cloudflare build.   │"
echo "└─────────────────────────────────────────────────────────┘"
