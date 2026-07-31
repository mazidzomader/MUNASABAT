# Rules.md — AI Agent Operating Rules for Munasabat

These rules govern **how** the AI agent builds Munasabat. They take precedence over the agent's own default preferences. If a rule here conflicts with a request in chat, the agent should flag the conflict rather than silently choosing one side.

## 1. Source of Truth

- `PRD.md` defines **what** to build. `Architecture.md` defines **how it's structured**. `Phases.md` defines **the order**. This file defines **the constraints**. `Design.md` defines **how it looks**. `Memory.md` tracks **what's already done**.
- Before starting any task, the agent must check `Memory.md` for current phase and prior decisions. Do not re-derive architecture decisions that are already made — follow them.
- If a request conflicts with `PRD.md`/`Architecture.md`, the agent must point out the conflict and ask before proceeding, rather than silently deviating.

## 2. Libraries & Packages

**Use (approved):**
`flutter_riverpod`, `go_router`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging`, `qr_flutter`, `mobile_scanner`, `table_calendar`, `image_picker`, `url_launcher`, `pdf`, `printing`, `intl`, `cached_network_image`, `flutter_dotenv`, `http` (for uploads/downloads against GCS signed URLs), `webview_flutter` (for SSLCOMMERZ hosted checkout, sandbox mode only — see Rules.md §11).

Server-side (Cloud Functions) additionally uses `@google-cloud/storage` (Node.js) to mint signed URLs and SSLCOMMERZ's REST API (no dedicated Node SDK required — plain HTTPS calls per their sandbox API docs).

**Do not use without explicit approval first:**
- Any second state-management library (no mixing Provider/Bloc/GetX with Riverpod).
- Any second navigation library (no mixing Navigator 1.0 imperative routes with go_router across the app).
- Any paid/commercial SDK.
- Any package that hasn't been updated in 2+ years or has known unresolved critical issues.

**Rule:** If a needed capability has no approved package, propose one option with a one-line justification and wait for confirmation before adding it to `pubspec.yaml`.

## 3. Code Style & Structure

- Follow the folder structure in `Architecture.md` exactly. Do not invent new top-level folders under `lib/` without updating `Architecture.md`.
- One class per file; file name matches the class name in `snake_case`.
- Widgets that exceed ~200 lines should be split into smaller private widgets or moved to `widgets/`.
- No business logic inside widget `build()` methods beyond simple conditional rendering — logic belongs in providers/repositories.
- All public methods/classes get a short doc comment (`///`) explaining purpose, especially in `repositories/` and `services/`.
- Use `const` constructors wherever possible.

## 4. Security Rules (non-negotiable)

- Guest QR tokens must be server-generated, cryptographically random, and unique per guest+event — never derived from a predictable ID or timestamp.
- Firestore Security Rules must enforce:
  - A host can only read/write their own `events/*` documents and subcollections.
  - A guest can only read the invitation/guest documents tied to their own `userId`.
  - No user may modify another user's `users/*` document, and no host may edit or delete another host's event.
  - Nobody can write directly to another guest's `status` field from the client — check-in must go through a Cloud Function that validates the QR token server-side.
  - Nobody can write `paymentStatus: "succeeded"` on a gift or premium document directly from the client — only the server-side SSLCOMMERZ IPN handler (via the Admin SDK) may set that field.
- Since file storage is plain GCS (not Firebase Storage), it has no declarative rules layer — access control for uploads and for reads of **private** content must be enforced by the Cloud Functions that mint signed URLs (checking the caller's role/invite status before signing), not left to "the object path is hard to guess."
- Never log or print QR tokens, phone numbers, OTP codes, or GCS signed URLs to console in production builds.
- Passwords are never stored or handled outside Firebase Auth's own flow.

## 5. Error Handling

- Every async call (network, Firebase) must be wrapped so failures produce a user-facing message, not a crash or a silent no-op.
- Use `AsyncValue.guard` (Riverpod) or try/catch in repositories; surface errors to the UI through the `AsyncValue.error` state, shown via a shared error widget (`core/widgets/`).
- Never swallow exceptions silently (`catch (e) {}` with nothing in the body is not allowed).
- User-facing error text must be plain language ("Couldn't load your guest list. Pull down to try again.") — not raw exception text or stack traces.
- Network/timeouts must have a retry affordance (button or pull-to-refresh), not just a dead-end error screen.

## 6. Data & Privacy

- Private galleries must never be readable by unauthenticated or non-invited users — enforced both at the Firestore Security Rules level (who can query the `memories` metadata) and at the GCS signed-URL level (who can get a download URL for the actual media file), not just in UI logic.
- Do not add analytics/tracking SDKs unless explicitly requested.
- Do not hardcode any real phone numbers, emails, or personal data in sample/seed data — use clearly fake placeholder data (e.g., `+000000000`, `test@example.com`).

## 7. Testing & Validation

- Each phase in `Phases.md` must be manually runnable/demoable before moving to the next phase — do not stack unverified phases.
- Widget/unit tests are encouraged for repository logic and Cloud Functions (QR validation, RSVP status transitions) but are not a blocker for MVP phases unless a phase explicitly says so.
- Before marking a phase complete, the agent must update `Memory.md` (see that file's instructions).

## 8. What the Agent Should Do

- Ask before making an architectural decision not already covered in `Architecture.md`.
- Keep changes scoped to the current phase in `Phases.md` — do not jump ahead and build unrelated features "while in there."
- Flag any place where a feature in `PRD.md` seems technically risky or ambiguous, rather than guessing silently.
- Keep `Memory.md` updated at the end of each work session/phase.
- Prefer editing existing files over creating parallel/duplicate versions of a screen or model.

## 9. What the Agent Should NOT Do

- Do not introduce a second backend (e.g., a custom REST API) alongside Firebase without explicit approval — this is a Firebase-first architecture.
- Do not commit secrets, API keys, or service account JSON files with real credentials into any file the user will publish publicly.
- Do not silently rename established route names, model field names, or collection names — these are shared contracts with `Architecture.md`; propose the change there first.
- Do not add mock/fake data paths that silently replace real Firebase calls "to make progress" without clearly flagging it as temporary/mock in code comments and in `Memory.md`.
- Do not implement any real/live payment flow — payments in this build are sandbox mode only, per `Rules.md` §11 and `Architecture.md` §10.
- Do not build any vendor directory, vendor profiles, or vendor management tooling — this feature has been removed from scope entirely.
- Do not build any admin role, admin dashboard, or platform-moderation tooling — this feature has been removed from scope entirely. There are only two roles: `host` and `guest`.

## 10. Communication Style Expected From the Agent

- Before a phase: briefly state what will be built and which files will be touched.
- After a phase: summarize what changed, what to test manually, and update `Memory.md`.
- If blocked (missing Firebase config, ambiguous requirement), stop and ask rather than guessing and building on a bad assumption.

## 11. Payments (Sandbox Mode) — Wedding Gifts & Premium Features

These rules are non-negotiable and apply to both the Wedding Gifts feature and the Premium Features purchase flow, since they share one payment integration.

- **Sandbox only, always:** Every payment call in this project uses the payment provider's test/sandbox API keys and test card numbers. There is no code path in this build that can charge a real card. If a task ever seems to require live keys, stop and ask — do not add them.
- **No client-trusted success states:** The app may show an optimistic "processing" state, but a gift or premium purchase is only ever marked `succeeded` in Firestore by the server-side webhook handler, never by the client after the payment sheet closes.
- **No raw card handling:** The Flutter app must use the payment provider's hosted UI/SDK (e.g., Stripe's PaymentSheet) — it must never collect, transmit, or store raw card numbers, CVVs, or expiry dates itself.
- **No local secret keys:** Secret/server-side API keys live only in Cloud Functions config (or a secrets manager), never bundled into the Flutter client or committed to source control — only the publishable/test key belongs in the client.
- **Anonymous gifts stay traceable:** An anonymous gift hides the sender's name in the host-facing UI only. The underlying sender ID and payment record are always retained server-side; the agent must not build "true anonymity" that would make a transaction unrecoverable for support/refund purposes.
- **Idempotency:** Payment-confirmation Cloud Functions (webhook handlers) must be idempotent — a retried webhook delivery must not double-count a gift or double-unlock premium.
- **Clear sandbox labeling:** Any payment screen shown during development/testing should make it obvious it's a test transaction (e.g., a visible "Test Mode" label or use of Stripe's own test-mode UI, which already indicates this) so nobody mistakes a demo for a real charge.
- **Money is stored as integers in the smallest currency unit** (e.g., cents), never as floats, to avoid rounding bugs in totals/wallets.
