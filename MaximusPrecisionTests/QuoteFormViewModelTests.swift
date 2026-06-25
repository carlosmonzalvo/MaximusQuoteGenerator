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
        XCTAssertEqual(vm.makeNames.count, 12)
    }

    func test_makesPreviewAndShowMore() throws {
        let vm = try makeVM()
        // Preview shows only the first N makes with a "ver más" affordance.
        XCTAssertEqual(vm.visibleMakeNames.count, vm.makesPreviewCount)
        XCTAssertTrue(vm.hasMoreMakes)
        vm.showMoreMakes()
        XCTAssertEqual(vm.visibleMakeNames.count, vm.makeNames.count)
        XCTAssertFalse(vm.hasMoreMakes)
    }

    func test_modelsPreviewResetsWhenSwitchingMake() throws {
        let vm = try makeVM()
        vm.selectMake("Toyota")           // many models → preview + ver más
        XCTAssertEqual(vm.visibleModelOptions.count, vm.modelsPreviewCount)
        XCTAssertTrue(vm.hasMoreModels)
        vm.showMoreModels()
        XCTAssertFalse(vm.hasMoreModels)
        // Switching make collapses the model list back to the preview.
        vm.selectMake("Nissan")
        XCTAssertFalse(vm.showAllModels)
        XCTAssertTrue(vm.hasMoreModels)
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

    func test_manualYearEntrySanitizesAndFlagsOutOfRange() throws {
        let vm = try makeVM()
        // Digits only, capped at 4 chars.
        vm.setManualYear("año 2008!")
        XCTAssertEqual(vm.vehicleYear, "2008")
        // 2008 is more than 10 years before the current year → out of range.
        XCTAssertTrue(vm.isYearOutOfRange)

        // A recent year (inside the 10-year window) is not out of range.
        vm.vehicleYear = String(vm.currentYear - 1)
        XCTAssertFalse(vm.isYearOutOfRange)

        // The range floor itself is still in range.
        vm.vehicleYear = String(vm.rangeStartYear)
        XCTAssertFalse(vm.isYearOutOfRange)
    }

    func test_minYearClampsToModelYearStart() throws {
        let vm = try makeVM()
        XCTAssertEqual(vm.minYear(forModelYearStart: nil), 2015)
        XCTAssertEqual(vm.minYear(forModelYearStart: 2021), 2021)
        XCTAssertEqual(vm.minYear(forModelYearStart: 2010), 2015) // never below catalog floor
    }

    func test_totalsWithIvaAndCashDiscount() {
        let vm = QuoteFormViewModel()
        vm.items = [QuoteItem(type: .part, title: "x", quantity: 1, unitPrice: 1000)]
        XCTAssertEqual(vm.total, 1000, accuracy: 0.001)

        vm.includesIVA = true
        XCTAssertEqual(vm.ivaAmount, 160, accuracy: 0.001)
        XCTAssertEqual(vm.total, 1160, accuracy: 0.001)

        // Default cash discount is 16% of subtotal, which equals the IVA, so a
        // cash payer pays the subtotal.
        vm.includesCashDiscount = true
        XCTAssertEqual(vm.cashDiscountPercent, 16, accuracy: 0.001)
        XCTAssertEqual(vm.cashDiscountAmount, 160, accuracy: 0.001)
        XCTAssertEqual(vm.total, 1000, accuracy: 0.001)

        // Configurable: 10% → discount 100, total 1060.
        vm.cashDiscountPercent = 10
        XCTAssertEqual(vm.cashDiscountAmount, 100, accuracy: 0.001)
        XCTAssertEqual(vm.total, 1060, accuracy: 0.001)
    }
}
