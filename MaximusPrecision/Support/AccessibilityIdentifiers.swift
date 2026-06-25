//
//  AccessibilityIdentifiers.swift
//  MaximusPrecision
//
//  Shared between the app target and the UI test target so identifiers and
//  launch arguments can never drift out of sync. Add this file's target
//  membership to BOTH MaximusPrecision and MaximusPrecisionUITests.
//

import Foundation

/// Stable accessibility identifiers for every element the UI tests touch.
enum A11y {
    enum Splash {
        static let root = "splash.root"
    }

    enum QuoteForm {
        static let root = "quoteForm.root"
        static let customerName = "quoteForm.customerName"
        static let customerPhone = "quoteForm.customerPhone"
        static let vehicleBrand = "quoteForm.vehicleBrand"
        static let vehicleModel = "quoteForm.vehicleModel"
        static let vehicleYear = "quoteForm.vehicleYear"
        static let vehiclePlate = "quoteForm.vehiclePlate"
        static let addPart = "quoteForm.addPart"
        static let addLabor = "quoteForm.addLabor"
        static let notes = "quoteForm.notes"
        static let total = "quoteForm.total"
        static let generatePDF = "quoteForm.generatePDF"
        static let emptyState = "quoteForm.emptyState"

        static let docTypeQuote = "quoteForm.docType.quote"
        static let docTypeRemision = "quoteForm.docType.remision"
        static let ivaToggle = "quoteForm.ivaToggle"
        static let cashDiscountToggle = "quoteForm.cashDiscountToggle"
        static let subtotalAmount = "quoteForm.subtotalAmount"
        static let ivaAmount = "quoteForm.ivaAmount"
        static let cashDiscountAmount = "quoteForm.cashDiscountAmount"
        static let cashDiscountRate = "quoteForm.cashDiscountRate"

        static let versionPill = "quoteForm.versionPill"
        static let yearField = "quoteForm.yearField"

        static func templateChip(_ index: Int) -> String { "quoteForm.template.\(index)" }
        static func lineItem(_ index: Int) -> String { "quoteForm.item.\(index)" }
        static func deleteItem(_ index: Int) -> String { "quoteForm.item.\(index).delete" }
        static func makeChip(_ index: Int) -> String { "quoteForm.make.\(index)" }
        static func modelChip(_ index: Int) -> String { "quoteForm.model.\(index)" }
        static let makeShowMore = "quoteForm.make.showMore"
        static let modelShowMore = "quoteForm.model.showMore"
    }

    enum VersionPicker {
        static let none = "versionPicker.none"
        static let close = "versionPicker.close"
        static func trim(_ index: Int) -> String { "versionPicker.trim.\(index)" }
    }

    enum YearPicker {
        static let close = "yearPicker.close"
        static let manualToggle = "yearPicker.manualToggle"
        static let manualField = "yearPicker.manualField"
        static let manualConfirm = "yearPicker.manualConfirm"
        static func year(_ index: Int) -> String { "yearPicker.year.\(index)" }
    }

    enum ItemEdit {
        static let root = "itemEdit.root"
        static let typePicker = "itemEdit.typePicker"
        static let title = "itemEdit.title"
        static let detail = "itemEdit.detail"
        static let quantity = "itemEdit.quantity"
        static let unitPrice = "itemEdit.unitPrice"
        static let total = "itemEdit.total"
        static let done = "itemEdit.done"
        static let cancel = "itemEdit.cancel"
    }

    enum PDFPreview {
        static let root = "pdfPreview.root"
    }

    enum RootTab {
        static let quote = "rootTab.quote"
        static let records = "rootTab.records"
    }

    enum Records {
        static let root = "records.root"
        static let scopePicker = "records.scopePicker"
        static let search = "records.search"
        static let add = "records.add"
        static let sync = "records.sync"
        static let emptyState = "records.emptyState"
        static func vehicleRow(_ index: Int) -> String { "records.vehicle.\(index)" }
        static func clientRow(_ index: Int) -> String { "records.client.\(index)" }
    }

    enum RecordEdit {
        static let root = "recordEdit.root"
        static let name = "recordEdit.name"
        static let phone = "recordEdit.phone"
        static let email = "recordEdit.email"
        static let plate = "recordEdit.plate"
        static let brand = "recordEdit.brand"
        static let model = "recordEdit.model"
        static let year = "recordEdit.year"
        static let save = "recordEdit.save"
        static let cancel = "recordEdit.cancel"
    }

    enum Sync {
        static let enableToggle = "sync.enableToggle"
        static let peerToggle = "sync.peerToggle"
        static let syncNow = "sync.syncNow"
    }

    enum VehicleDetail {
        static let root = "vehicleDetail.root"
        static let payers = "vehicleDetail.payers"
        static let history = "vehicleDetail.history"
    }
}

/// Launch arguments the app understands. Passed by UI tests to get a
/// deterministic, fast-booting app (no 2s splash, etc.).
enum LaunchArgument {
    /// Present whenever the app is driven by XCUITest.
    static let uiTesting = "-uiTesting"
    /// Skip the animated splash and go straight to the form.
    static let skipSplash = "-skipSplash"
    /// Seed sync as enabled with a demo history (for deterministic screenshots).
    static let seedSyncDemo = "-seedSyncDemo"

    static var shouldSeedSyncDemo: Bool {
        ProcessInfo.processInfo.arguments.contains(seedSyncDemo)
    }

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTesting)
    }

    /// True when running under XCTest (unit or UI), used to keep the store
    /// ephemeral so test runs never touch the on-disk database.
    static var isRunningTests: Bool {
        isUITesting || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static var shouldSkipSplash: Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains(skipSplash) || args.contains(uiTesting)
    }
}
