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
        static let cardFeeToggle = "quoteForm.cardFeeToggle"
        static let subtotalAmount = "quoteForm.subtotalAmount"
        static let ivaAmount = "quoteForm.ivaAmount"
        static let cardFeeAmount = "quoteForm.cardFeeAmount"

        static let versionPill = "quoteForm.versionPill"
        static let yearField = "quoteForm.yearField"

        static func templateChip(_ index: Int) -> String { "quoteForm.template.\(index)" }
        static func lineItem(_ index: Int) -> String { "quoteForm.item.\(index)" }
        static func deleteItem(_ index: Int) -> String { "quoteForm.item.\(index).delete" }
        static func makeChip(_ index: Int) -> String { "quoteForm.make.\(index)" }
        static func modelChip(_ index: Int) -> String { "quoteForm.model.\(index)" }
    }

    enum VersionPicker {
        static let none = "versionPicker.none"
        static let close = "versionPicker.close"
        static func trim(_ index: Int) -> String { "versionPicker.trim.\(index)" }
    }

    enum YearPicker {
        static let close = "yearPicker.close"
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
}

/// Launch arguments the app understands. Passed by UI tests to get a
/// deterministic, fast-booting app (no 2s splash, etc.).
enum LaunchArgument {
    /// Present whenever the app is driven by XCUITest.
    static let uiTesting = "-uiTesting"
    /// Skip the animated splash and go straight to the form.
    static let skipSplash = "-skipSplash"

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
