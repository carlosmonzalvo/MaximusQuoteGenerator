import Foundation

struct QuoteTemplate: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let type: QuoteItemType
}

let defaultTemplates: [QuoteTemplate] = [
    .init(
        title: "Cambio de balatas delanteras",
        detail: "Incluye desmontaje, instalación y revisión general del sistema de frenos.",
        type: .labor
    ),
    .init(
        title: "Rectificado de discos",
        detail: "Rectificado de discos para corregir superficie de frenado y mejorar el contacto.",
        type: .labor
    ),
    .init(
        title: "Aceite de motor",
        detail: "Suministro de aceite de motor según especificación del vehículo.",
        type: .part
    ),
    .init(
        title: "Filtro de aceite",
        detail: "Reemplazo de filtro de aceite nuevo.",
        type: .part
    ),
    .init(
        title: "Cambio de bujías",
        detail: "Desmontaje e instalación de bujías nuevas con revisión de sistema de encendido.",
        type: .labor
    ),
    .init(
        title: "Limpieza de inyectores",
        detail: "Lavado de inyectores con ultrasonido y prueba en laboratorio.",
        type: .labor
    )
]
