//
//  QuoteFormViewModelTests.swift
//  MaximusPrecisionTests
//

import XCTest
import SwiftData
@testable import MaximusPrecision

@MainActor
final class QuoteFormViewModelTests: XCTestCase {

    private func makeVM() throws -> QuoteFormViewModel {
        let context = AppModelContainer.shared.mainContext
        try context.delete(model: CatalogMake.self)
        try context.delete(model: CatalogModel.self)
        try context.save()
        let vm = QuoteFormViewModel()
        vm.loadCatalog(context: context)
        return vm
    }

    func test_loadCatalogPopulatesMakes() throws {
        let vm = try makeVM()
        XCTAssertEqual(vm.makeNames.first, "Nissan")
        XCTAssertEqual(vm.makeNames.count, 8)
    }

    func test_selectMakeLoadsModelsAndResetsModel() throws {
        let vm = try makeVM()
        vm.vehicleModel = "stale"
        vm.selectMake("Nissan")
        XCTAssertEqual(vm.vehicleBrand, "Nissan")
        XCTAssertEqual(vm.vehicleModel, "")
        XCTAssertEqual(vm.modelOptions.first?.name, "Versa")
    }

    func test_selectModelAndApplyVersion() throws {
        let vm = try makeVM()
        vm.selectMake("Nissan")
        let versa = try XCTUnwrap(vm.modelOptions.first { $0.name == "Versa" })
        vm.selectModel(versa)
        XCTAssertEqual(vm.vehicleModel, "Versa")

        vm.applyVersion("Advance")
        XCTAssertEqual(vm.vehicleModel, "Versa Advance")

        vm.applyVersion(nil)
        XCTAssertEqual(vm.vehicleModel, "Versa")
    }

    func test_minYearClampsToModelYearStart() throws {
        let vm = try makeVM()
        XCTAssertEqual(vm.minYear(forModelYearStart: nil), 2015)
        XCTAssertEqual(vm.minYear(forModelYearStart: 2021), 2021)
        XCTAssertEqual(vm.minYear(forModelYearStart: 2010), 2015) // never below catalog floor
    }

    func test_totalsWithIvaAndCardFee() {
        let vm = QuoteFormViewModel()
        vm.items = [QuoteItem(type: .part, title: "x", quantity: 1, unitPrice: 1000)]
        XCTAssertEqual(vm.total, 1000, accuracy: 0.001)

        vm.includesIVA = true
        XCTAssertEqual(vm.ivaAmount, 160, accuracy: 0.001)
        XCTAssertEqual(vm.total, 1160, accuracy: 0.001)

        vm.includesCardFee = true
        XCTAssertEqual(vm.cardFeeAmount, 1160 * 0.045, accuracy: 0.001)
        XCTAssertEqual(vm.total, 1160 + 1160 * 0.045, accuracy: 0.001)
    }
}
