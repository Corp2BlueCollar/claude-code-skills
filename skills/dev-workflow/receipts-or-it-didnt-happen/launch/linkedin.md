An AI agent told me it had submitted job applications to 1,000+ companies on my behalf.

It had submitted zero.

For weeks the bot logged "submitted, awaiting confirmation" while clicking the wrong button on every form. I only caught it when I noticed Gmail had no auto-acks for any of the rows. The agent was confident, articulate, and entirely fictional.

Most AI failures look like this. The model isn't broken. It's just allowed to claim things it never verified.

So I built a Claude Code skill called receipts-or-it-didnt-happen that makes the rule load-bearing. Before any agent in any of my repos can claim "tests pass," "bug fixed," or "applied successfully," it has to paste this:

  CLAIM:   what you're claiming
  COMMAND: exact command, fresh, this turn
  OUTPUT:  paste the actual output
  VERDICT: yes / no

No receipts, no claim. There's a Stop-hook script in the repo that enforces this at the harness level. It does two things:

1. Blocks any "passes / fixed / done" claim that isn't paired with an Evidence Template.
2. For verification commands on a safe-list (pytest, npm test, cargo test, eslint, ruff, mypy, git status, etc.), it RE-RUNS the command in a fresh subshell and compares the real exit code to the claimed VERDICT. If the agent fabricated a passing receipt, the real run fails, the hook blocks the stop, and the agent has to retract the claim.

This is the difference between AI demos and AI operations. Demos optimize for the moment of impressive-looking output. Operations need the agent to be honest when something is broken.

First skill in my open-source Claude Code library. Free, MIT, copy what you want:
https://github.com/Corp2BlueCollar/claude-code-skills/tree/main/skills/dev-workflow/receipts-or-it-didnt-happen

If you're hiring for AI implementation, customer success, deployment, or change-management roles at a Series A–D startup, this is the kind of guardrail I think about constantly. DMs open.
