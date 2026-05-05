#!/usr/bin/env bash
# check-receipts.sh — Claude Code Stop hook for the "Receipts Or It Didn't Happen" skill.
#
# Reads the hook payload from stdin, finds the most recent assistant message in the
# transcript, and rejects any completion claim that isn't accompanied by an Evidence
# Template (CLAIM / COMMAND / OUTPUT / VERDICT) block in the same message.
#
# Exit 0  → allow the agent to stop (no claim, or claim has receipts)
# Exit 2  → block the stop and feed stderr back to the agent so it must verify
#
# Requires: jq

set -euo pipefail

# Read the JSON payload Claude Code sends to the hook on stdin.
payload=$(cat)

# Locate the transcript file.
transcript=$(printf '%s' "$payload" | jq -r '.transcript_path // empty')
if [[ -z "$transcript" || ! -f "$transcript" ]]; then
  exit 0
fi

# Avoid infinite loops if the harness is already in a stop_hook_active state.
active=$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')
if [[ "$active" == "true" ]]; then
  exit 0
fi

# Pull the most recent assistant message text from the JSONL transcript.
# Each line is a transcript event; we want the last assistant message's text content.
# Pure awk for portability (macOS lacks `tac` by default).
last_line=$(awk '/"role"[[:space:]]*:[[:space:]]*"assistant"/ {last=$0} END{print last}' "$transcript")

if [[ -z "$last_line" ]]; then
  exit 0
fi

last_assistant=$(printf '%s' "$last_line" | jq -r '
  .message.content // .content // empty
  | if type=="array" then map(select(.type=="text") | .text) | join("\n") else . end
' 2>/dev/null || true)

if [[ -z "$last_assistant" ]]; then
  exit 0
fi

# Claim words that imply success/completion. Word-boundary, case-insensitive.
# Uses grep -iE for portable word boundaries (macOS bash 3.2's [[ =~ ]] lacks \b).
claim_re='\b(passes|passing|passed|all tests pass|complete|completed|fixed|working|done|ready|shipped|green|succeeded|success)\b'

has_claim() { printf '%s' "$1" | grep -qiE "$claim_re"; }

# A valid Evidence Template has all four markers in the same message:
# CLAIM:, COMMAND:, OUTPUT:, VERDICT:
has_receipt() {
  local text="$1"
  printf '%s' "$text" | grep -qE '^[[:space:]]*CLAIM:[[:space:]]+'   || return 1
  printf '%s' "$text" | grep -qE '^[[:space:]]*COMMAND:[[:space:]]+' || return 1
  printf '%s' "$text" | grep -qE '^[[:space:]]*OUTPUT:[[:space:]]+'  || return 1
  printf '%s' "$text" | grep -qiE '^[[:space:]]*VERDICT:[[:space:]]+(yes|no)\b' || return 1
  return 0
}

if has_claim "$last_assistant"; then
  if ! has_receipt "$last_assistant"; then
    cat >&2 <<'EOF'
RECEIPTS REQUIRED — completion claim detected without an Evidence Template.

The "Receipts Or It Didn't Happen" rule is in effect. Before you stop, paste an
Evidence Template in this message:

  CLAIM:   [what you're claiming]
  COMMAND: [exact command you ran, fresh, this turn]
  OUTPUT:  [paste actual stdout / exit code / failure count]
  VERDICT: [yes / no — does the output confirm the claim?]

If you haven't run the verification command in this message, run it now, paste the
output, then state the verdict. If the claim doesn't hold, retract it.

No receipts, no claim.
EOF
    exit 2
  fi
fi

exit 0
