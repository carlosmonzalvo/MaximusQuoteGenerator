import Foundation

enum QuoteItemType: String, CaseIterable, Codable {
    case part = "Refacción"
    case labor = "Mano de obra"
}

struct QuoteItem: Identifiable, Codable {
    let id: UUID
    var type: QuoteItemType
    var title: String
    var detail: String
    var quantity: Double
    var unitPrice: Double

    var total: Double {
        quantity * unitPrice
    }

    init(
        id: UUID = UUID(),
        type: QuoteItemType,
        title: String = "",
        detail: String = "",
        quantity: Double = 1,
        unitPrice: Double = 0
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}
