# Task — Step Wizard Form + PDF redesign

**Repo:** `https://github.com/carlosmonzalvo/MaximusQuoteGenerator`
**Branch base:** `feat/wireframe-design`
**Language:** Swift / SwiftUI, iOS 17+

---

## Context

The app is an iOS quote generator for an auto repair shop. It currently has a single-scroll form (`QuoteFormView.swift`) with all fields stacked. We want to replace it with a **multi-step wizard** so it feels less cluttered.

The design system is already set up in `UIApplication+Extensions.swift`:
- `MXTheme.bg` → `#0d0d0d`, `MXTheme.accent` → `#e8c84a` (gold), `MXTheme.header` → `#111111`
- `MXTheme.partBlue` → `#7ab8e8`, `MXTheme.laborGreen` → `#6dcf6d`
- `Color(hex:)` extension available

---

## What to build

### 1. Step Wizard replacing the scroll form

Replace the current `QuoteFormView` body with a **3-step horizontal pager**. Users swipe left/right or tap Next/Back to move between steps. Steps:

| Step | Content |
|------|---------|
| 1 — Cliente | Nombre + Teléfono |
| 2 — Vehículo | Marca, Modelo, Año, Placas (2×2 grid) |
| 3 — Conceptos | Template chips + item cards + Notes field |

Use `TabView` with `.tabViewStyle(.page(indexDisplayMode: .never))` for swipe-between-steps behavior.

### 2. Progress bar

At the top of the screen (below the Dynamic Island safe area), show a thin segmented progress bar:
- 3 segments, one per step
- Completed/current segment: `MXTheme.accent` (gold `#e8c84a`)
- Pending segments: `MXTheme.border` (`#2a2a2a`)
- Height: 3pt, full width with 16pt horizontal padding, 8pt corner radius per segment
- Animates with `.animation(.easeInOut(duration: 0.25))`

Above the bar, show step label e.g. `"Paso 1 de 3 — Cliente"` in `MXTheme.muted`, 12pt.

### 3. Navigation buttons

- **Back** (steps 2–3): text button `"← Atrás"` in `MXTheme.muted`, top-left
- **Next** (steps 1–2): filled gold button `"Siguiente →"` at the bottom, same style as the existing bottom bar button
- **Step 3 bottom bar**: keep the existing total bar (total + "Generar PDF →" button)

Validation before advancing:
- Step 1 → requires `customerName` non-empty
- Step 2 → requires `vehicleBrand` and `vehicleModel` non-empty
- Step 3 → at least 1 item

Show inline error text in `MXTheme.accent` (not an alert) if validation fails on Next tap.

### 4. PDF visual redesign

Update `PDFGeneratorService.swift` to produce a cleaner document:

- **Header**: Left = "MAXIMUS PRECISION" bold 16pt + "Taller Automotriz" gray 9pt. Right = folio `#COT-XXXX` bold 13pt + date 9pt. Separated by a 2pt black rule full-width.
- **Client/vehicle block**: two-column layout (label uppercase gray 8pt + value 11pt)
- **Items table**: columns `Descripción | Cant | P.Unit | Total`. Header row uppercase gray 8pt. Each row 11pt, alternating row backgrounds (`#f9f9f9` / white). Left colored dot (blue = part, green = labor) before description.
- **Totals block**: right-aligned, subtotal parts + subtotal labor + `TOTAL` 14pt bold with 2pt top rule.
- **Footer**: centered, 8pt gray: `"Esta cotización tiene vigencia de 15 días"`
- Keep `logo_maximus` watermark at 8% opacity centered on page.

---

## Files to modify

- `MaximusPrecision/Features/Quotes/Views/QuoteFormView.swift` — replace form with wizard
- `MaximusPrecision/Services/PDFGeneratorService.swift` — redesign PDF layout

Do **not** touch `MXTheme`, `SplashView`, `PDFPreviewView`, models, or the ViewModel.

---

## Delivery

Work on a new branch off `feat/wireframe-design` and open a PR back to that branch when done.
