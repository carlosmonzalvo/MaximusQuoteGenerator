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

    func test_seedTopThreeMakesAreTier1InRankOrder() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        XCTAssertEqual(catalog.makes(maxTier: 1), ["Nissan", "Chevrolet", "Volkswagen"])
    }

    func test_seedIsIdempotent() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        let count = catalog.makes().count
        catalog.seedIfNeeded()
        XCTAssertEqual(catalog.makes().count, count)
    }

    func test_tierFilterLimitsMakes() throws {
        let catalog = try makeCatalog()
        catalog.seedIfNeeded()
        XCTAssertEqual(catalog.makes(maxTier: 0).count, 0)
        XCTAssertEqual(catalog.makes(maxTier: 1).count, 3)        // tier 1
        XCTAssertEqual(catalog.makes(maxTier: 2).count, 6)        // tier 1 + 2
        XCTAssertEqual(catalog.makes(maxTier: 3).count, 8)        // tier 1 + 2 + 3
        XCTAssertEqual(catalog.makes(maxTier: 4).count, 9)        // tier 1 + 2 + 3 + 4
        // Ranks are global and ordered.
        XCTAssertEqual(catalog.makes(), ["Nissan", "Chevrolet", "Volkswagen", "KIA", "Toyota", "Mazda", "SEAT", "Cupra", "Ford"])
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
