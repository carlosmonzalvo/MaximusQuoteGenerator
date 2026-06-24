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

    /// The year picker sheet.
    func test_captureYearPicker() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .tapMakeChip(0)            // Nissan
            .tapModelChip(0)           // Versa (sets the year lower bound)
        form.openYearPicker().assertVisible()
        snapshot("08-Year-picker")
    }

    /// The "más de 10 años" manual year entry.
    func test_captureYearManualEntry() {
        let form = QuoteFormRobot(app)
            .assertVisible()
            .tapMakeChip(0)
            .tapModelChip(0)
        form.openYearPicker().assertVisible().enableManualEntry()
        snapshot("16-Year-manual")
    }

    /// Expedientes: register a client + a vehicle and open the patient's record.
    func test_captureExpedientes() {
        let records = RecordsRobot(app).open()

        // Add a payer (client).
        records.selectClients()
            .addClient(name: "Juan Pérez", phone: "5512345678")
        snapshot("09-Clientes")

        // Add a patient (vehicle) and open its expediente.
        records.selectVehicles()
            .addVehicle(plate: "ABC-1234", brand: "Nissan", model: "Versa")
        snapshot("10-Autos")

        records.tapVehicleRow(0)
        snapshot("11-Expediente-auto")
    }

    /// Sync settings + history (seeded for a deterministic capture).
    func test_captureSyncHistory() {
        app.terminate()
        app = XCUIApplication.launchForTesting(extraArguments: [LaunchArgument.seedSyncDemo])
        RecordsRobot(app).open().openSync()
        snapshot("17-Sync-historial")
    }

    /// iOS 26 Liquid Glass search living in the tab bar (search-role tab).
    func test_captureGlassTabSearch() {
        let records = RecordsRobot(app).open()
        records.selectVehicles()
            .addVehicle(plate: "ABC-1234", brand: "Nissan", model: "Versa")
        records.searchInTabBar("Versa")
        snapshot("12-Busqueda-tab-glass")
    }

    /// The "Ver más" chip expanding the full make list.
    func test_captureVerMasMakes() {
        let form = QuoteFormRobot(app).assertVisible()
        form.tapMakeShowMore()
        snapshot("13-Ver-mas-marcas")
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
