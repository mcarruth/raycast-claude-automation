#!/bin/bash
# Shared helpers for the Raycast scripts. macOS bash 3.2 compatible.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
CONFIG_FILE="$REPO_DIR/config.local"
DATA_DIR="$REPO_DIR/data"
PATTERNS_LOG="${PATTERNS_LOG:-$DATA_DIR/patterns.log}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Not set up yet. Run ./setup.sh in $REPO_DIR"
    exit 1
fi

# Sets BACKEND, CLI, MODEL, and SAVED_PATH
. "$CONFIG_FILE"

# Raycast does not load your shell profile, so restore the PATH captured by setup.sh
if [ -n "$SAVED_PATH" ]; then
    export PATH="$SAVED_PATH"
fi

read_skill() {
    local file="$SKILLS_DIR/$1.md"
    if [ ! -f "$file" ]; then
        echo "Missing prompt file: $file" >&2
        return 1
    fi
    cat "$file"
}

strip_ansi() {
    sed $'s/\x1b\\[[0-9;?]*[a-zA-Z]//g' | tr -d '\r'
}

# Reads the full prompt on stdin, prints the model's reply on stdout.
# On failure prints a short reason on stderr and returns non-zero.
run_llm() {
    local prompt output status errors errfile
    prompt=$(cat)
    errfile=$(mktemp -t tone-err)

    case "$BACKEND" in
        claude)
            # Text in, text out: load no tools and no MCP servers
            set -- -p --tools "" --strict-mcp-config
            [ -n "$MODEL" ] && set -- "$@" --model "$MODEL"
            output=$(printf '%s' "$prompt" | "$CLI" "$@" 2>"$errfile")
            status=$?
            ;;
        kiro)
            # Flags unverified against kiro-cli; adjust if replies look off.
            if [ -n "$MODEL" ]; then
                output=$("$CLI" chat --no-interactive --model "$MODEL" "$prompt" 2>"$errfile")
            else
                output=$("$CLI" chat --no-interactive "$prompt" 2>"$errfile")
            fi
            status=$?
            # Drop color codes and the leading "> " reply marker
            output=$(printf '%s\n' "$output" | strip_ansi | sed '1s/^> //')
            ;;
        *)
            rm -f "$errfile"
            echo "Unknown BACKEND '$BACKEND' in $CONFIG_FILE" >&2
            return 1
            ;;
    esac

    errors=$(strip_ansi < "$errfile")
    rm -f "$errfile"

    if [ $status -ne 0 ]; then
        # Look for an expired-credentials error only when the call failed,
        # since a successful rewrite can legitimately contain those words
        case $(printf '%s\n%s' "$errors" "$output" | tr '[:upper:]' '[:lower:]') in
            *expiredtoken*|*credentials*expired*|*"token has expired"*|*"token is expired"*|*"security token included in the request is invalid"*)
                echo "AWS credentials expired. Refresh them and try again." >&2
                return 1
                ;;
        esac
    fi

    if [ $status -ne 0 ]; then
        echo "$BACKEND failed: $(printf '%s\n%s' "$errors" "$output" | grep -v '^[[:space:]]*$' | tail -1)" >&2
        return 1
    fi

    if [ -z "$(printf '%s' "$output" | tr -d '[:space:]')" ]; then
        echo "$BACKEND returned an empty response" >&2
        return 1
    fi

    printf '%s\n' "$output"
}

# Builds the prompt from one or more skills, an optional context line, and the user's text
# Usage: build_prompt "<text>" "<context line or empty>" skill [skill...]
build_prompt() {
    local text="$1" context="$2"
    shift 2
    local skill
    for skill in "$@"; do
        read_skill "$skill" || return 1
        printf '\n\n---\n\n'
    done
    if [ -n "$context" ]; then
        printf '%s\n\n' "$context"
    fi
    printf 'Draft:\n\n%s\n' "$text"
}
