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

    func test_captureFeatureScreenshots() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .fillCustomer(name: "Juan Pérez", phone: "5512345678")
            .fillVehicle(brand: "Nissan", model: "Sentra", year: "2018", plate: "ABC1234")

        form.tapAddPart()
            .setTitle("Balatas delanteras")
            .setQuantity("2")
            .setUnitPrice("900")
            .tapDone()

        form.dismissKeyboardIfNeeded()
        snapshot("01-Cotizacion")

        form.toggleIVA()
        snapshot("02-IVA-16")

        form.toggleCardFee()
        snapshot("03-Comision-tarjeta")

        form.switchToRemision()
        snapshot("04-Nota-de-remision")

        form.tapGenerate()
        PDFPreviewRobot(app).assertVisible()
        snapshot("05-PDF-generado")
    }
}
