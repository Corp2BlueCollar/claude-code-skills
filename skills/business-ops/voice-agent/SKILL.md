---
name: voice-agent
description: Use when configuring, tuning, or troubleshooting GoHighLevel Voice AI agents. Also use when the user mentions "voice agent," "voice AI," "AI receptionist," "phone AI," "call agent," "appointment booking voice," "agent sounds robotic," "voice prompt," "call transfer," "outbound calling," or wants to make a voice agent sound more natural.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Agent
user-invocable: true
---

# GHL Voice Agent Tuning Skill

You are an expert in GoHighLevel Voice AI agent configuration and optimization. Your goal is to make voice agents sound natural, book appointments reliably, and convert callers into customers.

## Quick Reference

| Setting | Value |
|---------|-------|
| Navigate to | AI Agents > Voice AI |
| Voice catalog | 340+ voices, 26 languages |
| Custom voices | ElevenLabs import (up to 10, agency-level) |
| Pricing | $0.06/min (voice engine) + LLM tokens + telephony |
| Idle timer | 1-20s (default 8s), auto-hangup after 15s silence |
| Outbound limits | 1 call/min/location, 100/day, 4/contact/14 days |
| Call window | 10 AM - 6 PM contact local time |
| Backchanneling | Built-in ("uh-huh", "yeah", "okay") |

## Creating an Agent

1. AI Agents > Voice AI > + Create Agent
2. Set: Agent Name, Business Name, Voice, Direction (Inbound/Outbound)
3. Write Initial Greeting
4. Choose Goals mode: Basic (checkbox fields) or Advanced (full prompt control)
5. Assign phone number (use dedicated number, NOT default account number)
6. Set Working Hours and after-hours fallback
7. Attach Knowledge Base with trigger prompts
8. Configure Post-Call Actions (workflow triggers, email notifications)
9. Test via Web Call or Phone Call

## Prompt Engineering - The Core of Natural Voice

### The Three Prompt Elements
1. **Role**: Who the agent is (persona, business context)
2. **Task**: What to accomplish (qualify, book, transfer, answer)
3. **Guidelines**: Guardrails (what NOT to do, escalation rules)

### Golden Rules

**Be explicit, not abstract.** "Be conversational" does nothing. Show exactly what you mean:
```
BAD:  "Be friendly and conversational"
GOOD: "Use contractions. Say 'awesome' instead of 'excellent'.
       Occasionally say 'ya know' or 'gotcha'. Start some sentences
       with 'So' or 'And'."
```

**Provide side-by-side examples:**
```
ROBOTIC: "I can definitely handle that for you."
NATURAL: "Yeah, I can totally do that, no problem."

ROBOTIC: "Could you please provide me with your email address?"
NATURAL: "What's a good email for you?"
```

**Keep responses SHORT.** Target ~20 words, max 3 sentences. Voice responses should be 60-70% shorter than text.

**One question at a time.** Never stack questions. Ask, wait for answer, then ask next.

**Repeat critical instructions.** LLMs need far more repetition than expected. State important rules 2-3 times in different sections of the prompt.

**Use delimiters.** Separate prompt sections with `###`, `"""`, or XML tags for clarity.

### Natural Speech Techniques

| Technique | Example |
|-----------|---------|
| Filler words | "um", "uh", "well", "actually", "so" |
| Contractions | "I'll", "we're", "that's", "don't" |
| Casual confirmation | "gotcha", "awesome", "perfect", "sure thing" |
| Soft starts | "So,", "And,", "Well,", "Honestly," |
| Conversational bridges | "ya know", "here's the thing", "the good news is" |
| Natural pauses | Use commas and ellipses for breathing rhythm |

### Disfluency Patterns (Advanced)
Engineer realistic speech hesitations:
```
"Yeah, um... so, I can do that, no problem"
"Let me... actually, let me check on that real quick"
"That's a great- well, it's actually a pretty common question"
```
Rule: Follow standalone "um" with a brief pause, then resume with "so" or a connector.

### Number/Date/Email Formatting
- Phone: "five five five, one two three, four five six seven"
- Dates: "January Twenty Fourth" (no years)
- Time: "Four Thirty PM"
- Email: "username at domain dot com" - always confirm by spelling back

## Appointment Booking Configuration

### Setup
Advanced Mode > Set Up Your Actions > New Action > Book Appointment

### Parameters
| Parameter | Recommended |
|-----------|------------|
| Offering Days | 2-3 days forward |
| Slots Per Day | 3-5 |
| Hours Between Slots | 1-2 hours |
| Calendar | Primary booking calendar |

### Booking Flow Best Practice
1. Identify need: "Sounds like you need a [service]. Let me find you a time."
2. Offer specific slots: "I have tomorrow at 2 PM or Thursday at 10 AM - which works better?" (68% higher booking rate than open-ended "when works for you?")
3. Collect required info: name, email, phone (one at a time)
4. Confirm: "Perfect, you're all set for Thursday at 10 AM. You'll get a confirmation text."
5. Post-booking workflow fires automatically

### Current Limitations
- Rescheduling/cancellations require manual intervention or workflow workaround
- Multi-calendar not yet supported in Voice AI (available in Conversation AI)
- Voice AI does not natively show calendar widget - verbal slot offering only

## Call Transfer to Human

Configure in Advanced Mode. Set conditions for transfer:
- High-intent signals ("I want to sign up today")
- Complexity beyond AI capability
- Caller requests human
- Emergency/urgent situations

Keyword triggers initiate handoff. Full call history syncs to Conversations tab.

## Silence & Idle Handling

| Event | Behavior |
|-------|----------|
| Caller silent for [idle timer] seconds | Agent sends re-engagement prompt |
| 15s silence after reminder | Call auto-terminates |
| Background noise | Enable Noise Cancellation |

### Silence Escalation Protocol
- 3s: "Are you still there?"
- 6s: "I'm here whenever you're ready"
- 10s: "Sounds like we may have gotten disconnected. I'll follow up with a text."

## Outbound Calling

### Prerequisites
- KYC verification complete
- Outbound calling enabled (24-48hr approval)
- Verified caller ID
- Contacts with documented opt-in
- Pre-configured Voice AI agent

### Workflow Setup
1. Create workflow with trigger (Form Submit, Tag Added, Pipeline Stage Change)
2. Add "Voice AI Outbound Call" action
3. Configure: Agent, From Phone Number, Action Name
4. Test with QA tag on internal numbers
5. Review transcripts before going live

### TCPA Compliance (Critical)
- Prior express written consent required
- Business identification at call start
- Easy opt-out mechanism
- DNC list compliance
- $500-$1,500 per violation, no cap

## Testing Protocol

### During Development
1. **Web Call**: Browser-based, no phone needed, no transfer testing
2. **Phone Call**: Full feature testing including transfers

### Review Checklist
After each test call, check:
- [ ] Greeting sounds natural, identifies business
- [ ] Collects required info without stacking questions
- [ ] Handles "I don't know" and off-topic gracefully
- [ ] Books appointment with correct details
- [ ] Confirms booking clearly
- [ ] Transfers to human when appropriate
- [ ] Handles silence/noise appropriately
- [ ] Post-call workflows fire correctly

### Iteration Loop
Test → Review transcript → Adjust prompt → Re-test → Use Prompt Evaluator → Repeat

## Contractor/Home Service Prompts

### Qualification Data to Collect
- Service type (repair, replacement, installation, maintenance)
- Urgency (emergency vs routine)
- Property type (residential/commercial)
- Location/address
- Preferred scheduling window
- Budget awareness (optional, tread carefully)

### Example: HVAC Company Prompt
```
You are Jessica, a friendly virtual receptionist for [Business Name],
an HVAC company serving [Area]. You answer calls, qualify leads, and
book service appointments.

YOUR PERSONALITY:
- Warm but efficient. You sound like a real person, not a robot.
- Use contractions: "I'll", "we're", "that's"
- Say "gotcha" and "awesome" instead of "understood" and "excellent"
- Keep responses to 1-2 sentences max

YOUR TASK:
1. Greet: "Hey, thanks for calling [Business Name]! How can I help?"
2. Identify service: Ask what they need help with
3. Assess urgency: If emergency (no heat, no AC, gas smell), say
   "Let me get someone on the line right away" and transfer
4. For routine: Collect name, address, brief issue description
5. Book appointment: Offer 2-3 specific time slots
6. Confirm and close: Repeat appointment details, say they'll get
   a confirmation text

RULES:
- NEVER diagnose problems or quote prices
- NEVER say "I'm an AI" unless directly asked
- If asked something you don't know, say "Great question - let me
  have one of our techs get back to you on that"
- One question at a time. Always.
- If caller is upset, acknowledge first: "I totally get that,
  that sounds frustrating. Let's get this taken care of."
```

## Cost Optimization

| Strategy | Impact |
|----------|--------|
| Use GPT-4.1 Mini or GPT-5 Mini | 5-10x cheaper than full models |
| Keep prompts under 500 tokens | Less token spend per call |
| Limit context to last 3-5 turns | Reduces per-turn cost |
| Filter calls < 30s in workflows | Eliminates spam/hangup processing |
| Enable prompt caching | ~40% latency reduction |
| Skip AI Employee $97/mo plan | Pay-per-use is cheaper until ~1,500+ AI messages/mo |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Agent talks over caller | Enable Backchanneling at medium frequency |
| Sounds robotic | Add explicit speech examples to prompt (see Natural Speech above) |
| Misunderstands callers | Enable Noise Cancellation, simplify prompt, add FAQ entries |
| Loses context mid-call | Limit to 3-5 turn history, ensure knowledge base triggers are specific |
| Doesn't book appointment | Verify calendar is assigned, check "Book Appointment" action config |
| Caller reaches voicemail instead of AI | Reduce Inbound Call Timeout to prevent local voicemail pickup |
| Outbound calls not initiating | Check: opt-in documented, no DND, within call window, KYC complete |
| Post-call workflow doesn't fire | Verify Transcript Generated trigger filters match call type |

## Advanced Features

- **Custom Actions**: Mid-call API calls (POST only) for real-time data lookup
- **Backchanneling**: Built-in "uh-huh", "yeah" during micro-pauses
- **Noise Cancellation**: Remove ambient noise, or noise + background speech
- **Sentiment Analysis**: Real-time tracking on outbound dashboard
- **Translation**: Auto-translate transcripts/summaries to target language
- **Voice AI Chat Widget**: Browser-based voice on your website
- **Agent Studio**: Drag-and-drop multi-step AI workflow builder (separate from basic Voice AI)

## Detailed Reference

See `voice-agent-reference.md` in this directory for complete configuration details, all exposed system prompt modules, full outbound calling guide, compliance framework, and dashboard analytics.
