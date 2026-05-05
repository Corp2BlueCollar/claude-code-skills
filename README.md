# Claude Code Skills Portfolio

Reusable Claude Code skills for marketing, SEO, development workflow, agent operations, content, and business operations.

## TL;DR

This repo packages the reusable part of my Claude Code skill library into a public portfolio. The source library has 60+ skills. This public v1 includes 55 skills that were safe to share after excluding private operating playbooks, local machine paths, credentials, and business-specific instructions.

These skills are meant to show a practical approach to AI implementation:

- Turn repeated work into durable operating procedures.
- Give agents enough context to produce useful work without constant supervision.
- Keep execution tied to business outcomes, not demos.
- Build review and verification into the workflow before claiming done.

## Why This Exists

Most AI transformation fails because the work stops at prompts, demos, or one-off automations. The hard part is operationalization: deciding what the agent should know, when it should act, what it must verify, and where a human gate still belongs.

I built this library while using Claude Code across real business and product workflows. The goal was not to make a clever prompt collection. The goal was to make repeatable work easier to delegate: launch planning, SEO audits, paid ads setup, conversion review, debugging, web app testing, code review intake, and customer-facing implementation tasks.

That is the same pattern I bring to AI implementation roles. I can sit between customers, product, engineering, and operations, then turn messy workflows into systems people can actually use.

## Skill Index

See [CATEGORIES.md](CATEGORIES.md) for every included skill.

### Marketing

Skills for offers, copy, analytics, lifecycle email, paid ads, pricing, launch strategy, conversion rate optimization, and referral systems.

### SEO

Skills for technical SEO, programmatic SEO, page optimization, schema, sitemaps, image SEO, hreflang, GEO, and content planning.

### Development Workflow

Skills for test-driven development, systematic debugging, code review, worktrees, verification, web app testing, plan execution, and subagent coordination.

### Agent Operations

Skills for app connection patterns, project management, and reusable research workflows.

### Content

Skills for brainstorming, human editing, investor pitches, and Remotion video best practices.

### Business Operations

Skills for GoHighLevel, A2P registration, voice agents, and cold outreach research.

## Install

Copy any skill folder into your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills
cp -R skills/marketing/copywriting ~/.claude/skills/
```

Then invoke the skill by name in Claude Code when the task matches its description.

Example:

```text
Use the copywriting skill to rewrite this landing page for clearer conversion.
```

You can also install a whole category:

```bash
cp -R skills/seo/* ~/.claude/skills/
```

## How To Use This Library

1. Start with the outcome you want, not the model.
2. Pick the skill closest to the workflow.
3. Read the skill before running a high-stakes task.
4. Keep human approval gates for external actions like sending emails, posting publicly, deploying, or spending money.
5. After a workflow works three times, turn the real process into a new skill.

## About Brandon

I am Brandon Calloway, an AI implementation and operations leader focused on helping companies turn AI capability into repeatable customer and business outcomes.

My background combines enterprise delivery, hands-on AI building, and operating real service businesses:

- 5+ years enterprise experience across complex stakeholder environments.
- Multi-business operator through Dude Ventures Services LLC, founded October 2024.
- Built and systematized field-service workflows across ChristmasLightsDude and PoolCleaningDude.
- Improved PoolCleaningDude call capture from about 40% to 100% using AI-assisted phone and operations workflows.
- Grew ChristmasLightsDude to $65k in its first season, including a $39k MRR month 1 on $4k ad spend.
- Grew PoolCleaningDude to $16k MRR month 1 on $2k ad spend.
- Built this Claude Code skills library to make AI-assisted work more reliable, reviewable, and useful outside of toy demos.

I am most interested in senior customer-facing AI roles at Series A through Series D startups:

- Customer Success Manager or Customer Success Engineer
- Customer Outcomes Manager
- AI Engagement Manager
- Implementation Manager
- AI Deployment Strategist
- Technical Account Manager
- Forward Deployed Engineer
- Professional Services

Contact: [brandontcalloway@gmail.com](mailto:brandontcalloway@gmail.com)

LinkedIn: [https://www.linkedin.com/in/brandontcalloway](https://www.linkedin.com/in/brandontcalloway)

## License

MIT
