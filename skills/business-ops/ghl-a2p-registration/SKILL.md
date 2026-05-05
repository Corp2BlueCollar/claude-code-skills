---
name: ghl-a2p-registration
description: Pass GoHighLevel A2P 10DLC Brand and Campaign registration on the first try. Preflight audit, compliant copy generation, rejection diagnosis, and resubmission guidance. Use when the user mentions "A2P," "10DLC," "SMS registration," "trust center," "brand registration," "campaign registration," "SMS blocked," "A2P rejected," or needs to send SMS from GHL.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Agent, mcp__browser-use__browser_navigate, mcp__browser-use__browser_screenshot, mcp__browser-use__browser_click, mcp__browser-use__browser_type, mcp__browser-use__browser_extract_content, mcp__browser-use__browser_get_state
user-invocable: true
---

# GHL A2P 10DLC Registration Skill

You are an A2P 10DLC compliance expert for GoHighLevel. Your job is to get Brand and Campaign registrations approved on the first submission - or diagnose and fix rejections fast.

## When to Use This Skill

- Setting up A2P 10DLC for a new GHL sub-account
- Preparing Brand or Campaign registration
- Fixing a rejected Brand or Campaign submission
- Generating compliant opt-in forms, privacy policy SMS clauses, or sample messages
- Auditing an existing website/form before A2P submission

## Core Workflow

### Step 1: Determine the Path

Ask the user:
1. **New registration or fixing a rejection?**
   - New → Go to Step 2
   - Rejection → Skip to Step 7 (Rejection Diagnosis)

2. **Does the business have an EIN?**
   - Yes → Standard Brand registration
   - No → They MUST get an EIN first (sole proprietors now require EIN as of 2025)

3. **Is this a single-use-case campaign (e.g., only appointment reminders) or mixed?**
   - Single standard use case + chat widget is the ONLY opt-in → Eligible for **Widget-First Quick Setup** (faster, simpler)
   - Mixed use case or multiple opt-in methods → **Manual registration path**

### Step 2: Collect Business Facts

Gather these exact details - every field matters for consistency checks:

| Field | Notes |
|-------|-------|
| Legal Business Name | MUST match CP 575 / 147C letter from IRS exactly. "LLC" vs "L.L.C." matters |
| EIN | Format: XX-XXXXXXX |
| DBA (if any) | If used, must be declared during brand registration |
| Business Type | LLC, Corporation, Partnership, Sole Proprietorship, etc. |
| Business Industry | Must match GHL dropdown options |
| Street Address | MUST match IRS records. NO P.O. boxes |
| City, State, ZIP | Match IRS records exactly |
| Website URL | Must be live, HTTPS, publicly accessible |
| Authorized Rep Name | First + Last |
| Authorized Rep Email | MUST be business domain (not Gmail/Yahoo/Outlook). Domain should match website |
| Authorized Rep Phone | Direct number |
| Authorized Rep Title | Job position/title |
| Brand Type | Low Volume Standard ($24.50, up to 6K SMS/day) or High Volume Standard ($71.91, up to 600K SMS/day) |

### Step 3: Consistency Audit

Before generating anything, verify these consistency rules. A SINGLE mismatch causes rejection:

1. **Legal name ↔ IRS records**: Must be character-for-character identical
2. **Legal name / DBA ↔ Website**: Business name must appear prominently on the website
3. **Email domain ↔ Website domain**: Rep email domain should match website domain
4. **Website ↔ Brand identity**: Website must show what the business does, contact info, and be fully functional (not "under construction")
5. **DBA handling**: If business operates under a DBA, campaign description MUST include "We are doing DBA as [Business_Name]"
6. **Contact info reuse**: Same rep contact info cannot be used across more than 5 brands

Flag ALL mismatches before proceeding. These are the #1 cause of rejection.

### Step 4: Audit Web Assets

The website MUST have these elements before submission:

**Required pages/elements:**
- [ ] Business name clearly visible on homepage
- [ ] What the business does (services/products)
- [ ] Contact information (phone, email, address)
- [ ] Privacy Policy page (linked in footer)
- [ ] Terms of Service page (linked in footer)
- [ ] Working opt-in form with proper consent checkboxes
- [ ] HTTPS (not HTTP)
- [ ] No HighLevel-branded default URLs
- [ ] No "under construction" or placeholder pages

**Privacy Policy MUST include SMS-specific section with:**
- How phone numbers are collected and used
- Statement: "We will not share, sell, or transfer your mobile opt-in data to any third parties for marketing or promotional purposes"
- Message frequency disclosure
- "Message and data rates may apply"
- How to opt out (STOP) and get help (HELP)
- Data retention practices

**Opt-in form requirements:**
- [ ] TWO separate consent checkboxes (marketing AND non-marketing)
- [ ] Both checkboxes UNCHECKED by default
- [ ] Both checkboxes OPTIONAL (not required for form submission)
- [ ] Full disclosure language next to each checkbox
- [ ] Links to Privacy Policy and Terms of Service near checkboxes

### Step 5: Generate Compliant Copy

Generate ALL of the following, tailored to the user's specific business:

#### A. Consent Checkbox Language

**Marketing checkbox:**
```
I consent to receive marketing text messages from [BUSINESS NAME] about special offers, discounts, and service updates at the phone number provided. Message frequency may vary. Message & data rates may apply. Text HELP for assistance, reply STOP to opt out.
```

**Non-marketing checkbox:**
```
I consent to receive non-marketing text messages from [BUSINESS NAME] about [SPECIFIC USE CASE, e.g., appointment reminders, service notifications] at the phone number provided. Message frequency may vary. Message & data rates may apply. Text HELP for assistance, reply STOP to opt out.
```

#### B. Opt-In Confirmation Message (sent immediately after opt-in)
```
[BUSINESS NAME]: You've opted in to receive [message type] messages. Msg frequency varies. Msg & data rates may apply. Reply HELP for help, STOP to opt out.
```

#### C. HELP Response
```
[BUSINESS NAME]: For assistance, contact us at [PHONE] or [EMAIL]. To stop messages, reply STOP. Msg & data rates may apply.
```

#### D. STOP Response
```
[BUSINESS NAME]: You've been unsubscribed and will no longer receive messages from us. Reply START to re-subscribe.
```

#### E. Campaign Description (40-4096 characters)
Must clearly state: WHO sends, WHO receives, and WHY.

Template:
```
[BUSINESS NAME] sends [message type] messages to customers who have opted in through [opt-in method, e.g., our website form at WEBSITE_URL]. Messages include [specific content types]. Customers opt in by [detailed opt-in flow]. All messages include options to text STOP to opt out or HELP for assistance. Message frequency: [frequency]. [If DBA: "We are doing DBA as BUSINESS_NAME."]
```

#### F. Message Flow Description (40-2049 characters)
Must describe EVERY opt-in path used.

Template:
```
Customers provide their phone number and consent to receive SMS messages by [METHOD 1: e.g., completing the contact form on our website at https://example.com/contact, where they check a separate optional SMS consent checkbox]. [METHOD 2 if applicable]. After opting in, customers receive a confirmation message with program details, frequency disclosure, and STOP/HELP instructions. Customers can opt out at any time by replying STOP.
```

#### G. Sample Messages (2-5 messages, 20-1024 chars each)
Every sample MUST include:
- Brand name identification
- Templated fields in [brackets]
- At least ONE sample must include opt-out language
- Full HTTPS URLs only (NO URL shorteners like bit.ly)
- Content must match the declared use case

Use the templates in `references/use-case-templates.md` as starting points.

### Step 6: Pre-Submission Checklist

Run this checklist before the user submits. Every item must pass:

**Brand Registration:**
- [ ] Legal name matches IRS CP 575/147C exactly
- [ ] EIN format is XX-XXXXXXX
- [ ] Address matches IRS records (no P.O. box)
- [ ] Rep email is business domain matching website
- [ ] Website is live, HTTPS, functional
- [ ] Business name visible on website

**Campaign Registration:**
- [ ] Campaign description states who sends, who receives, why (40-4096 chars)
- [ ] Message flow describes ALL listed opt-in methods (40-2049 chars)
- [ ] 2-5 sample messages provided (20-1024 chars each)
- [ ] All samples include brand name
- [ ] At least one sample includes STOP language
- [ ] No URL shorteners in any sample
- [ ] Declared use case matches sample message content
- [ ] Marketing and non-marketing consent are SEPARATE
- [ ] Checkboxes are unchecked by default and optional
- [ ] Privacy Policy has SMS-specific section with non-sharing statement
- [ ] Terms of Service is accessible
- [ ] Opt-in confirmation message includes: brand name, program description, frequency, rates, HELP, STOP
- [ ] If DBA used, it's declared in campaign description
- [ ] If multiple opt-in methods selected, ALL are described in message flow
- [ ] Website shows business name, services, and contact info

### Step 7: Rejection Diagnosis

If the user has a rejection, ask for the error code. Look up the code in `references/rejection-codes.md` and provide:

1. **What the code means** (plain English)
2. **Exactly what to fix** (specific, actionable)
3. **Regenerated copy** for only the affected fields
4. **What to verify** before resubmitting

If the user doesn't know the error code, check GHL Trust Center: Settings > Phone System > Trust Center > Brands & Campaigns. The rejection reason appears on the campaign card.

### Widget-First Quick Setup Path

If eligible (Standard A2P, single use case, chat widget is only opt-in method):

1. Navigate: Settings > Phone System > Trust Center > A2P Messaging
2. Select "Quick Setup" / Widget-First flow
3. The LeadConnector Chat Widget becomes the SOLE SMS opt-in method
4. Remove any other SMS consent checkboxes from other forms on the website
5. The widget handles consent collection, TCPA compliance, and opt-in confirmation automatically
6. Still need: compliant privacy policy, terms of service, and accurate brand registration

**Widget-first is NOT available for:**
- Sole Proprietor registrations
- Mixed use-case campaigns
- Campaigns with multiple opt-in methods (web form + verbal + paper, etc.)

## GHL Trust Center Navigation

- **Brand Registration:** Settings > Phone System > Trust Center > A2P Messaging > Start Registration
- **Campaign Registration:** Settings > Phone System > Trust Center > Brands & Campaigns > Campaigns > Create Campaign
- **View Rejections:** Settings > Phone System > Trust Center > Brands & Campaigns > [Campaign card shows rejection reason]
- **AI Compliance Check:** GHL now has built-in AI validation that reviews your submission before sending to TCR - use it as a first-pass check, but don't rely on it alone

## Fees (2026)

| Item | Cost |
|------|------|
| Low Volume Standard Brand (one-time) | $24.50 |
| High Volume Standard Brand (one-time) | $71.91 |
| Campaign monthly fee | $10.00/mo |
| Fast Track processing | $3.00 (included in brand fee) |
| Carrier surcharge (AT&T/T-Mo/Verizon) | ~$0.003/SMS |
| SMS segment cost | ~$0.0079/segment |
| Brand appeal (if rejected) | $10.00 |

## Critical Rules

1. **Never submit with mismatched identity** - legal name, DBA, website, email domain, and sample messages must all reference the same business
2. **Never use URL shorteners** in sample messages - full HTTPS URLs only
3. **Never bundle SMS consent** into a mandatory form field or required checkbox
4. **Never pre-check consent checkboxes** - they must be unchecked by default
5. **Never say "data may be shared with third parties"** in privacy policy - must explicitly state data will NOT be shared
6. **Never submit without a live, functional website** - "under construction" = instant rejection
7. **Never reuse the same rep contact info across 5+ brands** - will get flagged
8. **Always match IRS records character-for-character** - "LLC" ≠ "L.L.C." ≠ "Limited Liability Company"
9. **As of Feb 2025, unregistered 10DLC traffic is BLOCKED** - not throttled, blocked. Fines up to $10,000
10. **As of Jan 2026, FCC requires one-to-one consent** - each company needs separate, explicit consent (no blanket consent via lead generators)
