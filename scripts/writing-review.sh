#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Writing Review
# @raycast.mode fullOutput
# @raycast.icon ✍️
# @raycast.packageName Claude Automation
# @raycast.description Copy a piece of writing first. Shows what's working, where it tells instead of shows, and one thing to try next.

. "$(dirname "$0")/../lib/common.sh"

input=$(pbpaste)

if [ -z "$(printf '%s' "$input" | tr -d '[:space:]')" ]; then
    echo "Clipboard is empty. Copy your writing first."
    exit 1
fi

if ! response=$(build_prompt "$input" "" writing-review | run_llm); then
    exit 1
fi

echo "$response"
