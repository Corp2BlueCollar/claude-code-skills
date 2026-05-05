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

A reference implementation lives at `scripts/check-receipts.sh` in this skill folder. It runs **two-tier verification**:

### Tier 1 — Form check
The hook scans the most recent assistant message transcript for claim words (*passes, complete, fixed, working, done, ready, shipped, succeeded, success, green*) and confirms an Evidence Template (CLAIM / COMMAND / OUTPUT / VERDICT) appears in the same message. Claim word without all four markers → block.

### Tier 2 — Truth check (re-run + verdict comparison)
This is the load-bearing one. After form check passes, the hook:

1. Extracts the COMMAND line from the receipt.
2. Rejects it as "non-rerunnable" if it contains shell metacharacters (`;`, `&`, `|`, `<`, `>`, `` ` ``, `$`) — too dangerous to re-execute on agent-authored text.
3. Checks the first word against a **safe-list** of read-only / idempotent commands: `pytest`, `ruff`, `mypy`, `flake8`, `tsc`, `eslint`, `prettier`, `isort`, `black`, `cargo`, `go`, `mvn`, `gradle`, `make`, `npm test`, `npm run`, `pnpm test`, `pnpm run`, `yarn test`, `bash test*.sh`, `git status|diff|log|show|branch|ls-files|rev-parse`, `ls`, `cat`, `head`, `tail`, `wc`, `grep`, `find`, `file`, `stat`.
4. If the COMMAND matches the safe-list, the hook **re-executes it in a fresh subshell with a 60-second timeout** (configurable via `RECEIPTS_RERUN_TIMEOUT`).
5. Compares the **real exit code** of the re-run against the claimed VERDICT:
   - `VERDICT: yes` requires real exit `0`.
   - `VERDICT: no` requires real exit `≠ 0`.
   - Any mismatch → block, with the real output and exit code printed back to the agent.
6. If the COMMAND is non-rerunnable (metachars or off the safe-list), the hook falls back to **form-only verification** with a stderr note. The agent's claim still passes form check; the truth wasn't independently verified.

### Why the safe-list, not "run anything"
The COMMAND line is agent-authored text. Re-executing arbitrary shell from agent output is a security regression — even with whitelisting, the discipline is "if you want truth-checking, write a re-runnable proof-of-work command that has no side effects." The safe-list covers the verification commands a serious developer is already running anyway.

### What the hook catches now
- **Claims without receipts** ("all tests pass" with no Evidence Template) → block (form check)
- **Fabricated receipts** (claimed VERDICT: yes but the real command exits non-zero) → block (truth check)
- **Wrong-direction VERDICT** (claimed VERDICT: no but the real command passes) → block (truth check)
- **Non-rerunnable claims** (deploy commands, `gh repo create`, etc.) → form-only, with a stderr note that the truth wasn't checked. Discipline reminder printed: write a re-runnable proof-of-work command instead of the action itself.

### Env knobs
- `RECEIPTS_RERUN=0` — disable Tier 2 entirely, fall back to form-only.
- `RECEIPTS_RERUN_TIMEOUT=120` — extend the re-run timeout (default 60s).

### Limitations (be honest about what this doesn't catch)
- **Side-effect commands** (deploy scripts, API calls, anything with `;`, `&&`, redirects) fall back to form-only. The discipline of writing a re-runnable proof-of-work command is the user's responsibility.
- **Non-determinism**: a flaky test that passes once and fails on re-run will show as a mismatch. Acceptable false-alarm — flakiness is itself a signal.
- **Trust in the test code itself**: if the agent wrote a fake test that always returns 0, the hook will dutifully re-run it and accept the VERDICT. Verifying that the test is meaningful is out of scope; pair this skill with peer review or `codex review --uncommitted` for that.

---

## Verify This Skill Works

A skill called *Receipts Or It Didn't Happen* should ship with receipts. The skill ships with a self-test that exercises the hook against 14 transcript scenarios — 5 covering the Tier 1 form check, 9 covering the Tier 2 re-run + verdict comparison:

```bash
bash scripts/test-check-receipts.sh
```

Expected output:

```
Test report:
  14/14 scenarios passed

  PASS  1. claim without receipts is blocked (exit 2)
  PASS  2. neutral exploration with no claim language is allowed
  PASS  3. stop_hook_active loop guard short-circuits to allow
  PASS  4. incomplete receipt missing VERDICT line is blocked
  PASS  5. transcript with no assistant message is allowed
  PASS  6. safe-list cmd that really passes + VERDICT yes → allow
  PASS  7. safe-list cmd that really fails + VERDICT yes → BLOCK (mismatch)
  PASS  8. safe-list cmd that fails + honest VERDICT no → allow
  PASS  9. safe-list cmd that passes + dishonest VERDICT no → BLOCK (mismatch)
  PASS  10. command with shell metacharacter falls back to form-only allow
  PASS  11. non-safe-list command (gh repo create) falls back to form-only allow
  PASS  12. RECEIPTS_RERUN=0 disables Tier 2 (form-only) — even with bogus VERDICT
  PASS  13. ls (read-only safe-list) on existing dir + VERDICT yes → allow
  PASS  14. git status (safe-list) with VERDICT yes in any git repo → allow

Result: all scenarios passed (Tier 1 form check + Tier 2 re-run + verdict comparison)
```

The script exits 0 on full pass, 1 on any regression. CI runs it on every PR (see `.github/workflows/test.yml` at the repo root). If you change the hook's claim words, safe-list, or receipt pattern, run the test, watch a scenario break, then update the test alongside the hook so they evolve together.

**Test scenarios covered:**

| # | Scenario | Tier | Expected |
|---|----------|------|----------|
| 1 | Claim word with no Evidence Template | 1 (form) | Block |
| 2 | Pure exploration / no claim language | 1 (form) | Allow |
| 3 | `stop_hook_active=true` loop guard | 1 (form) | Allow (recursion guard) |
| 4 | Receipt missing VERDICT line | 1 (form) | Block |
| 5 | Empty transcript / no assistant message | 1 (form) | Allow |
| 6 | Safe-list cmd really passes + VERDICT yes | 2 (truth) | Allow |
| 7 | Safe-list cmd really fails + VERDICT yes (fabrication) | 2 (truth) | **Block** |
| 8 | Safe-list cmd fails + honest VERDICT no | 2 (truth) | Allow |
| 9 | Safe-list cmd passes + dishonest VERDICT no | 2 (truth) | **Block** |
| 10 | Command with shell metachars (`pytest && rm`) | 2 (truth) | Form-only allow |
| 11 | Non-safe-list command (`gh repo create`) | 2 (truth) | Form-only allow |
| 12 | `RECEIPTS_RERUN=0` env disables Tier 2 | 2 (truth) | Form-only allow |
| 13 | `ls` (read-only safe-list) + VERDICT yes | 2 (truth) | Allow |
| 14 | `git status` (safe-list) + VERDICT yes | 2 (truth) | Allow |

The Tier 2 fabrication-catch cases (#7 and #9) are the headline behavior. Without them, this is just a form-checker. With them, the hook actually gates on whether the claimed VERDICT matches reality.

If you add a new claim word, safe-list entry, scenario, or receipt format, add a corresponding `run_case` line to `scripts/test-check-receipts.sh` so the regression is caught the next time someone forks and runs the suite.
