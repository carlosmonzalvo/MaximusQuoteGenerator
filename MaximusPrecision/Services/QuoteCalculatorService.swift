import Foundation

final class QuoteCalculatorService {
    func subtotal(items: [QuoteItem]) -> Double {
        items.reduce(0) { $0 + $1.total }
    }
}
