//
//  ServiceRecord.swift
//  MaximusPrecision
//
//  A saved quote / nota de remisión (🧾) — the "visit" in the hospital analogy.
//  It records which vehicle (patient) was attended and which client (payer) paid
//  that time, along with a snapshot of the line items and totals so the document
//  is reproducible even if the catalog or prices change later.
//

import Foundation
import SwiftData

@Model
final class ServiceRecord: Syncable {
    var folio: String
    var date: Date

    // Sync metadata (see Syncable).
    var syncID: String = UUID().uuidString
    var updatedAt: Date = Date.now
    var deletedAt: Date? = nil
    var needsPush: Bool = true
    /// Stored as the raw value of `DocumentType` for forward compatibility.
    var documentTypeRaw: String
    var notes: String
    var includesIVA: Bool
    var includesCashDiscount: Bool
    var cashDiscountRate: Double = QuoteCalculatorService.defaultCashDiscountRate

    /// Frozen line items at the time the document was generated.
    var items: [QuoteItem]

    /// Frozen totals (so historical documents never drift with price changes).
    var subtotal: Double
    var ivaAmount: Double
    var cashDiscountAmount: Double
    var total: Double

    /// The patient this visit belongs to. Inverse: `VehicleRecord.services`.
    var vehicle: VehicleRecord?
    /// Who paid this time. Inverse: `ClientRecord.services`.
    var payer: ClientRecord?

    init(
        folio: String,
        date: Date = .now,
        documentType: DocumentType = .quote,
        notes: String = "",
        includesIVA: Bool = false,
        includesCashDiscount: Bool = false,
        cashDiscountRate: Double = QuoteCalculatorService.defaultCashDiscountRate,
        items: [QuoteItem] = [],
        subtotal: Double = 0,
        ivaAmount: Double = 0,
        cashDiscountAmount: Double = 0,
        total: Double = 0,
        vehicle: VehicleRecord? = nil,
        payer: ClientRecord? = nil
    ) {
        self.folio = folio
        self.date = date
        self.documentTypeRaw = documentType.rawValue
        self.notes = notes
        self.includesIVA = includesIVA
        self.includesCashDiscount = includesCashDiscount
        self.cashDiscountRate = cashDiscountRate
        self.items = items
        self.subtotal = subtotal
        self.ivaAmount = ivaAmount
        self.cashDiscountAmount = cashDiscountAmount
        self.total = total
        self.vehicle = vehicle
        self.payer = payer
    }

    var documentType: DocumentType {
        DocumentType(rawValue: documentTypeRaw) ?? .quote
    }
}
