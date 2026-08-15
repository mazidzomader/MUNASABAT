# Phases.md — Build Plan for Munasabat

The agent must build in this order. Do not start a phase until the previous one is demoable and `Memory.md` has been updated. Each phase lists: goal, scope, and exit criteria (what "done" looks like).

---

## Phase 0 — Project Setup & Foundations
**Goal:** A running Flutter app connected to Firebase, with theming and navigation skeleton in place.
**Scope:**
- Flutter project init, folder structure per `Architecture.md`
- Firebase project setup (dev flavor), `firebase_core` initialized
- `go_router` skeleton with placeholder screens for every route in `Architecture.md` §6
- Theme setup per `Design.md` (colors, fonts, `ThemeData`)
- Shared widgets: loading indicator, error state, empty state, primary button

**Exit criteria:** App builds and runs on iOS + Android simulators, navigates between placeholder screens, shows the correct theme.

---

## Phase 1 — Authentication
**Goal:** Full auth flow for both email and phone/OTP.
**Scope:**
- Register (email/password), Login (email/password), Login (phone/OTP), OTP verification screen, Password reset
- `auth_repository.dart`, `auth_provider.dart`
- Session persistence + logout
- Basic role field on `users/{userId}` (`host` default; `admin` set manually in Firestore for now — no self-serve admin signup)

**Exit criteria:** A new user can register by email, log out, log back in; a user can log in by phone number and verify via OTP; password reset email works.

---

## Phase 2 — Unified Dashboard & Event Creation
**Goal:** Users can create new events and see an overview of events they are hosting or attending.
**Scope:**
- Unified Dashboard shell (Tabs for "Hosting" and "Attending", plus sidebar drawer navigation)
- Create Event screen (title, date/time picker, venue name, Google Maps location picker/link, description, cover image upload)
- Event Detail screen showing all entered info
- Edit/Delete event

**Exit criteria:** Host creates an event with a cover image, sees it on the dashboard, edits it, and can delete it.

---

## Phase 3 — Checklist & Budget Tracker
**Goal:** Host can manage planning tasks and expenses per event.
**Scope:**
- Checklist Manager: add task, mark complete, progress bar
- Budget Tracker: add expense (label, category, amount), total vs. remaining budget view

**Exit criteria:** Host adds 5+ checklist items and marks some complete (progress updates); host adds several expenses across categories and sees an accurate running total/remaining balance.

---

## Phase 4 — Guest Management
**Goal:** Host can build and manage a guest list.
**Scope:**
- Add guest manually (name, phone, email)
- Guest list screen with search
- Edit/remove guest
- Invitation status field displayed (`Pending` initially)
- *(Contact import is a stretch item for this phase — only attempt after the manual flow is solid and confirmed working)*

**Exit criteria:** Host adds, searches, edits, and removes guests; list reflects changes in real time.

---

## Phase 5 — Digital Invitations & QR Generation
**Goal:** Every guest gets a unique digital invitation with a QR code.
**Scope:**
- Cloud Function: generate unique, cryptographically random `qrToken` per guest+event, create `invitations/{invitationId}` doc
- Invitation preview screen (event info, host name, date/time, venue, map link, QR code rendered via `qr_flutter`)
- Share via WhatsApp (native share sheet), SMS, Copy Link

**Exit criteria:** Host taps "Send Invitation" for a guest, sees a generated invitation with a QR code, and can share it through the native share sheet.

---

## Phase 6 — Attending Events (Unified Flow)
**Goal:** Invited users can manage their received invitations from the dashboard.
**Scope:**
- View upcoming invitation(s) from the "Attending" tab on the dashboard
- View event details, "Open in Google Maps"
- RSVP (Accept/Decline) — writes back to `guests/{guestId}.status`
- View own QR code, Download invitation (image/PDF)

**Exit criteria:** A user taps on an event they are invited to from the dashboard, sees their invitation, RSVPs, and downloads their QR invitation as an image or PDF.

---

## Phase 7 — QR Check-In
**Goal:** Host can scan guest QR codes at the event to check them in.
**Scope:**
- `mobile_scanner`-based scanner screen
- Cloud Function: validate scanned `qrToken` against `invitations` collection, flip guest status to `Checked In`, set `checkedInAt`
- UI feedback: success (green, guest name shown), invalid QR (red, clear error), already-checked-in (distinct warning state, not a silent re-confirm)

**Exit criteria:** Host scans a valid guest QR and sees an immediate success state with guest name; scanning the same QR twice shows an "already checked in" warning, not a duplicate success.

---

## Phase 8 — Wedding Gifts / Cash Gifts (Sandbox Payments)
**Goal:** Guests can send a digital cash gift to the host through a sandbox payment flow; hosts can see what they've received.
**Scope:**
- Stripe Test Mode integration: `flutter_stripe` client SDK + Cloud Functions `createGiftPaymentIntent` and `stripeWebhookHandler` (see `Architecture.md` §9, `Rules.md` §11)
- Guest-side "Send Wedding Gift" screen: amount entry, optional personal message, "send anonymously" toggle, Stripe payment sheet
- Guest-side transaction history (their own sent gifts)
- Host-side gift wallet: total received, per-gift list (name or "Anonymous", amount, message, timestamp), gift summary stats
- Webhook handler is the only writer of `paymentStatus: "succeeded"` — no client-side trust

**Exit criteria:** A guest sends a test gift using a Stripe test card (e.g., `4242 4242 4242 4242`), sees a success confirmation, and the host's wallet/transaction history immediately reflects it — including a correctly anonymized entry when "send anonymously" was used. A declined test card correctly shows a failure state without crediting the host.

---

## Phase 9 — Event Calendar
**Goal:** Host (and optionally guest) can see events on a calendar view.
**Scope:**
- `table_calendar` integration, highlight dates with events
- Tap date → show event details for that date

**Exit criteria:** Calendar correctly highlights all of a host's event dates and shows correct details when a highlighted date is tapped.

---

## Phase 10 — Wedding Memories (Gallery)
**Goal:** Post-event photo/video sharing with privacy controls.
**Scope:**
- Host uploads photos/videos to an event gallery
- Guests browse gallery, like photos, comment
- Privacy toggle: Public vs. Private (Guests Only), enforced via Firestore Security Rules

**Exit criteria:** Host uploads media; a logged-in guest tied to that event can view, like, and comment; a random unauthenticated/unrelated user cannot view a Private gallery.

---

## Phase 11 — Notifications
**Goal:** Push notifications for key lifecycle events.
**Scope:**
- FCM setup (client token registration + permission prompt)
- Cloud Function triggers: new invitation, RSVP confirmation, event reminder (scheduled), new gallery upload, checklist reminder, gift received, premium unlock confirmed

**Exit criteria:** Creating an invitation, RSVPing, uploading a gallery photo, and receiving a test gift each trigger a real push notification to the relevant user's device.

---

## Phase 12 — User Profile
**Goal:** Users can view/edit their profile and see their event history.
**Scope:**
- Profile screen: picture, name, phone, email (edit)
- Hosted events list, Attended events list

**Exit criteria:** User edits their profile picture/name and sees accurate hosted/attended event lists.

---

## Phase 13 — Premium Wedding Features (Sandbox Payments)
**Goal:** Hosts can unlock premium features for an event via a sandbox purchase.
**Scope:**
- Paywall screen listing premium features: Unlimited Guests, Extra Cloud Storage, HD Gallery
- Reuses the Phase 8 Stripe Test Mode integration (`createPremiumPaymentIntent`, same webhook handler pattern)
- On confirmed webhook success, `events/{eventId}/premium.isPremium` flips to `true` and `unlockedFeatures` updates
- Guest cap / storage cap / gallery quality logic in relevant features (Guests, Memories) reads this flag

**Exit criteria:** Host completes a sandbox test purchase from the paywall, sees an immediate confirmation, and a previously-capped feature (e.g., guest list limit) is now unlocked without needing to restart the app.

---

## Phase 14 — Admin Dashboard
**Goal:** Admins can moderate users and events.
**Scope:**
- Role-gated `/admin` route
- User management: view list, suspend, delete
- Event management: view all events, remove inappropriate events
- Payments oversight: read-only view of gift and premium transactions (sandbox data) for support/reconciliation

**Exit criteria:** An admin-flagged account can log in, view all users/events, suspend a user, remove an event, and view a list of sandbox gift/premium transactions — and a non-admin cannot access `/admin/*` at all.

---

## Phase 15 — Polish & Hardening
**Goal:** Production-readiness pass.
**Scope:**
- Firestore Security Rules audit against Rules.md §4 and §11 (payments)
- Empty states, loading states, error states audited across all screens
- App icon, splash screen, final theming pass per `Design.md`
- Basic analytics-free crash reporting (Firebase Crashlytics) if approved

**Exit criteria:** Full manual walkthrough of every user journey in `Architecture.md` §5 with no crashes and consistent empty/error/loading states.

---

## Notes on Phase Order

- Phases 0–7 form the critical MVP path (auth → event → guests → invitations → check-in). Phase 8 (Gifts) is placed right after check-in because it reuses the guest portal built in Phase 6 and is a natural next step; Phase 13 (Premium) reuses Phase 8's payment plumbing, so it's placed after the features it gates (Guests, Memories) are built. Everything from Phase 9 onward can be reordered if there's a business reason, but the agent must not skip ahead without updating this file and `Memory.md` first.
- Contact import (mentioned as optional in `PRD.md`) is intentionally not its own phase — attempt it only as a stretch add-on inside Phase 4 once the core guest flow works.
