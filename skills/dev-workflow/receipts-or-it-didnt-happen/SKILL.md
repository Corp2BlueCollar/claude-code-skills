---
name: receipts-or-it-didnt-happen
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires pasting an Evidence Template (CLAIM / COMMAND / OUTPUT / VERDICT) with fresh command output in the same message before any success claim. No receipts, no claim. Evidence before assertions always.
---

# Receipts Or It Didn't Happen

> Invoke as: `receipts-or-it-didnt-happen`

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Receipts or it didn't happen. Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH RECEIPTS IN THE SAME MESSAGE
```

If you haven't run the verification command in this message, you cannot claim it passes. No receipts, no claim.

## The Evidence Template

Every completion claim must take this form:

```
CLAIM:   [what you're claiming — "tests pass", "bug fixed", "build green"]
COMMAND: [exact command run, fresh, this message]
OUTPUT:  [paste actual stdout / exit code / failure count]
VERDICT: [does the output confirm the claim? yes / no]
```

Anything else is a guess. Paste the template, fill it in, then make the claim.

**Example — passing:**
```
CLAIM:   pytest suite passes after the auth fix
COMMAND: uv run pytest tests/auth/ -x
OUTPUT:  ============= 34 passed in 2.18s =============
VERDICT: yes
```

**Example — failing (still required, just honest):**
```
CLAIM:   pytest suite passes after the auth fix
COMMAND: uv run pytest tests/auth/ -x
OUTPUT:  FAILED tests/auth/test_token.py::test_refresh — AssertionError
VERDICT: no — refresh-token path still broken, fix incomplete
```

The template is also the receipt. Save it, paste it in PR descriptions, attach it to handoffs.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable. **Receipts or it didn't happen.**

---

## Hook Configuration (optional but recommended)

The skill is advisory by default. To make it *enforced* at the harness level, wire it to a Claude Code `Stop` hook that scans the assistant's final message for completion claims and rejects ones missing fresh receipts.

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/scripts/check-receipts.sh"
      }]
    }]
  }
}
```

A reference implementation lives at `scripts/check-receipts.sh` in this skill folder. It scans the most recent assistant message transcript for claim words (*passes, complete, fixed, working, done, ready, shipped*) and confirms an Evidence Template (CLAIM/COMMAND/OUTPUT/VERDICT) appears in the same message. If a claim word appears without a matching receipt, the hook exits non-zero and the harness re-prompts the agent to verify before stopping.

**What it catches:**
- "All tests pass" with no `pytest` / `npm test` / `cargo test` output above
- "Bug fixed" with no diff and no reproduction run
- "Build complete" with no exit-code line

**What it lets through:**
- Claims accompanied by an Evidence Template block
- Pure status updates without success language
- Questions, plans, exploratory turns

Customize the claim-word list and receipt regex inside the script for your stack.

---

## Verify This Skill Works

A skill called *Receipts Or It Didn't Happen* should ship with receipts. The skill ships with a self-test that exercises the hook against 7 transcript scenarios:

```bash
bash scripts/test-check-receipts.sh
```

Expected output:

```
Receipt:
CLAIM:   check-receipts.sh blocks unverified completion claims and allows everything else
COMMAND: bash scripts/test-check-receipts.sh
OUTPUT:  7/7 scenarios passed
  PASS  claim without receipts is blocked (exit 2)
  PASS  claim with full evidence template is allowed (exit 0)
  PASS  neutral exploration with no claim language is allowed
  PASS  stop_hook_active loop guard short-circuits to allow
  PASS  honest failing receipt (verdict=no) is allowed
  PASS  incomplete receipt missing VERDICT line is blocked
  PASS  transcript with no assistant message is allowed (no claim)
VERDICT: yes
```

The script exits 0 on full pass, 1 on any regression. CI runs it on every PR (see `.github/workflows/test.yml` at the repo root). If you change the hook's claim words or receipt pattern, run the test, watch a scenario break, then update the test alongside the hook so they evolve together.

**Test scenarios covered:**

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Assistant says "tests pass / bug fixed" with no Evidence Template | Block (exit 2) |
| 2 | Assistant claim + full CLAIM/COMMAND/OUTPUT/VERDICT block | Allow (exit 0) |
| 3 | Pure exploration / explanation, no claim language | Allow |
| 4 | `stop_hook_active=true` loop guard | Allow (always, to avoid recursion) |
| 5 | Honest failing receipt: `VERDICT: no — fix incomplete` | Allow (the receipt itself is the contract, not a "yes" verdict) |
| 6 | Receipt missing the `VERDICT:` line | Block (incomplete receipt = no receipt) |
| 7 | Empty transcript or no assistant message | Allow (nothing to gate) |

If you add a new claim word, scenario, or receipt format, add a corresponding `run_case` line to `scripts/test-check-receipts.sh` so the regression is caught the next time someone forks and runs the suite.
