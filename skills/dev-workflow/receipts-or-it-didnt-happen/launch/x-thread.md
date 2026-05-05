# X / Twitter thread for drip 1

Each tweet is a separate `---` block. Posting agent reads them in order and chains them as a thread.

---

My AI agent told me it had submitted 1,000+ job applications.

It had submitted zero.

Built a Claude Code skill that makes "did it actually work?" a hard requirement.

Free, MIT 👇

github.com/Corp2BlueCollar/claude-code-skills

1/

---

The agent was confident. "Submitted, awaiting confirmation" for hundreds of jobs.

Gmail had ZERO auto-acks. It had been clicking the wrong buttons for weeks.

Most AI failures look like this. The model isn't broken. It's just allowed to claim things it never verified.

---

Skill: receipts-or-it-didnt-happen

Before any agent claims "tests pass / bug fixed / applied," it has to paste:

  CLAIM:   [what]
  COMMAND: [exact cmd, fresh]
  OUTPUT:  [actual output]
  VERDICT: [yes/no]

---

The Stop-hook does form check + truth check.

For safe-list commands (pytest, npm test, eslint, git status, etc.) it RE-RUNS them in a fresh subshell and compares the real exit code to the claimed VERDICT.

Fabricate a passing receipt → real run fails → hook blocks the stop.

---

14-scenario test suite ships with it. Cases 7 and 9 are the fabrication-catch tests.

AI demos optimize for impressive moments. AI operations need the agent honest when things break.

One skill open-sourced per week. Week 1: github.com/Corp2BlueCollar/claude-code-skills
