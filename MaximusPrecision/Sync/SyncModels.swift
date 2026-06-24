//
//  SyncModels.swift
//  MaximusPrecision
//
//  Transport-agnostic sync primitives. The on-device records carry a stable
//  `syncID`, an `updatedAt` timestamp and a soft-delete `deletedAt`; these DTOs
//  are the wire/peer representation, and `SyncPayload` is one exchange unit.
//
//  Conflict resolution is last-write-wins by `updatedAt`. None of this is wired
//  to a transport by default, so the app stays 100% local and independent.
//

import Foundation

/// Anything that can take part in sync. Implemented by the SwiftData records.
protocol Syncable: AnyObject {
    var syncID: String { get set }
    var updatedAt: Date { get set }
    var deletedAt: Date? { get set }
}

extension Syncable {
    var isDeleted: Bool { deletedAt != nil }
}

/// Stable per-install identifier, so a device can tell its own echoes apart.
enum DeviceID {
    private static let key = "maximus.sync.deviceID"
    static let current: String = {
        if let existing = UserDefaults.standard.string(forKey: key) { return existing }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }()
}

// MARK: - DTOs (Codable wire representation)

struct ClientDTO: Codable, Hashable {
    var syncID: String
    var updatedAt: Date
    var deletedAt: Date?
    var name: String
    var phone: String
    var email: String
    var notes: String
}

struct VehicleDTO: Codable, Hashable {
    var syncID: String
    var updatedAt: Date
    var deletedAt: Date?
    var plate: String
    var brand: String
    var model: String
    var year: String
    var color: String
    var vin: String
    var notes: String
    /// syncIDs of linked clients (the many-to-many edges).
    var clientSyncIDs: [String]
}

struct ServiceDTO: Codable, Hashable {
    var syncID: String
    var updatedAt: Date
    var deletedAt: Date?
    var folio: String
    var date: Date
    var documentTypeRaw: String
    var notes: String
    var includesIVA: Bool
    var includesCardFee: Bool
    var subtotal: Double
    var ivaAmount: Double
    var cardFeeAmount: Double
    var total: Double
    var vehicleSyncID: String?
    var payerSyncID: String?
}

/// One sync exchange: a bundle of record snapshots plus the sender's identity.
struct SyncPayload: Codable {
    var deviceID: String = DeviceID.current
    var sentAt: Date = .now
    var clients: [ClientDTO] = []
    var vehicles: [VehicleDTO] = []
    var services: [ServiceDTO] = []

    var isEmpty: Bool { clients.isEmpty && vehicles.isEmpty && services.isEmpty }
}
