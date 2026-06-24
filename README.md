# Maximus Precision - Quote Generator

App iOS en SwiftUI para generar cotizaciones de refacciones y mano de obra, con exportación a PDF y share sheet.

---

## Requisitos previos

- macOS 13 o superior
- Xcode 15 o superior — descárgalo desde la App Store
- Homebrew — si no lo tienes:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

---

## Setup inicial (hazlo una sola vez)

### 1. Instalar Tuist

```bash
curl -Ls https://install.tuist.io | bash
```

Verifica que quedó bien:

```bash
tuist version
```

### 2. Apuntar Xcode correctamente

```bash
sudo xcode-select -s /Applications/Xcode.app
```

### 3. Clonar el repo

```bash
git clone https://github.com/carlosmonzalvo/MaximusQuoteGenerator.git
cd MaximusQuoteGenerator
```

---

## Abrir el proyecto

**No abras el `.xcodeproj` directamente.** Primero genera el workspace con Tuist:

```bash
tuist generate
```

Luego abre el workspace que se genera:

```bash
open MaximusPrecision.xcworkspace
```

> Si abres el `.xcodeproj` en lugar del `.xcworkspace` las cosas van a tronar. Usa siempre el workspace.

---

## Correr en simulador

1. En Xcode selecciona el scheme `MaximusPrecision`
2. Elige un simulador (iPhone 15 o superior recomendado)
3. `Cmd + R`

---

## Flujo de trabajo diario

Cada vez que jalones cambios o modifiques `Project.swift`:

```bash
tuist generate
```

No hace falta correrlo si solo modificas archivos `.swift` dentro de los targets existentes.

---

## Troubleshooting

**`Couldn't find Xcode's Info.plist`**
```bash
sudo xcode-select -s /Applications/Xcode.app
```

**`tuist: command not found`**
Cierra y vuelve a abrir la terminal, o corre:
```bash
source ~/.zshrc
```

**Build falla con errores de signing**
Habla con Rodolfo, él tiene el team ID configurado. No toques `DEVELOPMENT_TEAM` en el `project.pbxproj`.

---

## Tests de UI (robot pattern)

El target `MaximusPrecisionUITests` maneja los tests de interfaz con el **patrón
Robot**: cada pantalla tiene un `*Robot` que expone acciones de intención
(`fillCustomer`, `tapAddPart`, `tapGenerate`) y oculta los `XCUIElement` de los
test bodies. Los identifiers viven en `AccessibilityIdentifiers.swift`,
compilado en la app **y** en el bundle de tests para que nunca se desincronicen.

Correr los tests:

```bash
xcodebuild test -scheme MaximusPrecision \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Estructura:

- `Support/Robot.swift` — base con `tap`, `type`, `assertExists`, `element(id:)`
- `Support/XCUIApplication+Maximus.swift` — `launchForTesting()` (salta el splash)
- `Robots/` — `QuoteFormRobot`, `ItemEditRobot`, `PDFPreviewRobot`
- `QuoteFlowUITests.swift` — flujos end-to-end

La app entiende el launch argument `-uiTesting` (ver `LaunchArgument`) para
arrancar determinista y sin el splash de 2s.

> El target se generó con `scripts/add_uitests_target.rb` (gem `xcodeproj`). Es
> idempotente: re-córrelo si agregas archivos de test nuevos.

## Tests unitarios

El target `MaximusPrecisionTests` (hosteado en la app, `@testable import`) cubre
la lógica pura: el `LRUCache` y el `VehicleCatalog` (seeding, orden, cache).
Se generó con `scripts/add_unittests_target.rb`. Corren junto con los de UI en
el mismo `xcodebuild test`.

## Catálogo de vehículos (SwiftData + LRU cache)

- `Catalog/CatalogModels.swift` — entidades SwiftData `CatalogMake` / `CatalogModel`
  (con `trims`/versiones opcionales).
- `Catalog/VehicleCatalogSeed.swift` — catálogo curado de marcas/modelos comunes
  en México (2015+), organizado por **tiers** para crecer incrementalmente
  (tier 1 = top 3 marcas; agregar las siguientes 3 = sumar tier 2).
- `Catalog/VehicleCatalog.swift` — seeding idempotente + lookups con `LRUCache`.
- `Catalog/AppModelContainer.swift` — contenedor compartido del proceso (in-memory
  bajo tests).

En el formulario: la marca y el modelo se eligen con **pills**; la **versión/trim
es opcional** y se elige en un sheet rápido.

## Qué hace la app

- Formulario de cliente y vehículo (con catálogo de marcas/modelos)
- Lista dinámica de refacciones y mano de obra
- Plantillas rápidas para conceptos frecuentes
- IVA 16% y comisión por tarjeta 4.5% opcionales
- Cotización / Nota de remisión
- Generación y vista previa de PDF
- Compartir PDF por WhatsApp o cualquier app del share sheet
