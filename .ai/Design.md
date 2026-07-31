# Design.md — Visual Design System for Munasabat

This defines the visual language the agent must use for every screen. "Munasabat" (مناسبات, Arabic for "occasions/events") suggests a warm, celebratory, elegant tone — not a generic corporate/utility app. The palette below leans into a warm gold + deep rose/plum wedding aesthetic, with a clean neutral base so content (photos, guest lists) stays legible.

## 1. Brand Personality

- Elegant, warm, celebratory — but calm and readable, not "loud."
- Feels premium (like a wedding invitation), not like a generic to-do app.
- Prioritizes clarity for functional screens (guest lists, check-in) over decoration — decoration lives in invitations, dashboard headers, and empty states.

## 2. Color Palette

### Primary
| Token | Hex | Usage |
|---|---|---|
| `primaryGold` | `#C9A24B` | Primary brand color — buttons, active nav icons, highlights, QR frame accents |
| `primaryGoldDark` | `#A9822F` | Pressed states, primary text-on-gold contrast checks |
| `deepRose` | `#7A2E3B` | Secondary brand accent — headers, invitation accents, key CTAs alongside gold |

### Neutrals
| Token | Hex | Usage |
|---|---|---|
| `ink` | `#1F1B16` | Primary text |
| `charcoal` | `#4A4540` | Secondary text |
| `stone` | `#8C857C` | Tertiary text, placeholders, disabled |
| `cream` | `#FBF7F0` | App background (warm off-white, not stark white) |
| `surface` | `#FFFFFF` | Cards, sheets, elevated surfaces |
| `divider` | `#E8E1D4` | Borders, dividers |

### Status
| Token | Hex | Usage |
|---|---|---|
| `statusPending` | `#B8860B` (amber-gold) | Invitation "Pending" |
| `statusAccepted` | `#2E7D4F` | "Accepted" / success states |
| `statusDeclined` | `#B23A3A` | "Declined" / error states |
| `statusCheckedIn` | `#2E5E8C` | "Checked In" |

> Reuse `statusAccepted` / `statusDeclined` for payment outcomes (gift succeeded/failed, premium unlocked/purchase failed) rather than introducing new colors — keeps the status vocabulary consistent across the app.

### Dark Mode (optional, later phase)
Dark mode is not required for MVP but the theme should be structured (ColorScheme-based) so it can be added later without a full rewrite — do not hardcode raw hex colors directly in widgets; always reference theme tokens.

## 3. Typography

- **Headings:** `Playfair Display` (serif, elegant — used for wedding-facing/celebratory screens: invitation preview, event title, dashboard greeting header)
- **Body/UI:** `Inter` or `Poppins` (clean sans-serif — used everywhere else: forms, lists, buttons, admin screens)

| Style | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `displayLarge` | Playfair Display | 32 | 700 | Invitation title, event hero title |
| `headlineMedium` | Playfair Display | 24 | 600 | Section headers (e.g., "Your Wedding", "Memories") |
| `titleLarge` | Inter/Poppins | 20 | 600 | Screen titles (Guests, Vendors, Profile) |
| `titleMedium` | Inter/Poppins | 16 | 600 | Card titles, list item titles |
| `bodyLarge` | Inter/Poppins | 16 | 400 | Primary body text |
| `bodyMedium` | Inter/Poppins | 14 | 400 | Secondary body text, descriptions |
| `labelSmall` | Inter/Poppins | 12 | 500 | Badges, status chips, captions |

Both fonts must be bundled via `pubspec.yaml` (Google Fonts, self-hosted for reliability rather than a runtime `google_fonts` network fetch, to avoid first-load flicker/failure).

## 4. Spacing & Layout

- Base spacing unit: **4px**. Use multiples: 4, 8, 12, 16, 24, 32, 48.
- Screen horizontal padding: **16px** default, **24px** on tablet-width breakpoints.
- Card corner radius: **16px** (soft, elegant — not sharp corporate corners).
- Button corner radius: **12px**.
- Input field corner radius: **10px**.
- Minimum tap target: **48x48px**.

## 5. Components

- **Primary Button:** filled `primaryGold` background, `ink` or white text (whichever passes contrast), 12px radius, medium elevation on press only (no heavy shadow at rest).
- **Secondary Button:** outlined, `deepRose` or `primaryGold` border, transparent fill.
- **Status Chips:** pill-shaped, colored per status token table above, `labelSmall` text, white or ink text depending on contrast.
- **Cards:** `surface` background, `divider`-colored 1px border or subtle shadow (not both), 16px radius, 16px internal padding.
- **QR Display:** framed in a card with a thin `primaryGold` border, generous white padding around the QR itself (QR codes need quiet space to scan reliably) — never place a QR directly on a busy/colored background.
- **Gift Card (transaction list item):** `surface` card, 16px radius; sender name (or "Anonymous Well-Wisher" in `stone` italic when hidden) + amount in `titleMedium` + optional message in `bodyMedium`, timestamp in `labelSmall`. Amount rendered in `deepRose` or `primaryGoldDark` to feel celebratory, not like a cold banking app.
- **Wallet Summary Card (host):** larger hero-style card at the top of the gifts screen — total received in `displayLarge`-scale numerals (but sans-serif, not Playfair, since it's a number not a heading), gift count as a `labelSmall` subtitle. A visible "Sandbox / Test Mode" tag on this card during development so hosts testing the feature never mistake it for real funds.
- **Premium Paywall:** uses `deepRose` as the dominant accent (distinct from the everyday `primaryGold` UI) so it reads as a distinct, special screen — feature list with lock icons that switch to check icons once unlocked, single clear primary CTA button.
- **Premium Lock Badge:** small pill or icon badge (`primaryGold` outline, lock icon) overlaid on gated features (e.g., a locked "Add Guest" button once the free cap is hit) so restriction is clear without a jarring popup on every tap.
- **Empty States:** illustration or icon in `stone`/`primaryGold`, short friendly headline (Playfair Display), one-line body text (Inter), optional CTA button.
- **Loading States:** use skeleton loaders for lists (guest list, vendor list, gallery) rather than a single centered spinner, where feasible.

## 6. Iconography

- Use a single consistent icon set throughout (`Material Symbols` or `Phosphor Icons` — pick one and do not mix sets).
- Icons should be line-style by default, filled only for active/selected states (e.g., active bottom nav tab).

## 7. Imagery

- Cover images / gallery photos always rendered with **16px corner radius** and `cached_network_image` with a shimmer/placeholder while loading.
- Gallery grid: consistent aspect ratio (square or 4:5) — do not let mixed aspect ratios create a messy grid.

## 8. Motion

- Keep transitions subtle: standard `go_router` page transitions (platform default) are acceptable for MVP.
- Reserve custom animation for: QR scan success (a brief check-mark/confetti micro-animation), RSVP confirmation, checklist item completion (subtle strike-through/fade).
- Avoid gratuitous animation on data-heavy screens (guest list, admin dashboard) — keep those snappy and utilitarian.

## 9. Accessibility

- Minimum text contrast ratio: 4.5:1 for body text against its background.
- All interactive elements must have a minimum 48x48px tap area even if the visible icon/text is smaller.
- Status must never be conveyed by color alone (e.g., status chips always include text label, not just a colored dot) — important for the four invitation statuses.

## 10. Theming Implementation Note (for the agent)

- Define all of the above as a single `AppColors` class and `AppTextStyles` class under `core/theme/`, then wire them into a Flutter `ThemeData`/`ColorScheme` in `core/theme/theme_data.dart`.
- Widgets must reference `Theme.of(context)` / `AppColors.*` — never hardcode hex values inline in a widget file. This is required so a future dark mode or rebrand doesn't require touching every screen.
