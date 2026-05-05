#!/usr/bin/env bash
# check-receipts.sh — Claude Code Stop hook for "Receipts Or It Didn't Happen".
#
# Two-tier verification:
#   1. Form check: every completion claim must be paired with an Evidence
#      Template (CLAIM / COMMAND / OUTPUT / VERDICT) in the same message.
#   2. Truth check: when COMMAND matches a re-runnable safe-list and contains
#      no shell metacharacters, the hook re-executes it in a fresh subshell
#      with a timeout and compares the real exit code to the claimed VERDICT.
#      Mismatch → block. Non-rerunnable commands fall back to form-only with
#      a note printed to stderr (still allows the stop).
#
# Exit 0  → allow the agent to stop
# Exit 2  → block; stderr is fed back to the agent
#
# Env knobs:
#   RECEIPTS_RERUN=0           disable Tier 2 re-run, form-only mode
#   RECEIPTS_RERUN_TIMEOUT=60  seconds for the re-run subshell timeout
#
# Requires: jq, timeout (gtimeout on macOS via coreutils), bash 3.2+

set -uo pipefail

# ---------------------------------------------------------------------------
# 0. Read hook payload + transcript
# ---------------------------------------------------------------------------

payload=$(cat)

transcript=$(printf '%s' "$payload" | jq -r '.transcript_path // empty')
if [[ -z "$transcript" || ! -f "$transcript" ]]; then
  exit 0
fi

active=$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')
if [[ "$active" == "true" ]]; then
  exit 0
fi

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

# ---------------------------------------------------------------------------
# 1. Form check — Tier 1
# ---------------------------------------------------------------------------

claim_re='\b(passes|passing|passed|all tests pass|complete|completed|fixed|working|done|ready|shipped|green|succeeded|success)\b'

has_claim() { printf '%s' "$1" | grep -qiE "$claim_re"; }

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
else
  # No claim language → nothing to gate. Allow.
  exit 0
fi

# ---------------------------------------------------------------------------
# 2. Truth check — Tier 2 (re-run + verdict comparison)
# ---------------------------------------------------------------------------

# Tier 2 is opt-out via env var.
if [[ "${RECEIPTS_RERUN:-1}" == "0" ]]; then
  exit 0
fi

# Extract the COMMAND and VERDICT from the receipt.
command_line=$(printf '%s' "$last_assistant" \
  | grep -E '^[[:space:]]*COMMAND:[[:space:]]+' | head -1 \
  | sed -E 's/^[[:space:]]*COMMAND:[[:space:]]+//')

verdict_line=$(printf '%s' "$last_assistant" \
  | grep -iE '^[[:space:]]*VERDICT:[[:space:]]+' | head -1 \
  | sed -E 's/^[[:space:]]*[Vv][Ee][Rr][Dd][Ii][Cc][Tt]:[[:space:]]+//')

# Normalize the verdict to "yes" or "no" (the form check already validated this).
verdict_word=$(printf '%s' "$verdict_line" | awk '{print tolower($1)}')

# Strip trailing whitespace from command.
command_line=$(printf '%s' "$command_line" | sed -E 's/[[:space:]]+$//')

# ---------------------------------------------------------------------------
# Safety gate 1: reject any command with shell metacharacters.
# These are the characters that allow chaining, redirection, substitution,
# backgrounding — anything that lets a single COMMAND turn into multiple.
# A command without any of these is just a single executable + args, which
# we can re-run safely (modulo whatever side effects the executable has).
# Note: $ alone catches both $VAR and $(...) command substitution.
# ---------------------------------------------------------------------------
metachar_re='[;&|<>`$]'
if printf '%s' "$command_line" | grep -qE "$metachar_re"; then
  cat >&2 <<EOF
RECEIPTS — Tier 2 re-run skipped (command contains shell metacharacters).
Form-only verification accepted. Command was:
  $command_line
EOF
  exit 0
fi

# ---------------------------------------------------------------------------
# Safety gate 2: command must match a re-runnable safe-list.
# The first whitespace-delimited token is the executable; we vet that, plus
# a small set of two-word forms (npm test, pnpm run, cargo test, etc.).
# ---------------------------------------------------------------------------
read -r first_word second_word _rest <<<"$command_line"

is_safe_command() {
  case "$first_word" in
    pytest|ruff|mypy|flake8|tsc|eslint|prettier|isort|black) return 0 ;;
    cargo|go|mvn|gradle|./gradlew|make) return 0 ;;
    git)
      case "$second_word" in
        status|diff|log|show|branch|ls-files|rev-parse) return 0 ;;
      esac
      return 1
      ;;
    npm|pnpm|yarn)
      case "$second_word" in
        test|run) return 0 ;;
      esac
      return 1
      ;;
    bash|sh)
      # Allow `bash <path>/test*.sh` or `bash test*.sh` only.
      if [[ "$second_word" == test*.sh ]] || [[ "$second_word" == */test*.sh ]]; then
        return 0
      fi
      return 1
      ;;
    ls|cat|head|tail|wc|grep|find|file|stat) return 0 ;;
    *) return 1 ;;
  esac
}

if ! is_safe_command; then
  cat >&2 <<EOF
RECEIPTS — Tier 2 re-run skipped (command not on safe-list: $first_word${second_word:+ $second_word}).
Form-only verification accepted. Discipline reminder: when possible, write a
re-runnable proof-of-work COMMAND (a test, lint, status check, or file probe)
rather than the action itself. The skill verifies what it can re-run.
EOF
  exit 0
fi

# ---------------------------------------------------------------------------
# 3. Re-execute and compare exit code to claimed VERDICT.
# ---------------------------------------------------------------------------

# Pick the right timeout binary (Linux: timeout, macOS: gtimeout via coreutils, fallback: none).
timeout_secs="${RECEIPTS_RERUN_TIMEOUT:-60}"
timeout_bin=""
if command -v timeout >/dev/null 2>&1; then
  timeout_bin="timeout"
elif command -v gtimeout >/dev/null 2>&1; then
  timeout_bin="gtimeout"
fi

# Run in a fresh subshell. The metachar gate above guarantees this is a single
# executable + args, so `bash -c` is safe here.
if [[ -n "$timeout_bin" ]]; then
  real_output=$("$timeout_bin" "$timeout_secs" bash -c "$command_line" 2>&1)
  real_exit=$?
else
  real_output=$(bash -c "$command_line" 2>&1)
  real_exit=$?
fi

# Treat timeout (124 from coreutils) as a verification failure.
if [[ "$real_exit" == "124" ]]; then
  cat >&2 <<EOF
RECEIPTS — Tier 2 re-run TIMED OUT after ${timeout_secs}s.
Command: $command_line
The verification command must complete within the timeout. If your test is
genuinely long-running, set RECEIPTS_RERUN_TIMEOUT=<seconds> in your env.
EOF
  exit 2
fi

# Compare exit code to the claimed VERDICT.
if [[ "$verdict_word" == "yes" ]]; then
  if [[ "$real_exit" != "0" ]]; then
    cat >&2 <<EOF
RECEIPTS — VERDICT MISMATCH.
You claimed VERDICT: yes, but re-running the COMMAND in a fresh subshell
produced exit code $real_exit (non-zero = failure).

  Command:      $command_line
  Real exit:    $real_exit
  Claimed:      yes (success)

Real output (truncated):
$(printf '%s' "$real_output" | head -40)

Either the original run did not actually pass, the receipt was fabricated, or
the command is non-deterministic. Re-run honestly, paste real output, set
VERDICT accordingly. If the command is non-rerunnable (has side effects),
write a different proof-of-work command for the COMMAND line.
EOF
    exit 2
  fi
else
  # verdict_word == "no" — claim is "this failed". Real run should also fail.
  if [[ "$real_exit" == "0" ]]; then
    cat >&2 <<EOF
RECEIPTS — VERDICT MISMATCH.
You claimed VERDICT: no (failure), but re-running the COMMAND succeeded
(exit 0). The claim and the reality disagree.

  Command:      $command_line
  Real exit:    0 (pass)
  Claimed:      no (failure)

Update the receipt to match reality.
EOF
    exit 2
  fi
fi

# Verdict matches reality. Allow the stop.
exit 0
