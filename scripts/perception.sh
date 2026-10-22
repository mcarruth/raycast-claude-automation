#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Perception Check
# @raycast.mode fullOutput
# @raycast.icon 🪞
# @raycast.packageName Claude Automation
# @raycast.alias tp
# @raycast.description Copy a draft first. Shows how the author will come across to the reader.
# @raycast.argument1 { "type": "dropdown", "placeholder": "Reader", "optional": true, "data": [{"title": "Unknown", "value": "unknown"}, {"title": "Direct report", "value": "direct report"}, {"title": "Peer", "value": "peer"}, {"title": "Senior leader", "value": "senior leader"}, {"title": "Another team", "value": "another team"}, {"title": "Group channel", "value": "group channel"}] }

. "$(dirname "$0")/../lib/common.sh"

reader="${1:-unknown}"
input=$(pbpaste)

if [ -z "$(printf '%s' "$input" | tr -d '[:space:]')" ]; then
    echo "Clipboard is empty. Copy your draft first."
    exit 1
fi

echo "WHO IS READING: $reader"
echo ""

if ! response=$(build_prompt "$input" "Reader: $reader" perception-check | run_llm); then
    exit 1
fi

# Show everything except the PATTERNS line
printf '%s\n' "$response" | grep -v '^PATTERNS:'

# Log known pattern labels (labels only, never the message text)
known=$(sed -n 's/^- `\([a-z-]*\)`:.*/\1/p' "$SKILLS_DIR/perception-check.md")
patterns=$(printf '%s\n' "$response" | sed -n 's/^PATTERNS:[[:space:]]*//p' | tr ',' '\n' | tr -d ' `' | grep -Fx "$known")

if [ -n "$patterns" ]; then
    mkdir -p "$DATA_DIR"
    today=$(date +%Y-%m-%d)
    printf '%s\n' "$patterns" | while read -r label; do
        printf '%s\t%s\t%s\n' "$today" "$reader" "$label" >> "$PATTERNS_LOG"
    done
    echo ""
    echo "Logged: $(printf '%s' "$patterns" | tr '\n' ',' | sed 's/,/, /g')"
fi
