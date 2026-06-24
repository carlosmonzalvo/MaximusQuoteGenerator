//
//  SyncEngineTests.swift
//  MaximusPrecisionTests
//

import XCTest
import SwiftData
@testable import MaximusPrecision

@MainActor
final class SyncEngineTests: XCTestCase {

    private func freshContext() throws -> ModelContext {
        let context = AppModelContainer.shared.mainContext
        try context.fetch(FetchDescriptor<ServiceRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<VehicleRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<ClientRecord>()).forEach(context.delete)
        try context.save()
        return context
    }

    func test_snapshotCapturesLocalRecords() throws {
        let context = try freshContext()
        let repo = ClientVehicleRepository(context: context)
        let v = try XCTUnwrap(repo.upsertVehicle(plate: "ABC-1", brand: "Nissan", model: "Versa"))
        let c = try XCTUnwrap(repo.upsertClient(name: "Juan"))
        repo.link(client: c, to: v)
        repo.save()

        let payload = SyncEngine(context: context).snapshot()
        XCTAssertEqual(payload.vehicles.count, 1)
        XCTAssertEqual(payload.clients.count, 1)
        XCTAssertEqual(payload.vehicles.first?.clientSyncIDs, [c.syncID])
    }

    func test_mergeCreatesRemoteRecords() throws {
        let context = try freshContext()
        let engine = SyncEngine(context: context)

        var remote = SyncPayload(deviceID: "other")
        remote.clients = [ClientDTO(syncID: "C1", updatedAt: Date(), deletedAt: nil,
                                    name: "Remoto", phone: "55", email: "", notes: "")]
        let changed = engine.merge(remote)

        XCTAssertEqual(changed, 1)
        let clients = (try context.fetch(FetchDescriptor<ClientRecord>()))
        XCTAssertEqual(clients.map(\.name), ["Remoto"])
        XCTAssertEqual(clients.first?.syncID, "C1")
    }

    func test_mergeIsLastWriteWins() throws {
        let context = try freshContext()
        let engine = SyncEngine(context: context)

        // Seed a local client at t0.
        let local = ClientRecord(name: "Local")
        local.syncID = "C1"
        local.updatedAt = Date(timeIntervalSince1970: 1_000)
        context.insert(local)
        try context.save()

        // Older remote update is ignored.
        var older = SyncPayload()
        older.clients = [ClientDTO(syncID: "C1", updatedAt: Date(timeIntervalSince1970: 500),
                                   deletedAt: nil, name: "Viejo", phone: "", email: "", notes: "")]
        engine.merge(older)
        XCTAssertEqual(find(context, "C1")?.name, "Local")

        // Newer remote update wins.
        var newer = SyncPayload()
        newer.clients = [ClientDTO(syncID: "C1", updatedAt: Date(timeIntervalSince1970: 2_000),
                                   deletedAt: nil, name: "Nuevo", phone: "99", email: "", notes: "")]
        engine.merge(newer)
        XCTAssertEqual(find(context, "C1")?.name, "Nuevo")
        XCTAssertEqual(find(context, "C1")?.phone, "99")
    }

    func test_mergeAppliesSoftDelete() throws {
        let context = try freshContext()
        let engine = SyncEngine(context: context)
        let local = ClientRecord(name: "Local")
        local.syncID = "C1"
        local.updatedAt = Date(timeIntervalSince1970: 1_000)
        context.insert(local)
        try context.save()

        var tombstone = SyncPayload()
        tombstone.clients = [ClientDTO(syncID: "C1", updatedAt: Date(timeIntervalSince1970: 2_000),
                                       deletedAt: Date(timeIntervalSince1970: 2_000),
                                       name: "Local", phone: "", email: "", notes: "")]
        engine.merge(tombstone)
        XCTAssertNotNil(find(context, "C1")?.deletedAt)
    }

    func test_mergeRelinksServiceToVehicleAndPayer() throws {
        let context = try freshContext()
        let engine = SyncEngine(context: context)

        var remote = SyncPayload(deviceID: "other")
        remote.clients = [ClientDTO(syncID: "C1", updatedAt: Date(), deletedAt: nil,
                                    name: "Pagador", phone: "", email: "", notes: "")]
        remote.vehicles = [VehicleDTO(syncID: "V1", updatedAt: Date(), deletedAt: nil,
                                      plate: "PLT-1", brand: "VW", model: "Jetta", year: "2020",
                                      color: "", vin: "", notes: "", clientSyncIDs: ["C1"])]
        remote.services = [ServiceDTO(syncID: "S1", updatedAt: Date(), deletedAt: nil,
                                      folio: "F1", date: Date(), documentTypeRaw: "Cotización",
                                      notes: "", includesIVA: false, includesCardFee: false,
                                      subtotal: 100, ivaAmount: 0, cardFeeAmount: 0, total: 100,
                                      vehicleSyncID: "V1", payerSyncID: "C1")]
        engine.merge(remote)

        let service = try XCTUnwrap((try context.fetch(FetchDescriptor<ServiceRecord>())).first)
        XCTAssertEqual(service.vehicle?.plate, "PLT-1")
        XCTAssertEqual(service.payer?.name, "Pagador")
        let vehicle = try XCTUnwrap((try context.fetch(FetchDescriptor<VehicleRecord>())).first)
        XCTAssertEqual(vehicle.clients.map(\.name), ["Pagador"])
    }

    private func find(_ context: ModelContext, _ syncID: String) -> ClientRecord? {
        (try? context.fetch(FetchDescriptor<ClientRecord>()))?.first { $0.syncID == syncID }
    }
}
