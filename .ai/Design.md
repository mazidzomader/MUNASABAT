# Design.md — Visual Design System for Munasabat

This defines the visual language the agent must use for every screen. "Munasabat" (مناسبات, Arabic for "occasions/events") suggests a warm, celebratory, elegant tone — not a generic corporate/utility app.

> **Source of truth:** the official hero banner (`Munasabat_Hero_Banner.png`). All hex values below were sampled directly from that asset, not estimated. The banner sets the brand palette: a soft **watercolor blue-to-pink wash** framing a clean white/cream center, with a **deep brown wordmark** as the identity anchor. This replaces any earlier gold/rose "wedding invitation" palette — that direction is deprecated. Every screen should feel like it could sit inside that banner: airy, mostly neutral, with color used as an accent, not a fill.

## 1. Brand Personality

- Elegant, warm, celebratory — but calm and readable, not "loud."
- Feels premium (like a wedding invitation), not like a generic to-do app.
- Color is used the way the hero banner uses it: **soft, diffuse, concentrated at the edges/moments of delight** (hero headers, empty states, celebrations) — not as flat color fills across functional UI.
- Prioritizes clarity for functional screens (guest lists, check-in) over decoration — decoration lives in invitations, dashboard headers, hero banners, and empty states.

## 2. Color Palette

### Primary / Brand
| Token | Hex | Usage |
|---|---|---|
| `brandInk` | `#371E08` | Wordmark color, primary headings, primary button fill, primary text-on-light |
| `brandInkLight` | `#6B4A2E` | Pressed/hover state for `brandInk`, secondary emphasis text |
| `accentBlue` | `#7BAAFA` | Left-side brand accent (from banner watercolor) — links, info highlights, icons, secondary buttons/outlines |
| `accentBlueSoft` | `#A4E6F6` | Soft blue tint — chip fills, card backgrounds, hover states, decorative wash |
| `accentPink` | `#F99CEC` | Right-side brand accent (from banner watercolor) — celebratory highlights, secondary CTAs, badges |
| `accentPinkSoft` | `#EAC0FF` | Soft pink/orchid tint — chip fills, card backgrounds, hover states, decorative wash |

> Do not treat `accentBlue`/`accentPink` as interchangeable with each other or with `brandInk`. `brandInk` carries the brand (buttons, headings, the logo itself); the two accents are the "watercolor" pair and should generally appear **together** (as a soft gradient or paired highlights) rather than as arbitrary single-color fills, to stay visually tied to the hero banner.

### Neutrals
| Token | Hex | Usage |
|---|---|---|
| `ink` | `#2E2318` | Primary body text (softened `brandInk` for long-form legibility) |
| `charcoal` | `#5C5248` | Secondary text |
| `stone` | `#9B9188` | Tertiary text, placeholders, disabled |
| `cream` | `#FBF9F6` | App background (warm off-white, matches banner's white field) |
| `surface` | `#FFFFFF` | Cards, sheets, elevated surfaces |
| `divider` | `#EFEAE3` | Borders, dividers |

### Status
| Token | Hex | Usage |
|---|---|---|
| `statusPending` | `#B8860B` (amber-gold) | Invitation "Pending" |
| `statusAccepted` | `#2E7D4F` | "Accepted" / success states |
| `statusDeclined` | `#B23A3A` | "Declined" / error states |
| `statusCheckedIn` | `#2E5E8C` | "Checked In" |

> Status colors are semantic and kept independent of the brand watercolor palette so they stay unambiguous (traffic-light logic). Reuse `statusAccepted` / `statusDeclined` for payment outcomes (gift succeeded/failed, premium unlocked/purchase failed) rather than introducing new colors.

### Hero / Decorative Gradient
For hero banners, splash screens, onboarding, and empty-state backgrounds only — mirrors the reference banner exactly:

| Token | Hex stops | Usage |
|---|---|---|
| `gradientBlueWash` | `#9BA7FD → #7BAAFA → #A4E6F6 → transparent` | Top-left / left-edge watercolor bloom |
| `gradientPinkWash` | `#F99CEC → #EAC0FF → #FCD2F6 → transparent` | Top-right / right-edge watercolor bloom |

Usage rule (matches the banner's own composition): keep the **center 60–70% of any hero surface neutral** (`cream`/`surface`, white space for logo, copy, or an illustration) and let the two washes bloom only from the outer corners/edges, fading to transparent. Never let a wash cross behind body text or form fields — legibility comes first. Never use these gradient tokens as a background for functional/data-dense screens (guest list, check-in, admin dashboard); those stay on flat `cream`/`surface`.

### Dark Mode (optional, later phase)
Dark mode is not required for MVP but the theme should be structured (ColorScheme-based) so it can be added later without a full rewrite — do not hardcode raw hex colors directly in widgets; always reference theme tokens.

## 3. Typography

- **Headings:** `Playfair Display` (serif, elegant — used for wedding-facing/celebratory screens: invitation preview, event title, dashboard greeting header)
- **Body/UI:** `Inter` or `Poppins` (clean sans-serif — used everywhere else: forms, lists, buttons, admin screens)

> Note on the logo itself: the wordmark in the hero banner uses a bespoke cursive/calligraphic script (with a serif small-caps tagline underneath). That script is part of the **static logo asset only** — never set live UI text (headings, buttons, body) in a script/cursive font. Playfair Display is the closest "in-spirit" serif that stays legible at UI sizes and is what headings should actually use.

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

- **Primary Button:** filled `brandInk` background, white text, 12px radius, medium elevation on press only (no heavy shadow at rest).
- **Secondary Button:** outlined, `accentBlue` or `accentPink` border, transparent fill, `brandInk` or `ink` text.
- **Status Chips:** pill-shaped, colored per status token table above, `labelSmall` text, white or ink text depending on contrast.
- **Cards:** `surface` background, `divider`-colored 1px border or subtle shadow (not both), 16px radius, 16px internal padding.
- **QR Display:** framed in a card with a thin `brandInk` or `accentBlue` border, generous white padding around the QR itself (QR codes need quiet space to scan reliably) — never place a QR directly on a busy/colored or gradient-wash background.
- **Gift Card (transaction list item):** `surface` card, 16px radius; sender name (or "Anonymous Well-Wisher" in `stone` italic when hidden) + amount in `titleMedium` + optional message in `bodyMedium`, timestamp in `labelSmall`. Amount rendered in `brandInk` or `accentPink` to feel celebratory, not like a cold banking app.
- **Wallet Summary Card (host):** larger hero-style card at the top of the gifts screen — total received in `displayLarge`-scale numerals (but sans-serif, not Playfair, since it's a number not a heading), gift count as a `labelSmall` subtitle. A subtle `gradientBlueWash`/`gradientPinkWash` corner bloom is appropriate here (it's a celebratory hero moment), kept behind the numerals with the center left neutral for legibility. A visible "Sandbox / Test Mode" tag on this card during development so hosts testing the feature never mistake it for real funds.
- **Premium Paywall:** uses `accentPink` (paired with `accentBlue` as a soft corner wash, echoing the hero banner) as the dominant accent — distinct from the everyday `brandInk` UI — so it reads as a distinct, special screen. Feature list with lock icons that switch to check icons once unlocked, single clear primary CTA button (`brandInk` fill).
- **Premium Lock Badge:** small pill or icon badge (`accentBlue` or `brandInk` outline, lock icon) overlaid on gated features (e.g., a locked "Add Guest" button once the free cap is hit) so restriction is clear without a jarring popup on every tap.
- **Empty States:** illustration or icon in `stone`/`accentBlue`/`accentPink`, short friendly headline (Playfair Display), one-line body text (Inter), optional CTA button. A faint corner wash (per Hero/Decorative Gradient rules) is a good fit here.
- **Loading States:** use skeleton loaders for lists (guest list, vendor list, gallery) rather than a single centered spinner, where feasible.

## 6. Iconography

- Use a single consistent icon set throughout (`Material Symbols` or `Phosphor Icons` — pick one and do not mix sets).
- Icons should be line-style by default, filled only for active/selected states (e.g., active bottom nav tab).
- Default icon color is `charcoal` or `brandInk`; use `accentBlue`/`accentPink` only for active/selected or celebratory states, never as the default resting color for utility icons.

## 7. Imagery

- Cover images / gallery photos always rendered with **16px corner radius** and `cached_network_image` with a shimmer/placeholder while loading.
- Gallery grid: consistent aspect ratio (square or 4:5) — do not let mixed aspect ratios create a messy grid.

## 8. Motion

- Keep transitions subtle: standard `go_router` page transitions (platform default) are acceptable for MVP.
- Reserve custom animation for: QR scan success (a brief check-mark/confetti micro-animation), RSVP confirmation, checklist item completion (subtle strike-through/fade).
- Avoid gratuitous animation on data-heavy screens (guest list, admin dashboard) — keep those snappy and utilitarian.

## 9. Accessibility

- Minimum text contrast ratio: 4.5:1 for body text against its background.
- `accentBlue` and `accentPink` are mid-tone pastels — never use them as a text color on `cream`/`surface` at body sizes; they exist for fills, borders, icons, and large/bold display numerals only. Body text stays on `ink`/`charcoal`/`brandInk`.
- All interactive elements must have a minimum 48x48px tap area even if the visible icon/text is smaller.
- Status must never be conveyed by color alone (e.g., status chips always include text label, not just a colored dot) — important for the four invitation statuses.

## 10. Theming Implementation Note (for the agent)

- Define all of the above as a single `AppColors` class and `AppTextStyles` class under `core/theme/`, then wire them into a Flutter `ThemeData`/`ColorScheme` in `core/theme/theme_data.dart`.
- Add the two `LinearGradient`/`RadialGradient` definitions (`gradientBlueWash`, `gradientPinkWash`) as named constants (e.g. `AppGradients.heroBlue`, `AppGradients.heroPink`) so hero/decorative screens pull from one place rather than re-declaring stops inline.
- Widgets must reference `Theme.of(context)` / `AppColors.*` / `AppGradients.*` — never hardcode hex values inline in a widget file. This is required so a future dark mode or rebrand doesn't require touching every screen.