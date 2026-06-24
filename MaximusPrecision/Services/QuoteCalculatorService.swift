import Foundation

final class QuoteCalculatorService {
    /// IVA (Mexican VAT) rate applied on the subtotal.
    static let ivaRate = 0.16
    /// Surcharge applied when the customer pays by card. Charged on the amount
    /// actually run through the terminal (subtotal + IVA).
    static let cardFeeRate = 0.045

    func subtotal(items: [QuoteItem]) -> Double {
        items.reduce(0) { $0 + $1.total }
    }

    func iva(subtotal: Double, enabled: Bool) -> Double {
        enabled ? subtotal * Self.ivaRate : 0
    }

    /// `base` should be subtotal + IVA so the surcharge covers the whole charge.
    func cardFee(base: Double, enabled: Bool) -> Double {
        enabled ? base * Self.cardFeeRate : 0
    }
}
