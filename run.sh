#!/usr/bin/env bash
set -e

echo "🔹 Starting Newt inside Home Assistant OS..."

CONFIG_PATH="/data/options.json"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "❌ ERROR: Configuration file not found at $CONFIG_PATH!"
    exit 1
fi

PANGOLIN_ENDPOINT=$(jq -r '.PANGOLIN_ENDPOINT' "$CONFIG_PATH")
SITE_ID=$(jq -r '.NEWT_ID' "$CONFIG_PATH")
SITE_SECRET=$(jq -r '.NEWT_SECRET' "$CONFIG_PATH")

# Read custom environment variables
CUSTOM_ENV_VARS=$(jq -r '.custom_env_vars // [] | .[]' "$CONFIG_PATH")

if [[ -z "$PANGOLIN_ENDPOINT" || -z "$SITE_ID" || -z "$SITE_SECRET" || "$PANGOLIN_ENDPOINT" == "null" ]]; then
    echo "❌ ERROR: Missing required configuration values!"
    exit 1
fi

echo "✅ Configuration Loaded:"
echo "  PANGOLIN_ENDPOINT=$PANGOLIN_ENDPOINT"
echo "  SITE_ID=$SITE_ID"
echo "  SITE_SECRET=${SITE_SECRET:0:4}*****${SITE_SECRET: -4}"

# Process and display custom environment variables
EXTRA_ENV=""
if [[ -n "$CUSTOM_ENV_VARS" ]]; then
    echo "✅ Custom Environment Variables:"
    while IFS= read -r env_var; do
        if [[ -n "$env_var" ]]; then
            echo "  $env_var"
            # Export the variable for the newt process
            export "$env_var"
            # Also add to the command line (for explicit passing)
            var_name="${env_var%%=*}"
            EXTRA_ENV="$EXTRA_ENV $var_name=\"${!var_name}\""
        fi
    done <<< "$CUSTOM_ENV_VARS"
fi

# 🔁 Auto-reconnect loop
while true; do
    echo "🔹 Starting Pangolin-cli..."
    # Custom variables are already exported above
    export PANGOLIN_ENDPOINT="$PANGOLIN_ENDPOINT"
    export SITE_ID="$SITE_ID"
    export SITE_SECRET="$SITE_SECRET"
    /usr/bin/pangolin up site --interface newt --interface-main newt --attach

    echo "⚠️ Pangolin-cli stopped! Waiting 5 second before reconnecting..."
    sleep 5
done
