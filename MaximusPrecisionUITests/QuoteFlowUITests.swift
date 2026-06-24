//
//  QuoteFlowUITests.swift
//  MaximusPrecisionUITests
//
//  End-to-end UI tests written with the Robot Pattern. The test bodies read as
//  user intent; all element lookups live in the *Robot types.
//

import XCTest

final class QuoteFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication.launchForTesting()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    /// Happy path: capture customer + vehicle, add a line item, generate the PDF.
    func test_generateQuote_happyPath() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .assertEmptyStateVisible()
            .fillCustomer(name: "Juan Pérez", phone: "5512345678")
            .fillVehicle(brand: "Nissan", model: "Sentra", year: "2018", plate: "ABC1234")

        form.tapAddPart()
            .setTitle("Balatas delanteras")
            .setQuantity("2")
            .setUnitPrice("450")
            .tapDone()

        form.assertLineItemCount(1)
            .tapGenerate()

        PDFPreviewRobot(app)
            .assertVisible()
            .assertShareOptionsVisible()
    }

    /// Quick-add from a template chip should create a line item without the sheet.
    func test_addTemplate_createsLineItem() {
        QuoteFormRobot(app)
            .assertVisible()
            .addTemplate(at: 0)
            .assertLineItemCount(1)
    }

    /// Generating without a customer name surfaces the validation alert.
    func test_generateWithoutCustomer_showsValidationAlert() {
        QuoteFormRobot(app)
            .assertVisible()
            .addTemplate(at: 0)
            .tapGenerate()

        XCTAssertTrue(
            app.alerts["Aviso"].waitForExistence(timeout: 5),
            "Expected validation alert when generating without a customer"
        )
    }

    /// Deleting the only line item returns the form to its empty state.
    func test_deleteLineItem_returnsToEmptyState() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .addTemplate(at: 0)
            .assertLineItemCount(1)

        form.deleteItem(at: 0)
            .assertEmptyStateVisible()
    }
}
