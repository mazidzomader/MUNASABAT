# Architecture.md — Munasabat

This document defines the technical stack, app architecture, folder structure, and data model. The AI agent must follow this structure for every phase in Phases.md. Do not introduce a different architecture pattern mid-project without updating this file first.

## 1. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (stable channel) | Single codebase for iOS + Android |
| Language | Dart (null-safety on) | |
| State management | Riverpod (`flutter_riverpod`) | No `setState`-driven business logic; UI-local state only |
| Navigation | `go_router` | Declarative routes, deep-link friendly (needed for invitation links) |
| Backend | Firebase (Auth, Firestore, Cloud Functions, Cloud Messaging) + Google Cloud Storage (GCS) for file storage | See note below on why storage is split out from Firebase |
| Auth | Firebase Authentication (Email/Password + Phone/OTP) | |
| Database | Cloud Firestore | NoSQL, real-time listeners for guest status/RSVP updates |
| File storage | Google Cloud Storage (GCS) bucket, **not** Firebase Storage | Cover images, gallery photos/videos, profile pictures. Uploads/downloads are mediated by signed URLs issued from Cloud Functions — see §9. |
| Push notifications | Firebase Cloud Messaging (FCM) | |
| Server logic | Firebase Cloud Functions (Node.js/TypeScript) | QR validation, notification triggers, GCS signed-URL issuance, payment IPN handling |
| Payments | SSLCOMMERZ (**Sandbox mode only**) via hosted checkout (WebView) + SSLCOMMERZ REST API (Cloud Functions) | Used for Wedding Gifts and Premium Feature purchases. No live store credentials anywhere in this build. See §10. |
| QR generation | `qr_flutter` | |
| QR scanning | `mobile_scanner` | |
| Payment checkout UI | `webview_flutter` | Renders SSLCOMMERZ's hosted sandbox checkout page in-app; app never collects card details itself |
| Maps | `url_launcher` (open Google Maps externally) + optionally `google_maps_flutter` for embedded preview | MVP may just deep-link to Maps app instead of embedding a map widget — confirm per phase |
| Calendar UI | `table_calendar` | |
| Image picking | `image_picker` | |
| PDF generation (invitation download) | `pdf` + `printing` packages | |
| Local formatting | `intl` | Dates, currency |
| Env config | `flutter_dotenv` or Firebase per-flavor config | No secrets committed to source control |

> If the AI agent believes a different package is needed, it must propose the change and get explicit confirmation before adding it. See Rules.md §2.
>
> **Why GCS instead of Firebase Storage:** Firebase Storage *is* GCS underneath, with an added declarative security-rules layer. Since this project uses plain GCS directly (coursework preference — simpler to reason about, fewer moving Firebase pieces), that rules layer isn't available. Per-user/per-guest access control (e.g., keeping a "Private" gallery private) is therefore enforced differently: Cloud Functions check the requester's Firestore role/invite status and only then mint a short-lived signed URL for upload or download. Public content (cover images, Public-privacy galleries) can be served as plain public URLs. See §9 for the full pattern.
>
> **Why SSLCOMMERZ:** per product owner's instruction. Its integration model is different from an SDK-embedded payment sheet — SSLCOMMERZ works via a backend-created "session" that returns a hosted checkout page URL, which the Flutter app opens in a WebView. Confirmation still arrives server-side via SSLCOMMERZ's IPN (Instant Payment Notification) callback, so the "never trust the client alone" rule in Rules.md §11 still applies unchanged.

## 2. High-Level Architecture

Munasabat follows a **layered, feature-first architecture**:

```
UI (Widgets/Screens)
   ↓ watches / calls
Riverpod Providers (state + business logic)
   ↓ calls
Repository layer (abstracts data source)
   ↓ calls
Firebase Services (Auth / Firestore / Functions) + Google Cloud Storage (via signed URLs) + SSLCOMMERZ (via Cloud Functions)
```

Rules:
- Widgets never call Firebase, GCS, or SSLCOMMERZ directly. They only read/watch providers.
- Providers never contain raw Firestore query strings inline in the UI layer — that logic lives in repositories.
- Repositories are the only layer allowed to import `cloud_firestore` and `firebase_auth` packages directly. GCS access from the client is never via a raw GCS SDK — it's always an HTTP upload/download against a signed URL obtained through a Cloud Function (see §9).
- Cross-cutting server-trusted logic (e.g., "mark guest as checked in," "validate QR," "issue a signed storage URL," "confirm a payment") must go through Cloud Functions, not direct client writes, wherever it affects another user's data or requires elevated trust.

## 3. Folder Structure

```
lib/
├── main.dart
├── app.dart                        # MaterialApp / router setup
├── core/
│   ├── constants/                  # app-wide constants (enums, keys)
│   ├── theme/                      # theme_data.dart, colors.dart, text_styles.dart (see Design.md)
│   ├── routing/                    # go_router config, route names
│   ├── utils/                      # formatters, validators, helpers
│   └── widgets/                    # shared/reusable widgets (buttons, loaders, empty states)
├── models/
│   ├── user_model.dart
│   ├── event_model.dart
│   ├── guest_model.dart
│   ├── invitation_model.dart
│   ├── checklist_item_model.dart
│   ├── expense_model.dart
│   ├── memory_model.dart           # gallery photo/video + comments/likes
│   ├── gift_model.dart             # cash gift / transaction
│   └── premium_model.dart          # premium status + unlocked features per event
├── repositories/
│   ├── auth_repository.dart
│   ├── event_repository.dart
│   ├── guest_repository.dart
│   ├── invitation_repository.dart
│   ├── memory_repository.dart
│   └── payment_repository.dart     # wraps Cloud Function calls to create SSLCOMMERZ sessions + poll payment status; only layer allowed to touch payment endpoints
├── providers/
│   ├── auth_provider.dart
│   ├── event_provider.dart
│   ├── guest_provider.dart
│   ├── invitation_provider.dart
│   ├── memory_provider.dart
│   └── payment_provider.dart       # drives gift sending + premium purchase UI state (incl. WebView checkout lifecycle)
├── features/
│   ├── auth/
│   │   └── auth_screen.dart        # Unified Auth (splash, login, register, forgot password)
│   ├── dashboard/
│   │   └── dashboard_screen.dart   # Unified Dashboard (overview, drawer, tabs, stats)
│   ├── event/
│   │   └── event_screen.dart       # Event Management (create, edit, detail, list, location picker)
│   ├── guests/
│   │   └── guest_screen.dart       # Guest Management (guest list, add guest, guest detail)
│   ├── invitations/
│   │   └── invitation_screen.dart  # Digital Invitations (preview, share)
│   ├── checkin/
│   │   └── checkin_screen.dart     # QR Check-In scanner
│   ├── guest_portal/
│   │   └── attending_screen.dart   # Attending events (my invitations, RSVP, my QR)
│   ├── calendar/
│   │   └── calendar_screen.dart    # Event calendar view
│   ├── gifts/
│   │   └── gift_screen.dart        # Wedding gifts (send gift, wallet, history)
│   ├── premium/
│   │   └── premium_screen.dart     # Premium paywall & feature unlock
│   ├── memories/
│   │   └── memory_screen.dart      # Wedding memories gallery & media upload
│   └── profile/
│       └── profile_screen.dart     # User profile management
└── services/
    ├── notification_service.dart   # FCM setup, topic/token handling
    ├── qr_service.dart             # QR payload generation/parsing helpers (client-side display only)
    └── storage_service.dart        # wraps HTTP upload/download against GCS signed URLs (requests the URL from a Cloud Function, then PUTs/GETs directly to GCS)

functions/                          # Firebase Cloud Functions (Node.js/TypeScript)
├── src/
│   ├── checkin/                    # validateAndCheckIn(guestId, eventId, qrToken)
│   ├── notifications/              # triggers on RSVP, new invite, new memory upload, gift received, premium unlock
│   ├── storage/                    # getUploadUrl(path), getDownloadUrl(path) — checks Firestore role/invite status before signing
│   └── payments/                   # createGiftSession, createPremiumSession, sslcommerzIpnHandler (sandbox credentials only)
└── index.ts                        # entry point — every Cloud Function above must be re-exported from here for Firebase to deploy it
```

## 4. Data Model (Firestore Collections)

```
users/{userId}
  - name, email, phone, photoUrl
  - hostedEventIds: [string]
  - attendedEventIds: [string]
  - createdAt

events/{eventId}
  - hostId, title, date, venueName, venueLatLng, description, coverImageUrl
  - createdAt, privacy ("public" | "private")

events/{eventId}/checklist/{itemId}
  - title, isCompleted, createdAt

events/{eventId}/expenses/{expenseId}
  - label, category, amount, createdAt

events/{eventId}/guests/{guestId}
  - name, phone, email, status ("pending" | "accepted" | "declined" | "checked_in")
  - invitationId, checkedInAt

invitations/{invitationId}
  - eventId, guestId, qrToken (unique, server-generated, non-sequential)
  - createdAt

events/{eventId}/memories/{memoryId}
  - type ("photo" | "video"), url, uploadedBy, createdAt
  - likes: [userId], comments subcollection

events/{eventId}/memories/{memoryId}/comments/{commentId}
  - userId, text, createdAt

events/{eventId}/gifts/{giftId}
  - senderId (always stored server-side, even if isAnonymous), displayName (null if isAnonymous),
    amount, currency, message, isAnonymous, paymentStatus ("pending" | "succeeded" | "failed"),
    sslcommerzTranId (SSLCOMMERZ transaction ID), createdAt

events/{eventId}/premium
  - isPremium, plan ("unlimited_guests" | "extra_storage" | "hd_gallery" | "bundle"), purchasedAt,
    sslcommerzTranId, unlockedFeatures: [string]
```

> `qrToken` must be generated server-side (Cloud Function) using a cryptographically random value — never a predictable ID like the guest's document ID or an incrementing number. See Rules.md §4.

## 5. App Flow (Primary User Journeys)

**Host journey:**
`Register/Login → Host Dashboard → Create Event → Add Guests → Generate & Send Invitations → (day of) Scan QR to Check In → View Gift Wallet → Optionally Purchase Premium → Upload Memories`

> Vendor discovery/directory has been removed from scope (see PRD.md) — it is not part of any user journey.

**Guest journey:**
`Receive invitation link/WhatsApp message → Guest Portal OTP Login → View Invitation → RSVP → View/Download QR → Optionally Send Wedding Gift (SSLCOMMERZ sandbox checkout) → (day of) Present QR at check-in → Browse Memories post-event`

## 6. Navigation Structure (go_router, high level)

```
/login
/register
/otp
/reset-password
/dashboard                 (Unified dashboard with Hosting / Attending tabs)
/event/create
/event/:eventId
/event/:eventId/checklist
/event/:eventId/budget
/event/:eventId/guests
/event/:eventId/guests/add
/event/:eventId/invitations
/checkin/:eventId          (QR scanner)
/event/:eventId/memories
/event/:eventId/gifts              (host — wallet + transaction history)
/premium/:eventId                  (host — paywall)
/profile

# Invites and attending interactions are accessed from the unified /dashboard
/guest/invitation/:invitationId
/guest/rsvp/:invitationId
/guest/gift/:invitationId           (send a wedding gift)
```

Route guards: unauthenticated users are redirected to `/login`. Host-only routes (e.g., `/event/:eventId/budget`) check that the requesting user's `userId` matches the event's `hostId`. All authenticated users are directed to `/dashboard` as their home.

## 7. State Management Convention

- One `Notifier`/`AsyncNotifier` (Riverpod) per feature-level concern (e.g., `EventNotifier`, `GuestListNotifier`).
- Screens are `ConsumerWidget` or `ConsumerStatefulWidget`; they `ref.watch` state and call notifier methods — no direct repository calls from widgets.
- Loading/error/data states are represented with `AsyncValue` and handled with `.when(data:, loading:, error:)` in the UI — no manual boolean `isLoading` flags scattered across widgets.

## 8. Environment & Config

- Firebase project has **at minimum** two environments: `dev` and `prod` (flavors), to avoid testing against live user data.
- A single GCS bucket is sufficient for coursework (e.g., `munasabat-dev-media`); no need to over-engineer multiple buckets per environment unless it becomes a problem.
- No API keys, service account files, or secrets are ever committed to the repo. Use `.gitignore` for `google-services.json` / `GoogleService-Info.plist` and any GCS/SSLCOMMERZ service-account or credential files if the repo is public, or document that they're intentionally included for a private repo.

## 9. Storage (Google Cloud Storage) Integration

- **Bucket access model:** the Flutter client never holds GCS credentials. All uploads/downloads go through a signed URL:
  1. Client calls a Cloud Function (`getUploadUrl`) with the target path (e.g., `events/{eventId}/cover.jpg`) and its Firebase Auth ID token.
  2. The function checks the caller is allowed to write there (e.g., is the event's host), then returns a short-lived (e.g., 15 min) v4 signed URL.
  3. Client performs an HTTP `PUT` of the file bytes directly to that signed URL (no Firebase/GCS SDK needed client-side beyond `http`).
- **Reads for public content** (cover images, `Public`-privacy galleries): served as a plain public object URL — no signed URL needed, since it's meant to be publicly viewable.
- **Reads for private content** (`Private (Guests Only)` galleries): the client requests a `getDownloadUrl` Cloud Function call, which checks the requester is an invited guest/host of that event before minting a short-lived signed read URL. This is the GCS-equivalent of what Firebase Storage Security Rules would have done declaratively.
- **Coursework-appropriate simplification:** this signed-URL pattern is intentionally the minimum needed to keep "Private" galleries actually private without Firebase Storage's rules engine. If grading/scope allows, an even simpler fallback (all objects public, relying only on unguessable paths) could be used instead — but that would weaken the Privacy requirement in `PRD.md` §7, so don't switch to it without updating that requirement first.

## 10. Payment Gateway (Sandbox) Integration — SSLCOMMERZ

Wedding Gifts and Premium Feature purchases share one payment integration.

- **Mode:** Sandbox only for this entire build. SSLCOMMERZ's sandbox store ID/password (from `https://developer.sslcommerz.com`) are used everywhere (dev and any demo/staging environment). No live merchant credentials are introduced until a dedicated go-live phase is explicitly scoped and approved.
- **Flow:** SSLCOMMERZ is not an embedded payment-sheet SDK — it's a hosted checkout page.
  1. Client asks a Cloud Function (`createGiftSession` / `createPremiumSession`) to initiate a transaction, passing amount/currency and a `tran_id` the function generates.
  2. The function calls SSLCOMMERZ's Session API (sandbox endpoint) and gets back a `GatewayPageURL`.
  3. The client opens that URL in a `webview_flutter` view. The guest/host completes payment on SSLCOMMERZ's own hosted page (their sandbox test card/mobile-banking credentials) — the app never sees or handles card data.
  4. SSLCOMMERZ redirects to configured success/fail/cancel URLs and, separately, calls the app's IPN (Instant Payment Notification) endpoint — a Cloud Function (`sslcommerzIpnHandler`).
  5. `sslcommerzIpnHandler` validates the notification against SSLCOMMERZ's Validation API and is the **only** place that marks a gift/premium purchase as `succeeded` in Firestore. The WebView's success redirect is just a UX signal to close the WebView — it is never trusted on its own to mark payment success.
- **Test data:** Use SSLCOMMERZ's published sandbox test credentials/cards (documented on their developer site) during development and QA. Document any specific test scenarios exercised (success, failure, cancel) in `Memory.md`.
- **Anonymous gifts:** `isAnonymous` only affects what the host's UI displays (`displayName` is nulled out there) — the underlying `senderId` and `sslcommerzTranId` are always retained server-side for support, refunds, and reconciliation.
- **Environment separation:** Sandbox store credentials live in Cloud Functions config (e.g., Firebase Functions config or environment variables), never in the Flutter client and never committed to source control.
