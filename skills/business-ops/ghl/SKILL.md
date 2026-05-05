---
name: ghl
description: Use when working with GoHighLevel (GHL) - sub-accounts, workflows, calendars, pipelines, Conversation AI, Voice AI, phone system, snapshots, custom fields, API, SaaS mode, rebilling, or any CRM automation task. Also use when the user mentions "GHL," "GoHighLevel," "HighLevel," "LC Phone," "sub-account," or "LeadConnector."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Agent
user-invocable: true
---

# GoHighLevel (GHL) Expert Skill

You are a GoHighLevel platform expert. Use this skill for any GHL configuration, automation, API integration, or troubleshooting task.

## Quick Reference

| Item | Value |
|------|-------|
| API Base URL | `https://services.leadconnectorhq.com` |
| API Version Header | `Version: 2021-07-28` |
| Auth (PIT) | `Authorization: <PIT_TOKEN>` |
| Auth (OAuth) | `Authorization: Bearer <OAUTH_TOKEN>` |
| Total Endpoints | 413 across 95 categories |
| OpenAPI Spec | [GitHub](https://github.com/GoHighLevel/highlevel-api-docs) |
| Support Portal | [help.gohighlevel.com](https://help.gohighlevel.com/) |

## Plans & Pricing

| Plan | Price | Key Capability |
|------|-------|---------------|
| Starter | $97/mo | 1 sub-account |
| Unlimited | $297/mo | Unlimited sub-accounts, rebilling at cost |
| Agency Pro | $497/mo | SaaS mode, rebilling with markup, OAuth apps |

## Core Concepts

### Sub-Accounts (Locations)
One per client business. Isolated CRM with own contacts, workflows, calendars, pipelines. Created via UI, API (`POST /locations/`), Zapier, or SaaS auto-provisioning.

### Snapshots
Reusable templates capturing all config from a sub-account (workflows, funnels, calendars, forms, pipelines, custom fields). Does NOT include contact data, user accounts, or integrations. Deploy via UI, share link, SaaS plan auto-load, or API (`snapshot_id` param).

### Workflows
Trigger → Actions with IF/ELSE branching. 94 trigger types, 100+ actions. Key triggers: Inbound Webhook, Contact Created, Appointment Status, Pipeline Stage Changed, Form Submitted, Customer Replied, Transcript Generated. Key actions: Send SMS/Email, Webhook, Custom Webhook, AI Prompt, Conversation AI, Create/Update Contact, Update Opportunity.

### Calendars
5 types: Simple (1:1), Round Robin, Class Booking, Collective, Service. Embed via iframe. API: `GET /calendars/:id/free-slots`, `POST /calendars/events/appointments`.

### Pipelines & Opportunities
Visual deal tracking. Opportunities move through pipeline stages. API: `POST /opportunities/`, `PUT /opportunities/:id/status`.

### Custom Fields & Custom Values
Fields = per-record data (contact/opportunity). Values = global placeholders (business name, phone). Types: Text, Number, Dropdown, Radio, Checkbox, Date, Monetary, Phone, Email, File Upload, Signature.

### Phone System (LC Phone)
Built-in telephony. Local: $1.15/mo. Inbound: $0.0085/min. Outbound: $0.014/min. IVR via workflow. A2P 10DLC required for US SMS ($23.95 one-time + $10/mo).

### Conversation AI
Three modes: Off, Suggestive, Auto-Pilot. Channels: SMS, Facebook, Instagram, Live Chat. Training: Web Crawler (up to 4,000 URLs), FAQs, file uploads (PDF/DOCX/PPT/TXT), tables. Up to 15 knowledge bases, 7 per bot.

### Voice AI
See the **voice-agent** skill for comprehensive Voice AI configuration and tuning.

## Key API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/contacts/` | Create contact |
| POST | `/contacts/search` | Search contacts |
| POST | `/contacts/upsert` | Create or update |
| GET | `/calendars/:id/free-slots` | Check availability |
| POST | `/calendars/events/appointments` | Book appointment |
| POST | `/opportunities/` | Create opportunity |
| PUT | `/opportunities/:id/status` | Update deal status |
| POST | `/locations/` | Create sub-account |
| POST | `/conversations/` | Create conversation |

## Webhook Events (Key)

`ContactCreate`, `ContactUpdate`, `AppointmentCreate`, `OpportunityStageUpdate`, `InboundMessage`, `OutboundMessage`, `VoiceAiCallEnd`, `PaymentReceived`, `FormSubmitted`

## Workflow Recipes (Pre-Built)
- Auto Missed Call Text-Back
- Fast Five (5-min lead nurture)
- Appointment Confirmation + Reminder
- No-Show Follow-Up
- Long-Term Reactivation
- Lead Nurturing Campaigns

## Common Tasks

### Set Up New Customer Sub-Account
1. Create sub-account (UI or API with snapshot_id)
2. Load snapshot with pre-built workflows/calendars
3. Provision phone number ($1.15/mo)
4. Register A2P 10DLC ($23.95 + $10/mo)
5. Configure calendar and availability
6. Set up Voice AI agent (see voice-agent skill)
7. Enable Conversation AI on channels
8. Create pipeline for lead tracking
9. Test workflows end-to-end

### Integrate External System
1. Create Private Integration Token (PIT) in Settings
2. Use `Authorization: <PIT>` + `Version: 2021-07-28` headers
3. Use Custom Webhook workflow action for outbound calls
4. Use Inbound Webhook trigger for incoming data
5. Monitor via Webhook Logs Dashboard

### Automate Post-Call Follow-Up
1. Use Transcript Generated trigger (filter: Voice AI, min duration)
2. AI Prompt action to classify call outcome
3. IF/ELSE branch by classification
4. Update opportunity stage / apply tags
5. Send follow-up SMS/email
6. Create task for team if needed

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using deprecated GET for contact search | Use `POST /contacts/search` |
| Assigning default phone to Voice AI | Use dedicated number to avoid routing conflicts |
| Not setting A2P registration | SMS will be blocked - register before sending |
| Snapshot missing custom field data | Snapshots copy field definitions, not data |
| IVR + Voice AI on same number | One number = one IVR workflow; use separate numbers |
| Wallet runs dry | Set auto-recharge threshold above expected daily spend |

## Detailed Reference

See `ghl-reference.md` in this directory for comprehensive API details, all 94 triggers, 100+ actions, webhook event payloads, calendar types, custom field types, and SaaS mode configuration.
