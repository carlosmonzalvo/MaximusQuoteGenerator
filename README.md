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

## Qué hace la app

- Formulario de cliente y vehículo
- Lista dinámica de refacciones y mano de obra
- Plantillas rápidas para conceptos frecuentes
- Generación y vista previa de PDF
- Compartir PDF por WhatsApp o cualquier app del share sheet
