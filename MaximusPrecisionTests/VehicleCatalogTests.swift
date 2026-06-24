//
//  VehicleCatalogTests.swift
//  MaximusPrecisionTests
//

import XCTest
import SwiftData
@testable import MaximusPrecision

@MainActor
final class VehicleCatalogTests: XCTestCase {

    /// Uses the process-wide shared (in-memory under tests) container so there
    /// is only ever one container per process.
    private func makeCatalog() throws -> VehicleCatalog {
        let context = AppModelContainer.shared.mainContext
        // Start from a clean slate so each test is independent.
        try context.delete(model: CatalogMake.self)
        try context.delete(model: CatalogModel.self)
        try context.save()
        return VehicleCatalog(context: context)
    }

    func test_seedInsertsTopThreeMakesInRankOrder() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        XCTAssertEqual(catalog.makes(), ["Nissan", "Chevrolet", "Volkswagen"])
    }

    func test_seedIsIdempotent() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        catalog.seedIfNeeded()
        XCTAssertEqual(catalog.makes().count, 3)
    }

    func test_tierFilterLimitsMakes() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        // Everything seeded so far is tier 1.
        XCTAssertEqual(catalog.makes(maxTier: 1).count, 3)
        XCTAssertEqual(catalog.makes(maxTier: 0).count, 0)
    }

    func test_modelsOrderedByCommonality() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        let nissan = catalog.models(forMake: "Nissan")
        XCTAssertEqual(nissan.first?.name, "Versa")
        XCTAssertTrue(nissan.contains { $0.name == "Sentra" })
    }

    func test_modelsCarryOptionalTrims() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        let versa = catalog.models(forMake: "Nissan").first { $0.name == "Versa" }
        XCTAssertEqual(versa?.trims, ["Sense", "Advance", "Exclusive"])
        XCTAssertTrue(versa?.hasTrims == true)
    }

    func test_modelsLookupIsCaseInsensitiveAndCached() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        let first = catalog.models(forMake: "Nissan")
        let cached = catalog.models(forMake: "nissan")
        XCTAssertEqual(first.map(\.name), cached.map(\.name))
        XCTAssertFalse(first.isEmpty)
    }
}
