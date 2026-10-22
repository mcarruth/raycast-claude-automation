# Raycast Claude Automation

Raycast commands that make messages, emails, and docs read as calm and professional before you send them. Works with the Claude Code CLI or kiro-cli.

## Commands

| Alias | Command | What it does |
|-------|---------|--------------|
| `tc`  | Tone Check | Select text in any app and run it: the selection is replaced with a calmer version. With nothing selected, it rewrites the clipboard and copies the result back. Best bound to a hotkey. |
| `tcr` | Tone Review | Copy a draft first. Shows a 1 to 5 heat rating and what was softened, and copies the rewrite to the clipboard. |
| `tp`  | Perception Check | Copy a draft first, then pick who's reading it. Explains how you'll come across: what you meant vs what they'll hear, what's missing, and one habit to try. No rewrite and no grammar notes. |
| `wr`  | Writing Review | Copy a few sentences or a short poem first. Shows the strongest line, where it tells instead of shows, what to cut or sharpen, how the ending lands, and one exercise for tomorrow. Never rewrites. |
| `tpp` | My Patterns | Your most common Perception Check patterns this week, all time, and per reader. |

Tone Check keeps the substance and stays firm. It removes sarcasm, blame, absolutes, all caps, and passive-aggressive phrases, and adds a greeting or thanks where a message reads as cold. It adjusts for Slack, email, or docs based on the app you are in.

## Setup on a new machine

1. Install the Claude Code CLI or kiro-cli and sign in. Check that it works in a terminal.
2. Clone this repo and run `./setup.sh`. It picks `claude` if installed, otherwise `kiro-cli`. Force one with `./setup.sh claude` or `./setup.sh kiro`.
3. Raycast → Extensions → Script Commands → Add Script Directories → choose `scripts/`.
4. Give Tone Check a hotkey: Raycast → Extensions → search "Tone Check" → Record Hotkey.
5. System Settings → Privacy & Security → Accessibility → turn on Raycast. Without this, Tone Check falls back to clipboard only.

Re-run `./setup.sh` if you move or reinstall the CLI.

## Files

- `skills/tone-check.md`: the rewrite instructions. Edit this to tune the tone.
- `skills/tone-review.md`: the output format for Tone Review.
- `skills/writing-review.md`: Writing Review instructions. Paste the same text into a Claude Project to use it on your phone.
- `skills/perception-check.md`: Perception Check instructions and the list of pattern labels.
- `lib/common.sh`: loads the config and calls the right CLI.
- `data/patterns.log`: pattern labels logged by Perception Check (date, reader, label). Never the message text. Not committed, so each laptop keeps its own.
- `config.local`: per-machine settings written by `setup.sh` (backend, CLI path, optional `MODEL`, saved `PATH`). Not committed.

## Notes

- Raycast doesn't load your shell profile, so shell aliases don't work in these scripts. `setup.sh` records the real CLI path and your `PATH` instead.
- Set `MODEL` in `config.local` to use a faster model for quicker rewrites.
- Some editors (VS Code, for example) copy the whole line when nothing is selected. In those apps, select the text before running Tone Check.
