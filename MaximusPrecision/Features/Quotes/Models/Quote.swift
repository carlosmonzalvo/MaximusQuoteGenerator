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
    var includesCashDiscount: Bool = false
    /// Configurable cash-discount rate (default 16%, i.e. the IVA).
    var cashDiscountRate: Double = QuoteCalculatorService.defaultCashDiscountRate

    var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }

    var ivaAmount: Double {
        includesIVA ? subtotal * QuoteCalculatorService.ivaRate : 0
    }

    /// Cash discount on the subtotal at the configured rate.
    var cashDiscountAmount: Double {
        includesCashDiscount ? subtotal * cashDiscountRate : 0
    }

    var total: Double {
        subtotal + ivaAmount - cashDiscountAmount
    }
}
