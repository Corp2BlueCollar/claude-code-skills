#!/usr/bin/env bash
# test-check-receipts.sh — verifies that check-receipts.sh blocks completion
# claims without an Evidence Template and allows everything else.
#
# This is the skill eating its own dogfood: the verification skill ships with
# verification of its own hook. Run it any time you change the hook logic.
#
# Usage:
#   bash scripts/test-check-receipts.sh
#
# Exit 0 = all scenarios passed. Exit 1 = at least one regression.

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

passes=0
fails=0
results=()

run_case() {
  local label="$1" body="$2" active="$3" expect="$4"
  printf '%s\n' "$body" > "$TRANS"
  local payload output ec
  payload=$(printf '{"transcript_path":"%s","stop_hook_active":%s}' "$TRANS" "$active")
  set +e
  output=$(printf '%s' "$payload" | bash "$HOOK" 2>&1)
  ec=$?
  set -e
  if [[ "$ec" == "$expect" ]]; then
    results+=("PASS  $label  (got=$ec)")
    passes=$((passes + 1))
  else
    results+=("FAIL  $label  (expected=$expect got=$ec)")
    if [[ -n "$output" ]]; then
      results+=("      output: $(printf '%s' "$output" | head -1)")
    fi
    fails=$((fails + 1))
  fi
}

# ---- Scenarios ----

run_case "claim without receipts is blocked (exit 2)" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"All tests pass and the bug is fixed."}]}}' \
false 2

run_case "claim with full evidence template is allowed (exit 0)" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done.\n\nCLAIM:   pytest passes after auth fix\nCOMMAND: uv run pytest tests/auth/\nOUTPUT:  ============= 34 passed in 2.18s =============\nVERDICT: yes"}]}}' \
false 0

run_case "neutral exploration with no claim language is allowed" \
'{"role":"user","content":"explore"}
{"role":"assistant","message":{"content":[{"type":"text","text":"The auth module uses JWT with a 15-minute TTL."}]}}' \
false 0

run_case "stop_hook_active loop guard short-circuits to allow" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Done."}]}}' \
true 0

run_case "honest failing receipt (verdict=no) is allowed" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"CLAIM:   tests pass\nCOMMAND: pytest\nOUTPUT:  FAILED test_x\nVERDICT: no"}]}}' \
false 0

run_case "incomplete receipt missing VERDICT line is blocked" \
'{"role":"user","content":"fix"}
{"role":"assistant","message":{"content":[{"type":"text","text":"Fixed it.\n\nCLAIM: pytest passes\nCOMMAND: pytest\nOUTPUT: 34 passed"}]}}' \
false 2

run_case "transcript with no assistant message is allowed (no claim)" \
'{"role":"user","content":"hello"}' \
false 0

# ---- Report ----

echo
echo "Receipt:"
echo "CLAIM:   check-receipts.sh blocks unverified completion claims and allows everything else"
echo "COMMAND: bash scripts/test-check-receipts.sh"
total=$((passes + fails))
echo "OUTPUT:  $passes/$total scenarios passed"
for line in "${results[@]}"; do
  echo "  $line"
done
if [[ "$fails" -eq 0 ]]; then
  echo "VERDICT: yes"
  exit 0
else
  echo "VERDICT: no ($fails regression(s))"
  exit 1
fi
