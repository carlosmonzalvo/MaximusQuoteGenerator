//
//  ClientVehicleRepositoryTests.swift
//  MaximusPrecisionTests
//

import XCTest
import SwiftData
@testable import MaximusPrecision

@MainActor
final class ClientVehicleRepositoryTests: XCTestCase {

    private func makeRepo() throws -> ClientVehicleRepository {
        let context = AppModelContainer.shared.mainContext
        // Delete instances individually (in dependency order) — SwiftData's
        // batch delete trips over the nullify inverse on ServiceRecord.payer.
        try context.fetch(FetchDescriptor<ServiceRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<VehicleRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<ClientRecord>()).forEach(context.delete)
        try context.save()
        return ClientVehicleRepository(context: context)
    }

    func test_upsertVehicleIsDeduplicatedByPlate() throws {
        let repo = try makeRepo()
        let a = repo.upsertVehicle(plate: "ABC-123", brand: "Nissan", model: "Versa")
        let b = repo.upsertVehicle(plate: "abc-123") // same plate, different case
        XCTAssertEqual(a?.persistentModelID, b?.persistentModelID)
        XCTAssertEqual(repo.vehicles().count, 1)
        // Descriptive fields preserved.
        XCTAssertEqual(b?.brand, "Nissan")
    }

    func test_upsertClientIsDeduplicatedByNameAndPhone() throws {
        let repo = try makeRepo()
        _ = repo.upsertClient(name: "Juan Pérez", phone: "555")
        _ = repo.upsertClient(name: "juan pérez", phone: "555")
        _ = repo.upsertClient(name: "Juan Pérez", phone: "999") // different phone → new
        XCTAssertEqual(repo.clients().count, 2)
    }

    func test_linkIsNonExclusiveAndDeduplicated() throws {
        let repo = try makeRepo()
        let vehicle = try XCTUnwrap(repo.upsertVehicle(plate: "XYZ-1"))
        let c1 = try XCTUnwrap(repo.upsertClient(name: "Ana"))
        let c2 = try XCTUnwrap(repo.upsertClient(name: "Beto"))
        repo.link(client: c1, to: vehicle)
        repo.link(client: c2, to: vehicle)
        repo.link(client: c1, to: vehicle) // duplicate ignored
        XCTAssertEqual(vehicle.clients.count, 2)
    }

    func test_recordServiceBuildsHistoryAndLinksPayer() throws {
        let repo = try makeRepo()
        let quote = Quote(
            folio: "ABCD1234",
            date: Date(),
            documentType: .quote,
            customer: Customer(name: "Carlos", phone: "555"),
            vehicle: Vehicle(brand: "Nissan", model: "Versa", year: "2020", plate: "PLT-777"),
            items: [QuoteItem(type: .part, title: "Balatas", quantity: 1, unitPrice: 1000)],
            notes: "",
            includesIVA: true,
            includesCashDiscount: false
        )
        let service = try XCTUnwrap(repo.recordService(from: quote))
        repo.save()

        XCTAssertEqual(repo.vehicles().count, 1)
        XCTAssertEqual(repo.clients().count, 1)
        XCTAssertEqual(service.vehicle?.plate, "PLT-777")
        XCTAssertEqual(service.payer?.name, "Carlos")
        XCTAssertEqual(service.total, quote.total, accuracy: 0.001)

        let vehicle = try XCTUnwrap(repo.vehicles().first)
        XCTAssertEqual(vehicle.services.count, 1)
        XCTAssertEqual(vehicle.currentPayer?.name, "Carlos")
        XCTAssertTrue(vehicle.clients.contains { $0.name == "Carlos" })
    }

    func test_transferKeepsBothPayersInHistory() throws {
        let repo = try makeRepo()
        func quote(folio: String, payer: String) -> Quote {
            Quote(
                folio: folio, date: Date(), documentType: .quote,
                customer: Customer(name: payer, phone: ""),
                vehicle: Vehicle(brand: "VW", model: "Jetta", year: "2018", plate: "TRN-1"),
                items: [QuoteItem(type: .labor, title: "Servicio", quantity: 1, unitPrice: 500)],
                notes: "", includesIVA: false, includesCashDiscount: false
            )
        }
        repo.recordService(from: quote(folio: "F1", payer: "Dueño A"))
        repo.recordService(from: quote(folio: "F2", payer: "Dueño B"))
        repo.save()

        let vehicle = try XCTUnwrap(repo.vehicles().first)
        XCTAssertEqual(repo.vehicles().count, 1) // same patient
        XCTAssertEqual(vehicle.services.count, 2)
        XCTAssertEqual(Set(vehicle.clients.map(\.name)), ["Dueño A", "Dueño B"])
    }
}
