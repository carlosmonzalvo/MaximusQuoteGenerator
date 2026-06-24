import Foundation

struct Quote: Codable {
    var folio: String
    var date: Date
    var documentType: DocumentType = .quote
    var customer: Customer
    var vehicle: Vehicle
    var items: [QuoteItem]
    var notes: String
    var includesIVA: Bool = false
    var includesCardFee: Bool = false

    var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }

    var ivaAmount: Double {
        includesIVA ? subtotal * QuoteCalculatorService.ivaRate : 0
    }

    /// Card surcharge is charged on the amount run through the terminal
    /// (subtotal + IVA).
    var cardFeeAmount: Double {
        includesCardFee ? (subtotal + ivaAmount) * QuoteCalculatorService.cardFeeRate : 0
    }

    var total: Double {
        subtotal + ivaAmount + cardFeeAmount
    }
}
