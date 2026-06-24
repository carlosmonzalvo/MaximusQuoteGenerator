//
//  VehicleRecord.swift
//  MaximusPrecision
//
//  The patient (🚗). This is the central record: it owns its service history
//  (its "expediente") and can be associated with one or more clients/payers,
//  none of them exclusive — a car can be transferred from one client to another
//  and both stay in its history.
//

import Foundation
import SwiftData

@Model
final class VehicleRecord: Syncable {
    /// License plate — the vehicle's working identity. Not marked `.unique`
    /// (same rationale as the catalog models), uniqueness is enforced in the repo.
    var plate: String
    var brand: String
    var model: String
    var year: String
    var color: String
    var vin: String
    var notes: String
    var createdAt: Date

    // Sync metadata (see Syncable).
    var syncID: String = UUID().uuidString
    var updatedAt: Date = Date.now
    var deletedAt: Date? = nil
    var needsPush: Bool = true

    /// Clients associated with this vehicle (many-to-many, non-exclusive).
    var clients: [ClientRecord]

    /// The vehicle's service history. Cascaded: deleting the patient removes its
    /// expediente.
    @Relationship(deleteRule: .cascade, inverse: \ServiceRecord.vehicle)
    var services: [ServiceRecord]

    init(
        plate: String,
        brand: String = "",
        model: String = "",
        year: String = "",
        color: String = "",
        vin: String = "",
        notes: String = "",
        createdAt: Date = .now,
        clients: [ClientRecord] = [],
        services: [ServiceRecord] = []
    ) {
        self.plate = plate
        self.brand = brand
        self.model = model
        self.year = year
        self.color = color
        self.vin = vin
        self.notes = notes
        self.createdAt = createdAt
        self.clients = clients
        self.services = services
    }

    /// Display label, e.g. "Nissan Versa 2020".
    var displayName: String {
        [brand, model, year].filter { !$0.isEmpty }.joined(separator: " ")
    }

    /// Most recent payer, if any — the "current insurance" of the patient.
    var currentPayer: ClientRecord? {
        services.max(by: { $0.date < $1.date })?.payer
    }
}
