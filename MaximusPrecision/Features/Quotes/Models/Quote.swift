import Foundation

struct Quote: Codable {
    var folio: String
    var date: Date
    var customer: Customer
    var vehicle: Vehicle
    var items: [QuoteItem]
    var notes: String

    var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }

    var total: Double {
        subtotal
    }
}
