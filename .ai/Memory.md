# Memory.md — Munasabat Progress Log

> **How to use this file:** This file does not exist at project start. Create it right before the AI agent writes its first line of code (start of Phase 0), and update it at the **end of every phase** and any time a real architectural/scope decision is made mid-phase. Its job is to let a new chat/agent session pick up exactly where the last one left off **without re-reading the entire codebase or guessing**. Keep entries short and factual — this is a status log, not a diary.
>
> When starting a new AI session, paste in: `PRD.md`, `Architecture.md`, `Rules.md`, `Phases.md`, `Design.md`, and this `Memory.md`. `Memory.md` tells the agent what's already true; the other five tell it what "true" is supposed to look like.

---

## How to Fill This Out (template — delete this section once real entries begin)

Each phase entry should include:
- **Status:** Not Started / In Progress / Done / Blocked
- **What was built:** bullet list of concrete files/screens/functions added or changed
- **Deviations from the plan:** anything that differs from `PRD.md`/`Architecture.md`/`Design.md`, and why
- **Known issues / TODO:** anything left rough, stubbed, or intentionally deferred
- **Decisions made:** answers to any "Open Questions" from `PRD.md`, or new decisions not previously documented

---

## Project Status Snapshot

- **Current phase:** _(e.g., Phase 2 — Host Dashboard & Event Creation)_
- **Last updated:** _(date)_
- **Overall state:** _(e.g., "Auth complete and stable; event creation UI built, Firestore write untested")_

---

## Phase Log

### Phase 0 — Project Setup & Foundations
- **Status:** Not Started
- **What was built:**
- **Deviations from the plan:**
- **Known issues / TODO:**
- **Decisions made:**

### Phase 1 — Authentication
- **Status:** Not Started
- **What was built:**
- **Deviations from the plan:**
- **Known issues / TODO:**
- **Decisions made:**

### Phase 2 — Host Dashboard & Event Creation
- **Status:** Not Started
- **What was built:**
- **Deviations from the plan:**
- **Known issues / TODO:**
- **Decisions made:**

### Phase 3 — Checklist & Budget Tracker
- **Status:** Not Started

### Phase 4 — Guest Management
- **Status:** Not Started

### Phase 5 — Digital Invitations & QR Generation
- **Status:** Not Started

### Phase 6 — Guest Portal (OTP-based)
- **Status:** Not Started

### Phase 7 — QR Check-In
- **Status:** Not Started

### Phase 8 — Wedding Gifts / Cash Gifts (Sandbox Payments)
- **Status:** Not Started

### Phase 9 — Event Calendar
- **Status:** Not Started

### Phase 10 — Wedding Memories (Gallery)
- **Status:** Not Started

### Phase 11 — Notifications
- **Status:** Not Started

### Phase 12 — User Profile
- **Status:** Not Started

### Phase 13 — Premium Wedding Features (Sandbox Payments)
- **Status:** Not Started

### Phase 14 — Admin Dashboard
- **Status:** Not Started

### Phase 15 — Polish & Hardening
- **Status:** Not Started

---

## Standing Decisions Log (accumulates across phases — never delete, only append)

| Date | Decision | Reason |
|---|---|---|
| _(fill in)_ | Removed the Wedding Vendors Directory feature entirely (no vendor browsing, favorites, or vendor admin management) | Cut from scope by product owner |
| _(fill in)_ | Added Wedding Gifts (cash gifting) and Premium Wedding Features, both via one shared payment integration (Stripe) | Product owner requested; monetization + guest gifting features |
| _(fill in)_ | Payments run in **sandbox/test mode only** for this entire build — no live keys, no real money movement | Explicit instruction from product owner; going live requires a separate compliance/KYC review not yet scoped |
| _e.g._ | _e.g. "Contact import deferred entirely, not attempted in Phase 4"_ | _e.g. "Low ROI for MVP, revisit post-launch"_ |

---

## Open Questions Carried From PRD.md (update as resolved)

- [ ] Co-host / multiple hosts per event — needed for MVP or later?
- [ ] Contact import — attempted in MVP or deferred?
- [ ] Can guests see other guests' RSVP status, or only their own?
- [ ] Which payment gateway/PSP for the sandbox integration — Stripe Test Mode (default assumption) or a regional provider?
- [ ] What is the free-tier guest cap that Premium's "Unlimited Guests" removes?
- [ ] Can hosts set a minimum/suggested gift amount, or is it always guest-entered free-form?
- [ ] Does the platform take a commission on gifts, or is 100% attributed to the host (sandbox behavior should match the intended real-money design even though no real money moves yet)?

---

## Known Technical Debt / Shortcuts Taken

_List anything built as a temporary stub (e.g., "vendor seed data added manually in Firestore console instead of via Admin UI, until Phase 13") so it isn't mistaken for finished work by a future session._
