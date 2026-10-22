#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title My Patterns
# @raycast.mode fullOutput
# @raycast.icon 📈
# @raycast.packageName Claude Automation
# @raycast.alias tpp
# @raycast.description Your most common Perception Check patterns

. "$(dirname "$0")/../lib/common.sh"

if [ ! -s "$PATTERNS_LOG" ]; then
    echo "No patterns logged yet. Run Perception Check (tp) on a few drafts first."
    exit 0
fi

week_ago=$(date -v-7d +%Y-%m-%d)

summarize() {
    awk -F'\t' -v since="$1" '$1 >= since && $3 != "none" {print $3}' "$PATTERNS_LOG" \
        | sort | uniq -c | sort -rn | head -5 \
        | awk '{printf "  %3d  %s\n", $1, $2}'
}

echo "LAST 7 DAYS"
week=$(summarize "$week_ago")
echo "${week:-  Nothing flagged}"
echo ""
echo "ALL TIME"
summarize "0000-00-00"
echo ""
echo "BY READER (all time, top pattern for each)"
awk -F'\t' '$3 != "none" {count[$2 "\t" $3]++} END {for (k in count) print count[k] "\t" k}' "$PATTERNS_LOG" \
    | sort -t "$(printf '\t')" -k1,1rn \
    | awk -F'\t' '!seen[$2]++ {printf "  %-15s %s (%d)\n", $2, $3, $1}'
echo ""
echo "Pattern definitions: skills/perception-check.md"
