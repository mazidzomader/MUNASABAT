# Memory.md — Munasabat Progress Log

> **How to use this file:** Update at the **end of every phase** and any time a real architectural/scope decision is made mid-phase. Its job is to let a new chat/agent session pick up exactly where the last one left off without re-reading the entire codebase or guessing.
>
> When starting a new AI session, paste in: `PRD.md`, `Architecture.md`, `Rules.md`, `Phases.md`, `Design.md`, and this `Memory.md`.

---

## Project Status Snapshot

- **Current phase:** Phase 3 — Checklist & Budget Tracker (Up Next)
- **Last updated:** 2026-08-15
- **Overall state:** Phase 2 complete. Dashboard stats partially wired. Full Event CRUD implemented with OpenStreetMap interactive location picker and Nominatim search.

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

### Phase 2 — Unified Dashboard & Event Creation

- **Status:** Done
- **What was built:**
  - **Splash Screen & Auth Screens** (`lib/features/auth/auth_screen.dart`):
    - Animated logo zoom-in (`Curves.elasticOut`, 1.2s) + fade-in.
    - Auto-navigates to `/login` after animation. Router redirect sends authenticated users to `/dashboard`.
    - Consolidated Login, Registration, and Forgot Password flows in a single file.
  - **Unified Dashboard** (`lib/features/dashboard/dashboard_screen.dart`):
    - Replaced Host Dashboard with a Unified Dashboard (for merged User roles).
    - **Stats Grid** (2×2): Wired up `hostEventsProvider` and `attendingEventsProvider` for real-time event counts.
    - Sidebar drawer navigation (Events, Guests, Budget, Gifts, etc.).
  - **Event Management** (`lib/features/event/event_screen.dart`):
    - Created `EventRepository` to handle event CRUD in Firestore.
    - Consolidated Create, Edit, Detail, List, and Map Picker screens into a single feature file.
    - **Interactive Map Picker**: Implemented `flutter_map` with OpenStreetMap.
    - Added free **Nominatim Search** to the map picker for finding venues.
    - Built mini-map view on `EventDetailScreen` with an "Open in Maps" button utilizing Google Maps generic link structure.
- **Deviations from the plan:**
  - Bottom nav replaced with a **sidebar drawer** per product owner preference.
  - Abandoned Google Maps premium interactive SDK due to API billing walls. Successfully implemented OpenStreetMap via `flutter_map`.
  - Implemented features consolidated into **1 Dart file per feature module** (`auth_screen.dart`, `dashboard_screen.dart`, `event_screen.dart`).
- **Known issues / TODO:**
  - Sidebar menu items (Guests, Budget, etc.) are navigation stubs — `onTap` only closes the drawer.
- **Decisions made:**
  - Use OpenStreetMap (`flutter_map`) instead of Google Maps API.
  - Use 1 Dart file per feature module for all UI screens and subwidgets.

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

### Phase 11 — User Profile

- **Status:** Not Started

### Phase 12 — Premium Wedding Features (Sandbox Payments)

- **Status:** Not Started

### Phase 13 — Polish & Hardening

- **Status:** Not Started

---

## Standing Decisions Log

| Date       | Decision                                                                                              | Reason                                                                                                                    |
| ---------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 2026-08-09 | Removed the Wedding Vendors Directory feature entirely                                                | Cut from scope by product owner                                                                                           |
| 2026-08-09 | Added Wedding Gifts (cash gifting) and Premium Wedding Features via shared SSLCommerz sandbox integration | Product owner requested; monetization + guest gifting                                                                     |
| 2026-08-09 | Payments run in **sandbox/test mode only** for the entire build                                       | Explicit instruction; going live requires separate compliance/KYC review                                                  |
| 2026-08-09 | Phone/OTP login removed — phone number is optional registration field only                            | Product owner decision: "phone is only for registration, not required any OTP. Remove phone login. Only Email is enough." |
| 2026-08-10 | Sidebar drawer navigation instead of bottom nav bar for host dashboard                                | Product owner preference expressed during dashboard design session                                                        |
| 2026-08-15 | Generalized Users (Host and Guest merged into single User role)                                       | Product owner requested unified experience where any user can both create and join events.                                |
| 2026-08-15 | Switched from Google Maps API to OpenStreetMap (`flutter_map`)                                        | Google Maps API key required billing account. OpenStreetMap + Nominatim search achieved same goals completely free.       |
| 2026-08-16 | 1 Dart file per feature module for all UI screens and subwidgets                                      | Project architecture requirement: consolidate screens within each feature into a single self-contained file.             |

---

## Open Questions Carried From PRD.md (update as resolved)

- [ ] Co-host / multiple hosts per event — needed for MVP or later?
- [ ] Contact import — attempted in MVP or deferred?
- [ ] Can guests see other guests' RSVP status, or only their own?
- [ ] Which payment gateway/PSP for the sandbox integration — SSLCommerz Sandbox Mode (default assumption) or a regional provider?
- [ ] What is the free-tier guest cap that Premium's "Unlimited Guests" removes?
- [ ] Can hosts set a minimum/suggested gift amount, or is it always guest-entered free-form?
- [ ] Does the platform take a commission on gifts, or is 100% attributed to the host?

---

## Known Technical Debt / Shortcuts Taken

- Dashboard stats for Guests, Tasks Done %, and Budget Used are still hardcoded to `0` — waiting for Phase 3 and Phase 4.
- Sidebar drawer navigation items are stubs (close drawer only) — routes will be connected as screens are built in subsequent phases.
