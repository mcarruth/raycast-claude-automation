#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Tone Check
# @raycast.mode silent
# @raycast.icon 🧊
# @raycast.packageName Claude Automation
# @raycast.alias tc
# @raycast.description Rewrite the selected text (or clipboard) to sound calm and professional

# Select text in any app and run this: the selection is replaced in place.
# With nothing selected, the clipboard is rewritten and copied back instead.

. "$(dirname "$0")/../lib/common.sh"

# Let Raycast's window close so the original app has focus again
sleep 0.3

app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
original_clipboard=$(pbpaste)

# Try to copy the current selection
selection=""
printf '' | pbcopy
if osascript -e 'tell application "System Events" to keystroke "c" using command down' >/dev/null 2>&1; then
    i=0
    while [ $i -lt 10 ]; do
        sleep 0.1
        selection=$(pbpaste)
        [ -n "$selection" ] && break
        i=$((i + 1))
    done
fi

if [ -n "$selection" ]; then
    mode=inplace
    input="$selection"
else
    mode=clipboard
    input="$original_clipboard"
    printf '%s' "$original_clipboard" | pbcopy
fi

if [ -z "$(printf '%s' "$input" | tr -d '[:space:]')" ]; then
    echo "Nothing to rewrite. Select some text or copy it first."
    exit 1
fi

context=""
[ -n "$app" ] && context="Destination app: $app"

errfile=$(mktemp -t tone-check)
if ! result=$(build_prompt "$input" "$context" tone-check | run_llm 2>"$errfile"); then
    printf '%s' "$original_clipboard" | pbcopy
    echo "Tone Check failed: $(cat "$errfile")"
    rm -f "$errfile"
    exit 1
fi
rm -f "$errfile"

printf '%s' "$result" | pbcopy

if [ "$mode" = inplace ]; then
    osascript -e 'tell application "System Events" to keystroke "v" using command down' >/dev/null 2>&1
    echo "Rewritten"
else
    echo "Calmer version copied to clipboard"
fi
