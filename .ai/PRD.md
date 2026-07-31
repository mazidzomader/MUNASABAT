# PRD.md — Munasabat (Wedding Planner & Guest Management Platform)

## 1. Overview

**Munasabat** is a Flutter-based wedding planning and guest management application. It gives hosts a single dashboard to plan a wedding end-to-end (event details, checklist, budget, guests, invitations, check-in, digital gifting, and post-event memories), and gives guests a simple portal to RSVP, check in, and send digital wedding gifts.

**Product name:** Munasabat
**Platform:** Flutter (iOS + Android, single codebase)
**Primary users:** Wedding Hosts (couples/families), Guests

## 2. Problem Statement

Wedding planning today is fragmented across spreadsheets, WhatsApp groups, paper invitations, and manual guest-list tracking. Hosts lack one place to manage tasks, budget, guests, and invitations. Guests lack a simple way to RSVP and receive event details. Munasabat consolidates this into one mobile app.

## 3. Target Users & Personas

| Persona | Description | Key Needs |
|---|---|---|
| **Host** | The couple or family member organizing the wedding | Plan event, manage budget/checklist, invite & track guests, check in guests day-of, share memories |
| **Guest** | Invited attendee | Receive invitation, RSVP, view venue/date, check in via QR, view/download invitation, browse memories |

## 4. Goals

- Give hosts a single dashboard to run their wedding logistics.
- Digitize invitations with unique QR codes for fast, fraud-resistant check-in.
- Give guests a frictionless, no-password (OTP) way to interact with their invitation.
- Let guests send digital/cash wedding gifts to the host, and let hosts unlock premium features — both via **SSLCOMMERZ in sandbox mode** for this build (see §6.9 and §6.10).
- Preserve wedding memories (photos/videos) in one shared, privacy-controlled gallery.

## 5. Non-Goals (Out of Scope for MVP)

- Real/live money movement — payments in this build run through **SSLCOMMERZ's sandbox environment only**; no real funds are captured, held, or paid out. Going live with real payments requires a merchant account and a separate compliance review not covered by this MVP.
- Host payouts/withdrawals to a real bank account (gift funds are tracked in-app only for MVP; payout rails are a future phase)
- Multi-language support (MVP is single language; architecture should not block future localization)
- Seating chart / table assignment tools
- Web app (Flutter mobile only for MVP; Flutter Web may be a future phase)
- Contact import is **optional/stretch**, not required for MVP sign-off
- Platform-wide admin/moderation tooling (user suspension, content takedown) — removed from scope; this build has no admin role

## 6. Feature List (Functional Requirements)

### 6.1 Authentication
- Email registration & login
- Mobile number authentication
- OTP verification (for phone login and guest portal login)
- Secure login/logout (session/token handling)
- Password reset (email flow)
- User profile management (edit name, photo, phone, email)

### 6.2 Wedding Event Management (Host)
- Create wedding event: title, date & time, venue name, Google Maps location (lat/lng + address), description, cover image
- Edit/delete event
- **Checklist Manager:** create tasks, mark complete, track % progress
- **Budget Tracker:** add expenses, categorize, view total budget, view remaining budget

### 6.3 Guest Management
- Add guest manually (name, phone, email optional)
- Import contacts (optional/stretch)
- Search guest list
- Edit guest info
- Remove guest
- Track invitation status: `Pending`, `Accepted`, `Declined`, `Checked In`

### 6.4 Digital Invitations
- Auto-generated invitation containing: event info, host name, date/time, venue, map location, unique QR code
- Share via WhatsApp (native share), SMS, Copy Link
- MVP uses native OS share sheet / native WhatsApp share — no custom WhatsApp Business API integration

### 6.5 QR Code Check-In
- Each invitation has one unique, guest-bound QR code
- Host uses in-app scanner to scan guest QR at the door
- Scanning verifies validity and automatically flips guest status to `Checked In`
- Duplicate scans of an already-checked-in guest must show a clear warning, not silently re-confirm

### 6.6 Guest Portal
- OTP login
- View upcoming invitation(s)
- View wedding details (date, venue, description)
- Open venue in Google Maps
- RSVP (Accept/Decline)
- View own QR invitation
- Download invitation (as image or PDF)

### 6.7 Event Calendar
- Interactive calendar view
- Highlights dates with events
- Tapping a date shows event details for that date

### 6.8 Wedding Memories
- Host uploads photos/videos post-event
- Guests browse gallery, like photos, leave comments
- Privacy setting per event: `Public` or `Private (Guests Only)`

### 6.9 Wedding Gifts / Cash Gifts (Recommended)
Guests can send a monetary gift to the host digitally, before or after the wedding, instead of (or alongside) a physical gift.

**Flow:**
```
Guest
  ↓
Open Invitation
  ↓
Send Wedding Gift
  ↓
SSLCOMMERZ Hosted Checkout (sandbox)
  ↓
Success
  ↓
Host Wallet / Transaction History
```

**Features:**
- Send a cash gift in-app (guest enters an amount, is redirected to SSLCOMMERZ's hosted checkout page to complete payment)
- Optional personal message attached to the gift
- Anonymous gift option (guest's name hidden from the host's view, but the transaction is still recorded server-side for reconciliation/support)
- Transaction history (guest sees their own sent gifts; host sees all gifts received per event)
- Gift summary for hosts (total received, count of gifts, optional breakdown by day)

**Scope note:** All payment flows in this build run against **SSLCOMMERZ's sandbox environment** using SSLCOMMERZ's published test credentials/cards — no real money changes hands. See `Rules.md` §11 and `Architecture.md` §9 for the sandbox-only implementation requirements.

### 6.10 Premium Wedding Features
Hosts can pay (sandbox/test transaction) to unlock premium capabilities for their event.

**Examples of premium-gated features:**
- Unlimited guests (free tier caps the guest list at a defined limit — see Open Questions)
- Extra cloud storage (higher photo/video upload limits in Wedding Memories)
- HD gallery (original-quality photo/video uploads instead of compressed)

Premium is purchased per-event (not account-wide) via the same sandbox SSLCOMMERZ integration used for gifts, so both features share one payment integration rather than two.

### 6.11 Notifications (Push)
- New invitation received
- RSVP confirmation
- Event reminders (e.g., T-7 days, T-1 day)
- New gallery upload
- Checklist reminders
- Gift received (host notified in real time)
- Premium unlock confirmed

### 6.12 User Profile
- Profile picture, name, phone, email
- List of hosted events
- List of attended events

## 7. Non-Functional Requirements

- **Performance:** Guest lists must support pagination/lazy loading (design assumes lists can grow to hundreds of guests).
- **Security:** Guest QR codes must not be guessable/sequential; must be tied server-side to a specific guest + event. Payment confirmation must always be verified server-side (IPN webhook), never trusted from the client alone.
- **Reliability:** Check-in scanning must work with poor/no connectivity at the venue where feasible (see Phases.md for offline check-in as a stretch phase).
- **Privacy:** Private galleries must not be accessible by non-invited guests or unauthenticated users. Anonymous gifts must hide the sender's identity from the host's UI while still being traceable server-side for support/fraud purposes.
- **Scalability:** Data model must support many events per host and many guests per event without redesign.
- **Accessibility:** Reasonable tap targets, color contrast, and readable font sizes (see Design.md).

## 8. Success Metrics (MVP)

- A host can create an event, add 20+ guests, send invitations, and check guests in via QR without a crash, end-to-end, in a single sitting.
- A guest can RSVP and view their QR invitation using only OTP login (no password ever required for guests).
- A guest can send a test wedding gift through the SSLCOMMERZ sandbox checkout and see it reflected in the host's wallet/transaction history.
- A host can unlock a premium feature via a sandbox test transaction and immediately see it take effect (e.g., raised guest cap).

## 9. Roles Summary

| Role | Can do |
|---|---|
| Host | Everything under their own event(s): event CRUD, guests, invitations, check-in, budget, checklist, memories, view gift wallet/transaction history, purchase premium features |
| Guest | View own invitations, RSVP, view/download own QR, browse memories per privacy rules, send wedding gifts (optionally anonymous), view own gift history |

## 10. Open Questions (track in Memory.md as decisions are made)

- Do hosts need collaborator/co-host support (multiple people managing one event) in MVP or later?
- Is contact import required for MVP launch or deferred entirely to a later phase?
- Should guests be able to see other guests' RSVP status, or only their own?
- Which SSLCOMMERZ sandbox store credentials (store ID/password) will the team use for development and demo?
- What is the free-tier guest cap that Premium's "Unlimited Guests" removes (e.g., 50, 100)?
- Should hosts be able to set a minimum/suggested gift amount, or is it always guest-entered free-form?
- Does the platform take a fee/commission on gifts, or is 100% of the (sandbox) gift amount attributed to the host?
