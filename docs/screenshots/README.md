# Capturas de features

## macOS nativo (no Catalyst)

La misma base de código corre nativa en macOS 15+ con Liquid Glass en macOS 26.
Los pills de marca y el chip "Ver más" funcionan igual que en iOS.

![macOS nativo — pills + Ver más](14-macOS-nativo.png)

### "Ver más" expandido (12 marcas) en macOS
![macOS Ver más](15-macOS-vermas.png)


Capturas reales del simulador (iPhone 16) generadas por
`MaximusPrecisionUITests/ScreenshotTests.swift`.

## Catálogo de vehículos (SwiftData + LRU cache)

### Pills de marca / modelo
![Pills marca/modelo](06-Pills-marca-modelo.png)

### "Ver más" — lista completa de marcas (12)
![Ver más marcas](13-Ver-mas-marcas.png)

### Versión opcional (sheet)
![Versión opcional](07-Version-sheet.png)

### Año (picker)
![Year picker](08-Year-picker.png)

### Año fuera de rango — "Más de 10 años" (entrada manual)
![Year manual](16-Year-manual.png)

### Cotización con marca/modelo elegidos
![Cotización](01-Cotizacion.png)

## IVA, comisión por tarjeta y tipo de documento

### IVA 16%
![IVA 16%](02-IVA-16.png)

### Comisión por tarjeta 4.5%
![Comisión tarjeta](03-Comision-tarjeta.png)

### Nota de remisión
![Nota de remisión](04-Nota-de-remision.png)

### PDF generado
![PDF generado](05-PDF-generado.png)

## Expedientes: clientes y autos (SwiftData)

El **auto es el paciente** (entidad central con su historial); el **cliente es
quien paga** (no exclusivo, puede transferirse el auto). Las cotizaciones se
guardan como servicios en el expediente del auto.

### Clientes
![Clientes](09-Clientes.png)

### Autos (pacientes)
![Autos](10-Autos.png)

### Expediente del auto (pagadores + historial)
![Expediente del auto](11-Expediente-auto.png)

### Búsqueda en el tab bar (Liquid Glass, iOS 26)
![Búsqueda glass en tab bar](12-Busqueda-tab-glass.png)
