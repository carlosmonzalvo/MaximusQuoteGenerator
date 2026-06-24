//
//  ScreenshotTests.swift
//  MaximusPrecisionUITests
//
//  Captures marketing/review screenshots of the new features. Run via:
//    xcodebuild test -only-testing:MaximusPrecisionUITests/ScreenshotTests ...
//  then export with `xcrun xcresulttool export attachments`.
//

import XCTest

final class ScreenshotTests: XCTestCase {

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

    private func snapshot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Main form with vehicle pills, document-type switch, and the PDF.
    func test_captureMainFlow() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .fillCustomer(name: "Juan Pérez", phone: "5512345678")

        // Add the line item while the header is short (add buttons on screen).
        form.tapAddPart()
            .setTitle("Balatas delanteras")
            .setQuantity("2")
            .setUnitPrice("900")
            .tapDone()
        form.dismissKeyboardIfNeeded()

        // Vehicle catalog: make/model pills.
        form.tapMakeChip(0)            // Nissan
            .assertModelChipsVisible()
        snapshot("06-Pills-marca-modelo")
        form.tapModelChip(0)           // Versa
        snapshot("01-Cotizacion")

        // Document type switch (the switcher sits at the top of the header).
        form.switchToRemision()
        snapshot("04-Nota-de-remision")
        form.switchToQuote()

        form.tapGenerate()
        PDFPreviewRobot(app).assertVisible()
        snapshot("05-PDF-generado")
    }

    /// Totals breakdown with IVA + card fee. Kept free of vehicle pills so the
    /// header stays short and the toggles are always on screen.
    func test_captureTotals() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .fillCustomer(name: "Juan Pérez", phone: "5512345678")

        form.tapAddPart()
            .setTitle("Balatas delanteras")
            .setQuantity("2")
            .setUnitPrice("900")
            .tapDone()
        form.dismissKeyboardIfNeeded()

        form.toggleIVA()
        snapshot("02-IVA-16")

        form.toggleCardFee()
        snapshot("03-Comision-tarjeta")
    }

    /// The optional version sheet, captured on its own.
    func test_captureVersionSheet() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .tapMakeChip(0)            // Nissan
            .tapModelChip(0)           // Versa

        form.openVersionPicker()
        snapshot("07-Version-sheet")
    }
}
