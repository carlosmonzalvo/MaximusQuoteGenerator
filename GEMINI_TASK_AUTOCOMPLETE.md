# Task — Vehicle Autocomplete (SwiftData-first, backend-ready)

**Repo:** `https://github.com/carlosmonzalvo/MaximusQuoteGenerator`
**Branch base:** `feat/wireframe-design`
**Language:** Swift / SwiftUI / SwiftData, iOS 17+

---

## Goal

Add smart autocomplete to the Marca and Modelo fields in the quote form.
Architecture is local-first (SwiftData + bundled JSON seed), but the data layer
must be abstracted behind a protocol so it can swap to a REST API later without
touching the UI.

---

## Data model

### Seed file — `Resources/vehicles.json`

Bundle a JSON file with the top ~20 brands sold in Mexico and their most common
models (8–12 per brand, last 10 years). Schema:

```json
[
  {
    "brand": "Nissan",
    "models": ["Versa", "Sentra", "Kicks", "March", "NP300", "X-Trail", "Frontier", "Murano"]
  },
  {
    "brand": "Volkswagen",
    "models": ["Jetta", "Vento", "Tiguan", "Polo", "Golf", "T-Cross", "Taos"]
  }
]
```

Include at minimum: Nissan, Volkswagen, Chevrolet, Toyota, Honda, Hyundai,
Kia, Ford, Mazda, Seat, Suzuki, Dodge, Jeep, RAM, BYD, Chirey, JAC, BAIC,
Renault, Peugeot.

### SwiftData models

```swift
@Model
class VehicleBrand {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade) var models: [VehicleModel]
}

@Model
class VehicleModel {
    @Attribute(.unique) var name: String
    var brand: VehicleBrand
    var usageCount: Int  // increments every time this model is picked — for sorting
}
```

### Seeder service

On first launch, read `vehicles.json` and insert into SwiftData if the store is
empty. Keep it idempotent (safe to call multiple times).

---

## Service layer (protocol-first for future backend swap)

```swift
protocol VehicleRepositoryProtocol {
    func brands(matching query: String) async -> [String]
    func models(for brand: String, matching query: String) async -> [String]
    func recordUsage(brand: String, model: String) async
}
```

Implement `LocalVehicleRepository` backed by SwiftData.
When the backend exists, a `RemoteVehicleRepository` can be dropped in — the UI
never changes.

---

## UI — Autocomplete fields

Replace the plain `MXField` for Marca and Modelo in the wizard step 2 with a
new `MXAutoField` component:

- While typing, show a floating list of up to 5 suggestions below the field
- Suggestions are filtered prefix-first, then fuzzy (e.g. "ver" → "Versa")
- Selecting a suggestion fills the field and dismisses the list
- Selecting a brand clears the model field and pre-loads that brand's models
- Suggestions list uses `MXTheme.surface` background, `MXTheme.border` separator,
  `MXTheme.accent` highlight on the matching prefix characters
- If no suggestions, show nothing (no empty dropdown)

### Sorting logic

Sort suggestions by:
1. Starts-with match first
2. Then `usageCount` descending (most-used floats to top over time)
3. Alphabetical as tiebreaker

---

## Normalization (lightweight, in Swift)

Before storing or querying, run input through a normalizer:

```swift
func normalize(_ input: String) -> String {
    input
        .trimmingCharacters(in: .whitespaces)
        .lowercased()
        .replacingOccurrences(of: #"(\b(sport|sr|limited|trendline|at|mt|plus|pro|max)\b)"#,
                               with: "", options: .regularExpression)
        .trimmingCharacters(in: .whitespaces)
}
```

Store normalized form separately if needed for matching, but display the
original casing to the user.

---

## Files to create / modify

| File | Action |
|------|--------|
| `Resources/vehicles.json` | Create — seed data |
| `Services/VehicleRepository.swift` | Create — protocol + local impl |
| `Services/VehicleSeeder.swift` | Create — seeds SwiftData on first launch |
| `Features/Quotes/Views/MXAutoField.swift` | Create — autocomplete field component |
| `App/MaximusPrecisionApp.swift` | Modify — inject modelContainer + run seeder |
| `Features/Quotes/Views/QuoteFormView.swift` | Modify — swap MXField → MXAutoField for brand/model |

Do **not** touch `MXTheme`, `SplashView`, `PDFPreviewView`, `PDFGeneratorService`,
or any existing model/ViewModel files.

---

## What NOT to build (scope guard)

- No scraping, no confidence scores, no deduplication engine — that's a backend concern
- No generation/trim tracking — model name only
- No network calls — local only for now
- No admin UI to manage the dataset

---

## Delivery

Branch off `feat/wireframe-design`, name it `feat/vehicle-autocomplete`.
Open a PR back to `feat/wireframe-design` when done.
