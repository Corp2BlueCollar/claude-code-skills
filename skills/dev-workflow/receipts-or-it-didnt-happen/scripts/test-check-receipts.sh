#!/usr/bin/env bash
# test-check-receipts.sh — exercises check-receipts.sh against form-check (Tier 1)
# and command re-run (Tier 2) scenarios.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/check-receipts.sh"

if [[ ! -x "$HOOK" ]]; then
  echo "ERROR: $HOOK not executable or missing" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required (brew install jq)" >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
TRANS="$TMPDIR/transcript.jsonl"

# Helper test scripts the safe-list will recognize as "bash test*.sh".
PASS_SH="$TMPDIR/test-pass.sh"
FAIL_SH="$TMPDIR/test-fail.sh"
printf '#!/usr/bin/env bash\necho "all good"\nexit 0\n' > "$PASS_SH"
printf '#!/usr/bin/env bash\necho "boom"\nexit 1\n' > "$FAIL_SH"
chmod +x "$PASS_SH" "$FAIL_SH"

passes=0
fails=0
results=()

run_case() {
  local label="$1" body="$2" active="$3" expect="$4" env_overrides="${5:-}"
  printf '%s\n' "$body" > "$TRANS"
  local payload output ec
  payload=$(printf '{"transcript_path":"%s","stop_hook_active":%s}' "$TRANS" "$active")
  set +e
  if [[ -n "$env_overrides" ]]; then
    output=$(printf '%s' "$payload" | env $env_overrides bash "$HOOK" 2>&1)
  else
    output=$(printf '%s' "$payload" | bash "$HOOK" 2>&1)
  fi
  ec=$?
  set -e
  if [[ "$ec" == "$expect" ]]; then
    results+=("PASS  $label  (got=$ec)")
    passes=$((passes + 1))
  else
    results+=("FAIL  $label  (expected=$expect got=$ec)")
    if [[ -n "$output" ]]; then
      results+=("      output: $(printf '%s' "$output" | head -3 | tr '\n' ' ')")
    fi
    fails=$((fails + 1))
  fi
}

# ---------------------------------------------------------------------------
# Tier 1 (form check) scenarios — preserved from the original test suite.
# ---------------------------------------------------------------------------

run_case "1. claim without receipts is blocked (exit 2)" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"All tests pass and the bug is fixed."}]}}' \
false 2

run_case "2. neutral exploration with no claim language is allowed" \
'{"role":"user","content":"explore"}
{"role":"assistant","message":{"content":[{"type":"text","text":"The auth module uses JWT with a 15-minute TTL."}]}}' \
false 0

run_case "3. stop_hook_active loop guard short-circuits to allow" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done."}]}}' \
true 0

run_case "4. incomplete receipt missing VERDICT line is blocked" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Fixed it.\n\nCLAIM: pytest passes\nCOMMAND: pytest\nOUTPUT: 34 passed"}]}}' \
false 2

run_case "5. transcript with no assistant message is allowed" \
'{"role":"user","content":"hello"}' \
false 0

# ---------------------------------------------------------------------------
# Tier 2 (re-run) scenarios — the hook actually re-executes the COMMAND.
# ---------------------------------------------------------------------------

run_case "6. safe-list cmd that really passes + VERDICT yes → allow" \
"{\"role\":\"user\",\"content\":\"fix\"}
{\"role\":\"assistant\",\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"Done.\\n\\nCLAIM:   passes\\nCOMMAND: bash $PASS_SH\\nOUTPUT:  all good\\nVERDICT: yes\"}]}}" \
false 0

run_case "7. safe-list cmd that really fails + VERDICT yes → BLOCK (mismatch)" \
"{\"role\":\"user\",\"content\":\"fix\"}
{\"role\":\"assistant\",\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"Done.\\n\\nCLAIM:   passes\\nCOMMAND: bash $FAIL_SH\\nOUTPUT:  fake all-good output\\nVERDICT: yes\"}]}}" \
false 2

run_case "8. safe-list cmd that fails + honest VERDICT no → allow" \
"{\"role\":\"user\",\"content\":\"fix\"}
{\"role\":\"assistant\",\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"Reporting failure honestly.\\n\\nCLAIM:   tests fail\\nCOMMAND: bash $FAIL_SH\\nOUTPUT:  boom\\nVERDICT: no\"}]}}" \
false 0

run_case "9. safe-list cmd that passes + dishonest VERDICT no → BLOCK (mismatch)" \
"{\"role\":\"user\",\"content\":\"fix\"}
{\"role\":\"assistant\",\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"Done.\\n\\nCLAIM:   tests fail\\nCOMMAND: bash $PASS_SH\\nOUTPUT:  fake fail\\nVERDICT: no\"}]}}" \
false 2

run_case "10. command with shell metacharacter falls back to form-only allow" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done.\n\nCLAIM:   passes\nCOMMAND: pytest && rm -rf /tmp/foo\nOUTPUT:  ok\nVERDICT: yes"}]}}' \
false 0

run_case "11. non-safe-list command (gh repo create) falls back to form-only allow" \
'{"role":"user","content":"ship"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done.\n\nCLAIM:   repo created\nCOMMAND: gh repo create foo/bar --public\nOUTPUT:  https://github.com/foo/bar\nVERDICT: yes"}]}}' \
false 0

run_case "12. RECEIPTS_RERUN=0 disables Tier 2 (form-only) — even with bogus VERDICT" \
"{\"role\":\"user\",\"content\":\"fix\"}
{\"role\":\"assistant\",\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"Done.\\n\\nCLAIM:   passes\\nCOMMAND: bash $FAIL_SH\\nOUTPUT:  fake\\nVERDICT: yes\"}]}}" \
false 0 \
"RECEIPTS_RERUN=0"

run_case "13. ls (read-only safe-list) on existing dir + VERDICT yes → allow" \
'{"role":"user","content":"check"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done.\n\nCLAIM:   tmp dir is readable\nCOMMAND: ls /tmp\nOUTPUT:  ...\nVERDICT: yes"}]}}' \
false 0

run_case "14. git status (safe-list) with VERDICT yes in any git repo → allow" \
'{"role":"user","content":"check"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done.\n\nCLAIM:   git status works\nCOMMAND: git status\nOUTPUT:  ...\nVERDICT: yes"}]}}' \
false 0

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

echo
echo "Test report:"
total=$((passes + fails))
echo "  $passes/$total scenarios passed"
echo
for line in "${results[@]}"; do
  echo "  $line"
done
echo
if [[ "$fails" -eq 0 ]]; then
  echo "Result: all scenarios passed (Tier 1 form check + Tier 2 re-run + verdict comparison)"
  exit 0
else
  echo "Result: $fails regression(s) detected"
  exit 1
fi
