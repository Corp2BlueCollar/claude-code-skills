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

Repo also includes a Stop-hook script.

If the agent tries to end a turn with claim language and no Evidence Template, the harness blocks the stop and re-prompts the agent to verify.

macOS bash 3.2 portable, smoke-tested against 7 transcript scenarios.

---

Bigger pattern: AI demos optimize for the moment of impressive output. AI operations need the agent honest when things break.

Open-sourcing one Claude Code skill per week from my library. This is week 1.

Repo: https://github.com/Corp2BlueCollar/claude-code-skills
