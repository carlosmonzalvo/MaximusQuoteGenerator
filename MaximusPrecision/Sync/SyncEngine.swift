//
//  SyncEngine.swift
//  MaximusPrecision
//
//  Snapshots the local SwiftData store into a SyncPayload and merges a remote
//  payload back in, resolving conflicts last-write-wins by `updatedAt`. It is
//  transport-agnostic: `sync(using:)` drives any SyncTransport, and with no
//  transport the engine simply does nothing (the app stays independent).
//

import Foundation
import SwiftData

@MainActor
final class SyncEngine {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Outcome of a sync pass, surfaced to the history UI.
    struct Result {
        var pushed: Int
        var pulled: Int
        var cursor: Int
    }

    // MARK: Snapshot (local → DTOs)

    /// Full snapshot of everything (used by peer transports and tests).
    func snapshot() -> SyncPayload {
        var payload = SyncPayload()
        payload.clients = fetchAll(ClientRecord.self).map(dto(for:))
        payload.vehicles = fetchAll(VehicleRecord.self).map(dto(for:))
        payload.services = fetchAll(ServiceRecord.self).map(dto(for:))
        return payload
    }

    /// Outbox: only records with local edits not yet pushed (delta push).
    func pendingSnapshot(cursor: Int) -> SyncPayload {
        var payload = SyncPayload()
        payload.sinceSeq = cursor
        payload.clients = fetchAll(ClientRecord.self).filter(\.needsPush).map(dto(for:))
        payload.vehicles = fetchAll(VehicleRecord.self).filter(\.needsPush).map(dto(for:))
        payload.services = fetchAll(ServiceRecord.self).filter(\.needsPush).map(dto(for:))
        return payload
    }

    // MARK: Merge (remote DTOs → local, last-write-wins)

    /// Applies a remote payload. Returns the number of records created/updated.
    @discardableResult
    func merge(_ remote: SyncPayload) -> Int {
        var changed = 0

        // Clients first (vehicles/services reference them).
        for incoming in remote.clients {
            changed += mergeClient(incoming)
        }
        for incoming in remote.vehicles {
            changed += mergeVehicle(incoming)
        }
        for incoming in remote.services {
            changed += mergeService(incoming)
        }

        try? context.save()
        return changed
    }

    /// Delta round trip over a transport: push only pending local edits, pull
    /// only records past the cursor, then merge (LWW) and advance the cursor.
    @discardableResult
    func sync(using transport: SyncTransport, cursor: Int = 0) async throws -> Result {
        guard transport.isAvailable else { throw SyncError.transportUnavailable }

        let outbox = pendingSnapshot(cursor: cursor)
        let pushedIDs = Set(outbox.clients.map(\.syncID)
            + outbox.vehicles.map(\.syncID)
            + outbox.services.map(\.syncID))

        let remote: SyncPayload
        do {
            remote = try await transport.exchange(outbox)
        } catch {
            throw SyncError.transport(error)
        }

        let pulled = merge(remote)
        clearPushFlags(for: pushedIDs)
        try? context.save()

        let nextCursor = remote.maxSeq > 0 ? remote.maxSeq : cursor
        return Result(pushed: pushedIDs.count, pulled: pulled, cursor: nextCursor)
    }

    /// Clears the outbox flag on records the server has now acknowledged.
    private func clearPushFlags(for ids: Set<String>) {
        guard !ids.isEmpty else { return }
        for c in fetchAll(ClientRecord.self) where ids.contains(c.syncID) { c.needsPush = false }
        for v in fetchAll(VehicleRecord.self) where ids.contains(v.syncID) { v.needsPush = false }
        for s in fetchAll(ServiceRecord.self) where ids.contains(s.syncID) { s.needsPush = false }
    }

    // MARK: Per-entity merge

    private func mergeClient(_ dto: ClientDTO) -> Int {
        let existing = find(ClientRecord.self, syncID: dto.syncID)
        guard shouldApply(incoming: dto.updatedAt, existing: existing?.updatedAt) else { return 0 }
        let client = existing ?? {
            let c = ClientRecord(name: dto.name)
            c.syncID = dto.syncID
            context.insert(c)
            return c
        }()
        client.name = dto.name
        client.phone = dto.phone
        client.email = dto.email
        client.notes = dto.notes
        client.updatedAt = dto.updatedAt
        client.deletedAt = dto.deletedAt
        client.needsPush = false
        return 1
    }

    private func mergeVehicle(_ dto: VehicleDTO) -> Int {
        let existing = find(VehicleRecord.self, syncID: dto.syncID)
        guard shouldApply(incoming: dto.updatedAt, existing: existing?.updatedAt) else { return 0 }
        let vehicle = existing ?? {
            let v = VehicleRecord(plate: dto.plate)
            v.syncID = dto.syncID
            context.insert(v)
            return v
        }()
        vehicle.plate = dto.plate
        vehicle.brand = dto.brand
        vehicle.model = dto.model
        vehicle.year = dto.year
        vehicle.color = dto.color
        vehicle.vin = dto.vin
        vehicle.notes = dto.notes
        vehicle.updatedAt = dto.updatedAt
        vehicle.deletedAt = dto.deletedAt
        vehicle.needsPush = false
        // Re-link clients by syncID (union, non-exclusive).
        let linked = dto.clientSyncIDs.compactMap { find(ClientRecord.self, syncID: $0) }
        for client in linked where !vehicle.clients.contains(where: { $0.syncID == client.syncID }) {
            vehicle.clients.append(client)
        }
        return 1
    }

    private func mergeService(_ dto: ServiceDTO) -> Int {
        let existing = find(ServiceRecord.self, syncID: dto.syncID)
        guard shouldApply(incoming: dto.updatedAt, existing: existing?.updatedAt) else { return 0 }
        let service = existing ?? {
            let s = ServiceRecord(folio: dto.folio)
            s.syncID = dto.syncID
            context.insert(s)
            return s
        }()
        service.folio = dto.folio
        service.date = dto.date
        service.documentTypeRaw = dto.documentTypeRaw
        service.notes = dto.notes
        service.includesIVA = dto.includesIVA
        service.includesCashDiscount = dto.includesCashDiscount
        service.cashDiscountRate = dto.cashDiscountRate
        service.subtotal = dto.subtotal
        service.ivaAmount = dto.ivaAmount
        service.cashDiscountAmount = dto.cashDiscountAmount
        service.total = dto.total
        service.updatedAt = dto.updatedAt
        service.deletedAt = dto.deletedAt
        service.needsPush = false
        service.vehicle = dto.vehicleSyncID.flatMap { find(VehicleRecord.self, syncID: $0) }
        service.payer = dto.payerSyncID.flatMap { find(ClientRecord.self, syncID: $0) }
        return 1
    }

    /// Last-write-wins: apply when there is no local copy, or the incoming
    /// timestamp is newer.
    private func shouldApply(incoming: Date, existing: Date?) -> Bool {
        guard let existing else { return true }
        return incoming > existing
    }

    // MARK: DTO builders

    private func dto(for c: ClientRecord) -> ClientDTO {
        ClientDTO(syncID: c.syncID, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
                  name: c.name, phone: c.phone, email: c.email, notes: c.notes)
    }

    private func dto(for v: VehicleRecord) -> VehicleDTO {
        VehicleDTO(syncID: v.syncID, updatedAt: v.updatedAt, deletedAt: v.deletedAt,
                   plate: v.plate, brand: v.brand, model: v.model, year: v.year,
                   color: v.color, vin: v.vin, notes: v.notes,
                   clientSyncIDs: v.clients.map(\.syncID))
    }

    private func dto(for s: ServiceRecord) -> ServiceDTO {
        ServiceDTO(syncID: s.syncID, updatedAt: s.updatedAt, deletedAt: s.deletedAt,
                   folio: s.folio, date: s.date, documentTypeRaw: s.documentTypeRaw,
                   notes: s.notes, includesIVA: s.includesIVA, includesCashDiscount: s.includesCashDiscount,
                   cashDiscountRate: s.cashDiscountRate,
                   subtotal: s.subtotal, ivaAmount: s.ivaAmount, cashDiscountAmount: s.cashDiscountAmount,
                   total: s.total, vehicleSyncID: s.vehicle?.syncID, payerSyncID: s.payer?.syncID)
    }

    // MARK: Fetch helpers

    private func fetchAll<T: PersistentModel>(_ type: T.Type) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }

    private func find<T: PersistentModel & Syncable>(_ type: T.Type, syncID: String) -> T? {
        fetchAll(type).first { $0.syncID == syncID }
    }
}
