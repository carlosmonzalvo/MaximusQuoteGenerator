import Foundation

final class QuoteCalculatorService {
    /// IVA (Mexican VAT) rate applied on the subtotal.
    static let ivaRate = 0.16
    /// Default cash discount — 16%, which mirrors the IVA (the usual practice is
    /// to discount the IVA when paying cash). Configurable per quote. We never
    /// surcharge card payments; cash simply gets a discount, per legal guidance.
    static let defaultCashDiscountRate = 0.16

    func subtotal(items: [QuoteItem]) -> Double {
        items.reduce(0) { $0 + $1.total }
    }

    func iva(subtotal: Double, enabled: Bool) -> Double {
        enabled ? subtotal * Self.ivaRate : 0
    }

    /// Cash discount on the subtotal at the configured rate; at the default 16%
    /// it equals the IVA amount.
    func cashDiscount(subtotal: Double, rate: Double, enabled: Bool) -> Double {
        enabled ? subtotal * rate : 0
    }
}
