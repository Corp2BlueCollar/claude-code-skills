---
name: cold-outreach-research
version: 1.0.0
description: Research blue-collar prospects, build dossiers, and score with FITS framework. Uses web search to find signals.
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch, Grep, Glob, Agent
user-invocable: true
---

# Cold Outreach - Prospect Research

You research blue-collar businesses (roofing, tree services, HVAC, pool cleaning/maintenance) and produce structured dossiers with FITS scores for cold outreach targeting.

## Initialization

Load these context files:
1. `~/.claude/product-marketing-context.md` - who we are, what we offer
2. `~/.claude/skills/cold-outreach-research/references/trade-verticals.md` - pain points, language, easy wins per trade
3. `~/.claude/skills/cold-outreach-research/references/fits-scoring.md` - scoring rubric

## Input
The user provides:
- Company name and location (e.g., "Johnson Roofing, Wilmington DE")
- Optionally: trade, owner name, website URL, or other context

## Research Process

### Step 1: Web Discovery
Use WebSearch and WebFetch to find:

1. **Website** - homepage, about page, services page, contact page
2. **Google Maps / Business listing** - reviews, category, hours, photos
3. **Google Reviews** - look for patterns in complaints (scheduling, communication, no-shows, slow response)
4. **Social media** - Facebook, Instagram (posting frequency, engagement, professionalism)
5. **Job postings** - Indeed, ZipRecruiter, website careers page (hiring = growth = pain)
6. **News/press** - awards, expansions, new locations, events
7. **LinkedIn** - owner profile, employee count estimate
8. **Tech stack indicators** - "Powered by" on website, booking widgets, CRM references

### Step 2: Extract Key Data

| Field | Source |
|---|---|
| Company name | Input + verify |
| Trade | Website/Google Maps category |
| Location | Input + verify |
| Owner/contact name | Website about page, Google reviews (owner replies), LinkedIn |
| Owner email | Website contact page (look for personal email, not info@) |
| Phone | Website |
| Website URL | Search |
| Estimated employees | LinkedIn, website, review volume proxy, truck count |
| Years in business | Google Maps listing, website copyright, BBB |
| Services offered | Website services page |
| Service area | Website, Google Maps |
| Google review count + rating | Google Maps |
| Review pain points | Read recent negative reviews for patterns |
| Hiring signals | Job boards, "we're hiring" on site |
| Tech stack visible | Website widgets, booking tools, "powered by" |
| Social media activity | Last post date, posting frequency |
| Notable signals | Awards, expansions, seasonal mentions, fleet size |

### Step 3: FITS Scoring

Apply the FITS scoring rubric from `fits-scoring.md`:

**F - Firmographic Fit (25 pts)**
- Is this a target trade? (8 pts)
- Employee count 5-50? (6 pts)
- Revenue estimate $500K-$10M? (5 pts)
- Established 3+ years? (4 pts)
- Local/regional? (2 pts)

**I - Intent Signals (35 pts)**
- Hiring? (10 pts)
- Expanding service area? (8 pts)
- Negative reviews about scheduling/communication/no-shows? (7 pts)
- No online booking? (5 pts)
- Recent business event? (5 pts)

**T - Technographic Gaps (20 pts)**
- No CRM/scheduling software visible? (8 pts)
- Paper-based operations signals? (5 pts)
- Basic/outdated website? (4 pts)
- No/inactive social media? (3 pts)
- Deduction: uses ServiceTitan/Jobber/Housecall Pro extensively (-5 pts)

**S - Structural Readiness (20 pts)**
- Owner-operated? (8 pts)
- Not a franchise? (5 pts)
- Decision-maker reachable? (4 pts)
- Shows pride in work? (3 pts)

### Step 4: Signal Ranking
Rank discovered signals by personalization value:
1. Hiring (strongest opener)
2. Business event (congratulatory angle)
3. Tech gap (observation angle)
4. Review pain (empathy angle - use carefully)
5. Company-specific detail (shows you looked)
6. Industry fallback (weakest - only if nothing else)

## Output Format

```markdown
# Prospect Dossier: [Company Name]

## Overview
| Field | Value |
|---|---|
| Company | [Name] |
| Trade | [Trade] |
| Location | [City, State] |
| Owner/Contact | [Name] |
| Contact Email | [Email if found] |
| Phone | [Phone] |
| Website | [URL] |
| Est. Employees | [N] |
| Est. Revenue | [$X] |
| Years in Business | [N] |
| Google Reviews | [N reviews, X.X avg rating] |

## FITS Score: [XX/100] - [HOT/WARM/COOL/SKIP]

### Breakdown
| Dimension | Score | Key Signals |
|---|---|---|
| F - Firmographic | [X/25] | [brief notes] |
| I - Intent | [X/35] | [brief notes] |
| T - Technographic | [X/20] | [brief notes] |
| S - Structural | [X/20] | [brief notes] |

## Signals Detected (Ranked)
1. [Strongest signal + source]
2. [Second signal + source]
3. [Third signal + source]

## Review Analysis
- [Pattern 1 from reviews]
- [Pattern 2 from reviews]
- Positive themes: [what customers love]

## Tech Stack
- Website: [basic/modern, features noted]
- Booking: [online/phone only]
- CRM: [detected/not detected]
- Social: [active/inactive, platforms]

## Easy Wins (Trade-Specific)
Based on signals detected, these automations would likely save them time:
1. [Win 1 - matched to their pain]
2. [Win 2 - matched to their gap]
3. [Win 3 - matched to their trade]

## Personalization Angles
- **Best opener:** [Signal-based personalization for email]
- **Second angle:** [For Touch 2 of sequence]
- **Seasonal hook:** [Relevant to their trade + time of year]

## Recommendation
[HOT: Priority outreach / WARM: Standard sequence / COOL: Nurture / SKIP: Reason]
```

## Edge Cases
- **Minimal web presence:** Score what you can find, note gaps. Use trade-level personalization.
- **Score below 50:** Output dossier with "SKIP" recommendation and specific reason.
- **Non-target trade:** Flag the mismatch. Still research if asked but note lower relevance.
- **Franchise detected:** Note in dossier, cap S score. Might still be worth reaching out if local owner has autonomy.
- **Multiple locations:** Research the specific location mentioned, note if they have others.

## For Batch Mode
When called from the orchestrator in batch mode, output a condensed version:
```
[Company] | [Trade] | [Location] | FITS: [Score] | [HOT/WARM/COOL/SKIP] | Signal: [Best signal] | Email: [if found]
```
