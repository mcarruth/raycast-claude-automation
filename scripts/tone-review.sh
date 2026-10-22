#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Tone Review
# @raycast.mode fullOutput
# @raycast.icon 🌡️
# @raycast.packageName Claude Automation
# @raycast.alias tcr
# @raycast.description Rate how heated the copied text is, show what changed, and copy a calmer version

# Copy your draft first, then run this.

. "$(dirname "$0")/../lib/common.sh"

input=$(pbpaste)

if [ -z "$(printf '%s' "$input" | tr -d '[:space:]')" ]; then
    echo "Clipboard is empty. Copy your draft first."
    exit 1
fi

if ! response=$(build_prompt "$input" "" tone-check tone-review | run_llm); then
    exit 1
fi

if ! printf '%s\n' "$response" | grep -q '^===REWRITE===$'; then
    echo "$response"
    echo ""
    echo "(Unexpected format, clipboard left unchanged.)"
    exit 1
fi

notes=$(printf '%s\n' "$response" | awk '/^===REWRITE===$/ {exit} {print}')
rewrite=$(printf '%s\n' "$response" | awk 'found {print} /^===REWRITE===$/ {found=1}')

printf '%s' "$rewrite" | pbcopy

echo "$notes"
echo ""
echo "REWRITE (copied to clipboard):"
echo ""
echo "$rewrite"
