#!/bin/bash

# Raycast + Claude CLI Automation - Setup Script
# Usage: ./setup.sh [claude|kiro]
# With no argument, uses claude if installed, otherwise kiro-cli.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"
CONFIG_FILE="$REPO_DIR/config.local"

echo "Setting up Raycast Claude Automation..."

backend="$1"
if [ -z "$backend" ]; then
    if command -v claude >/dev/null 2>&1; then
        backend=claude
    elif command -v kiro-cli >/dev/null 2>&1; then
        backend=kiro
    else
        echo "Neither claude nor kiro-cli is installed (shell aliases don't count)."
        exit 1
    fi
fi

case "$backend" in
    claude) cli=$(command -v claude || true) ;;
    kiro)   cli=$(command -v kiro-cli || true) ;;
    *)      echo "Unknown backend '$backend'. Use claude or kiro."; exit 1 ;;
esac

if [ -z "$cli" ]; then
    echo "The $backend CLI is not on your PATH."
    exit 1
fi

# Keep any model override from a previous run
model=""
if [ -f "$CONFIG_FILE" ]; then
    model=$(sed -n 's/^MODEL="\(.*\)"$/\1/p' "$CONFIG_FILE")
fi

cat > "$CONFIG_FILE" <<CONFIG
# Machine-specific settings, written by setup.sh. Not committed.
BACKEND="$backend"
CLI="$cli"
# Optional model override, e.g. a fast model for quicker rewrites. Empty uses the CLI default.
MODEL="$model"
# Raycast doesn't load your shell profile, so scripts reuse this PATH
SAVED_PATH="$PATH"
CONFIG

chmod +x "$SCRIPTS_DIR"/*.sh

echo ""
echo "Backend: $backend ($cli)"
echo "Config:  $CONFIG_FILE"
echo ""
echo "Next steps:"
echo "1. Raycast → Extensions → Script Commands → Add Script Directories → $SCRIPTS_DIR"
echo "2. Give Tone Check a hotkey: Raycast → Extensions → find \"Tone Check\" → Record Hotkey"
echo "3. Allow Raycast under System Settings → Privacy & Security → Accessibility"
echo "   (needed to replace selected text; without it Tone Check uses the clipboard)"
echo ""
