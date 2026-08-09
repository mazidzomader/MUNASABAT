# Memory.md — Munasabat Progress Log

> **How to use this file:** Update at the **end of every phase** and any time a real architectural/scope decision is made mid-phase. Its job is to let a new chat/agent session pick up exactly where the last one left off without re-reading the entire codebase or guessing.
>
> When starting a new AI session, paste in: `PRD.md`, `Architecture.md`, `Rules.md`, `Phases.md`, `Design.md`, and this `Memory.md`.

---

## Project Status Snapshot

- **Current phase:** Phase 2 — Host Dashboard (In Progress)
- **Last updated:** 2026-08-10
- **Overall state:** Phase 1 complete (auth refactored to email-only). Splash screen built and wired. Host Dashboard shell built with sidebar navigation. UI polish applied across auth and dashboard screens.

---

## Phase Log

### Phase 0 — Project Setup & Foundations

- **Status:** Done
- **What was built:**
  - Initialized Flutter project (`munasabat`).
  - Added dependencies to `pubspec.yaml` per `Architecture.md`.
  - Created Dart models in `lib/models/` for all Firestore collections.
  - Linked to Firebase project `munasabat-2d9c2` via `flutterfire configure`.
  - Integrated Firebase initialization inside `lib/main.dart` and verified compilation.
- **Deviations from the plan:** None.
- **Known issues / TODO:** None.
- **Decisions made:** Connected to Firebase project `munasabat-2d9c2`.

### Phase 1 — Authentication

- **Status:** Done
- **What was built:**
  - Configured project themes, colors, and typography (Playfair Display & Poppins fonts bundled).
  - Created shared widgets (`PrimaryButton`, `LoadingOverlay`, `AppTextField`, `showErrorSnackbar`/`showSuccessSnackbar`).
  - Implemented `AuthRepository` to encapsulate Firebase Auth + user registration in Firestore.
  - Implemented `AuthProvider` for session management (Riverpod `AsyncNotifier`).
  - Created `LoginScreen` (email/password only + Forgot Password bottom sheet) and `RegisterScreen` (single-step host signup: Name, Email, Password, optional Phone).
  - Set up `AppRouter` (GoRouter) with auth route guards redirecting based on auth state and role.
  - Defined initial `firestore.rules`.
  - Added SHA-1 and SHA-256 fingerprints to Firebase Console for Android app.
- **Deviations from the plan:**
  - **Phone/OTP login removed entirely** — product owner decision. Phone number is collected at registration as an optional field only; it is not used for authentication.
  - OTP verification screen, Phone login tab, and all related `AuthRepository`/`AuthProvider` phone-auth methods were deleted.
- **Known issues / TODO:** None.
- **Decisions made:**
  - Email is the only login method. Phone is an optional profile field.
  - `google-services.json` updated with SHA fingerprints for proper Firebase Auth on Android.

### Phase 2 — Host Dashboard & Event Creation

- **Status:** In Progress
- **What was built:**
  - **Splash Screen** (`lib/features/auth/screens/splash_screen.dart`):
    - Animated logo zoom-in (`Curves.elasticOut`, 1.2s) + fade-in.
    - Full-screen blue/pink gradient background using `AppGradients`.
    - Real logo loaded from `assets/img/Munasabat Logo.png` (registered in `pubspec.yaml`).
    - Auto-navigates to `/login` after animation. Router redirect sends authenticated users to `/dashboard`.
    - Route: `/splash` set as `initialLocation` in `AppRouter`.
  - **Host Dashboard Shell** (`lib/features/host_dashboard/screens/dashboard_screen.dart`):
    - Personalized greeting header with blue/pink gradient wash and time-based greeting.
    - Hamburger ☰ button opens a slide-in sidebar drawer.
    - **Sidebar drawer** contains: Events, Guests, Budget, Gifts, Items, Memories, Subscription Plan — each with a tinted icon. Sign Out at the bottom.
    - **Stats Grid** (2×2): Events, Guests, Tasks Done %, Budget Used — each card has its own tinted background and matching shadow.
    - **Recent Activity** section with welcome tips (will be replaced with real data in later phases).
- **Deviations from the plan:**
  - Dashboard shell built ahead of full event creation (event creation is still pending).
  - Bottom nav from the Phase 2 plan replaced with a **sidebar drawer** per product owner preference.
- **Known issues / TODO:**
  - Sidebar menu items (Events, Guests, Budget, etc.) are navigation stubs — `onTap` only closes the drawer; actual screens not yet built.
  - Stats grid shows hardcoded `0` values — will be populated with real Firestore data as each feature phase lands.
  - Event creation screen, Event Detail screen, Edit/Delete — **not yet built**.
- **Decisions made:**
  - Sidebar drawer navigation instead of bottom nav bar for the host dashboard.

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

## Standing Decisions Log

| Date       | Decision                                                                                              | Reason                                                                                                                    |
| ---------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 2026-08-09 | Removed the Wedding Vendors Directory feature entirely                                                | Cut from scope by product owner                                                                                           |
| 2026-08-09 | Added Wedding Gifts (cash gifting) and Premium Wedding Features via shared Stripe sandbox integration | Product owner requested; monetization + guest gifting                                                                     |
| 2026-08-09 | Payments run in **sandbox/test mode only** for the entire build                                       | Explicit instruction; going live requires separate compliance/KYC review                                                  |
| 2026-08-09 | Phone/OTP login removed — phone number is optional registration field only                            | Product owner decision: "phone is only for registration, not required any OTP. Remove phone login. Only Email is enough." |
| 2026-08-10 | Sidebar drawer navigation instead of bottom nav bar for host dashboard                                | Product owner preference expressed during dashboard design session                                                        |

---

## Open Questions Carried From PRD.md (update as resolved)

- [ ] Co-host / multiple hosts per event — needed for MVP or later?
- [ ] Contact import — attempted in MVP or deferred?
- [ ] Can guests see other guests' RSVP status, or only their own?
- [ ] Which payment gateway/PSP for the sandbox integration — Stripe Test Mode (default assumption) or a regional provider?
- [ ] What is the free-tier guest cap that Premium's "Unlimited Guests" removes?
- [ ] Can hosts set a minimum/suggested gift amount, or is it always guest-entered free-form?
- [ ] Does the platform take a commission on gifts, or is 100% attributed to the host?

---

## Known Technical Debt / Shortcuts Taken

- Dashboard stats (Events, Guests, Tasks Done %, Budget Used) are hardcoded to `0` — stub until Firestore queries are wired in Phase 2–3.
- Sidebar drawer navigation items are stubs (close drawer only) — routes will be connected as screens are built in subsequent phases.
- `GuestHomeScreen` is a placeholder screen — full guest portal builds in Phase 6.
