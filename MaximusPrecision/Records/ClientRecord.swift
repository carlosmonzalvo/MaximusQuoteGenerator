//
//  ClientRecord.swift
//  MaximusPrecision
//
//  The payer (👤). In the hospital analogy this is the "insurance": it foots the
//  bill but is not exclusive — a client can pay for several vehicles, and a
//  vehicle can be paid by different clients over time.
//

import Foundation
import SwiftData

@Model
final class ClientRecord {
    var name: String
    var phone: String
    var email: String
    var notes: String
    var createdAt: Date

    /// Vehicles this client is associated with (many-to-many, non-exclusive).
    /// Inverse is declared on `VehicleRecord.clients`.
    @Relationship(inverse: \VehicleRecord.clients)
    var vehicles: [VehicleRecord]

    /// Services this client has paid for. Nullified (not cascaded) if the client
    /// is deleted, since the service still belongs to the vehicle's history.
    @Relationship(inverse: \ServiceRecord.payer)
    var services: [ServiceRecord]

    init(
        name: String,
        phone: String = "",
        email: String = "",
        notes: String = "",
        createdAt: Date = .now,
        vehicles: [VehicleRecord] = [],
        services: [ServiceRecord] = []
    ) {
        self.name = name
        self.phone = phone
        self.email = email
        self.notes = notes
        self.createdAt = createdAt
        self.vehicles = vehicles
        self.services = services
    }
}
