//
//  QuoteFormRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the main quote form screen.
//

import XCTest

final class QuoteFormRobot: Robot {

    // MARK: Elements

    private var customerName: XCUIElement { element(A11y.QuoteForm.customerName) }
    private var customerPhone: XCUIElement { element(A11y.QuoteForm.customerPhone) }
    private var vehicleBrand: XCUIElement { element(A11y.QuoteForm.vehicleBrand) }
    private var vehicleModel: XCUIElement { element(A11y.QuoteForm.vehicleModel) }
    private var vehicleYear: XCUIElement { element(A11y.QuoteForm.vehicleYear) }
    private var vehiclePlate: XCUIElement { element(A11y.QuoteForm.vehiclePlate) }
    private var notes: XCUIElement { element(A11y.QuoteForm.notes) }
    private var addPartButton: XCUIElement { element(A11y.QuoteForm.addPart) }
    private var addLaborButton: XCUIElement { element(A11y.QuoteForm.addLabor) }
    private var generateButton: XCUIElement { element(A11y.QuoteForm.generatePDF) }
    private var emptyState: XCUIElement { element(A11y.QuoteForm.emptyState) }
    private var ivaToggleButton: XCUIElement { element(A11y.QuoteForm.ivaToggle) }
    private var cardFeeToggleButton: XCUIElement { element(A11y.QuoteForm.cardFeeToggle) }
    private var docTypeQuoteButton: XCUIElement { element(A11y.QuoteForm.docTypeQuote) }
    private var docTypeRemisionButton: XCUIElement { element(A11y.QuoteForm.docTypeRemision) }
    private var ivaRow: XCUIElement { element(A11y.QuoteForm.ivaAmount) }
    private var cardFeeRow: XCUIElement { element(A11y.QuoteForm.cardFeeAmount) }
    private var totalLabel: XCUIElement { element(A11y.QuoteForm.total) }

    private var vehicleBrandField: XCUIElement { element(A11y.QuoteForm.vehicleBrand) }
    private var vehicleModelField: XCUIElement { element(A11y.QuoteForm.vehicleModel) }
    private var versionPill: XCUIElement { element(A11y.QuoteForm.versionPill) }
    private var yearField: XCUIElement { element(A11y.QuoteForm.yearField) }

    func templateChip(_ index: Int) -> XCUIElement { element(A11y.QuoteForm.templateChip(index)) }
    func lineItem(_ index: Int) -> XCUIElement { element(A11y.QuoteForm.lineItem(index)) }
    func deleteItem(_ index: Int) -> XCUIElement { element(A11y.QuoteForm.deleteItem(index)) }
    func makeChip(_ index: Int) -> XCUIElement { element(A11y.QuoteForm.makeChip(index)) }
    func modelChip(_ index: Int) -> XCUIElement { element(A11y.QuoteForm.modelChip(index)) }

    // MARK: Assertions

    @discardableResult
    func assertVisible() -> Self {
        assertExists(customerName, "Quote form did not appear")
    }

    /// The form keeps the keyboard up after typing; tap a neutral spot in the
    /// header (wired to dismiss the keyboard) to get it out of the way before
    /// reaching for controls lower on the screen.
    @discardableResult
    func dismissKeyboardIfNeeded() -> Self {
        guard app.keyboards.element.exists else { return self }
        // Empty area of the header title row, between the title and the folio.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.10)).tap()
        return self
    }

    @discardableResult
    func assertEmptyStateVisible() -> Self {
        assertExists(emptyState, "Expected the empty-conceptos state")
    }

    @discardableResult
    func assertLineItemCount(_ count: Int) -> Self {
        // Cards and their delete buttons both begin with "quoteForm.item.";
        // keep only the card identifiers.
        let cards = elements(prefix: "quoteForm.item.")
            .map { $0.identifier }
            .filter { !$0.hasSuffix(".delete") }
        XCTAssertEqual(cards.count, count, "Unexpected line-item count")
        return self
    }

    // MARK: Actions

    @discardableResult
    func fillCustomer(name: String, phone: String) -> Self {
        type(name, into: customerName)
        type(phone, into: customerPhone)
        return self
    }

    /// Note: `year` is now chosen via the year picker (see `openYearPicker`),
    /// so it is intentionally not typed here.
    @discardableResult
    func fillVehicle(brand: String, model: String, year: String = "", plate: String = "") -> Self {
        type(brand, into: vehicleBrand)
        type(model, into: vehicleModel)
        if !plate.isEmpty { type(plate, into: vehiclePlate) }
        return self
    }

    @discardableResult
    func addTemplate(at index: Int) -> Self {
        tap(templateChip(index))
    }

    /// Taps "+ Refacción" which opens the edit sheet for the new item.
    @discardableResult
    func tapAddPart() -> ItemEditRobot {
        dismissKeyboardIfNeeded()
        scrollToHittable(addPartButton)
        tap(addPartButton)
        return ItemEditRobot(app).assertVisible()
    }

    /// Taps "+ M. de obra" which opens the edit sheet for the new item.
    @discardableResult
    func tapAddLabor() -> ItemEditRobot {
        dismissKeyboardIfNeeded()
        scrollToHittable(addLaborButton)
        tap(addLaborButton)
        return ItemEditRobot(app).assertVisible()
    }

    @discardableResult
    func openItem(at index: Int) -> ItemEditRobot {
        tap(lineItem(index))
        return ItemEditRobot(app).assertVisible()
    }

    @discardableResult
    func deleteItem(at index: Int) -> Self {
        tap(deleteItem(index))
    }

    @discardableResult
    func enterNotes(_ text: String) -> Self {
        type(text, into: notes)
    }

    @discardableResult
    func tapGenerate() -> Self {
        dismissKeyboardIfNeeded()
        return tap(generateButton)
    }

    // MARK: Document type & totals

    @discardableResult
    func switchToRemision() -> Self {
        dismissKeyboardIfNeeded()
        scrollToTop()
        return tap(docTypeRemisionButton)
    }

    @discardableResult
    func switchToQuote() -> Self {
        dismissKeyboardIfNeeded()
        scrollToTop()
        return tap(docTypeQuoteButton)
    }

    @discardableResult
    func toggleIVA() -> Self {
        dismissKeyboardIfNeeded()
        scrollToHittable(ivaToggleButton)
        return tap(ivaToggleButton)
    }

    @discardableResult
    func toggleCardFee() -> Self {
        dismissKeyboardIfNeeded()
        scrollToHittable(cardFeeToggleButton)
        return tap(cardFeeToggleButton)
    }

    @discardableResult
    func openYearPicker() -> YearPickerRobot {
        dismissKeyboardIfNeeded()
        scrollToTop()
        tap(yearField)
        return YearPickerRobot(app)
    }

    @discardableResult
    func assertYear(_ expected: String) -> Self {
        waitFor(yearField)
        XCTAssertTrue(
            (yearField.label).contains(expected),
            "Expected year field to show \(expected), got \(yearField.label)"
        )
        return self
    }

    func currentTotalText() -> String {
        waitFor(totalLabel)
        return totalLabel.label
    }

    @discardableResult
    func assertTitle(_ title: String) -> Self {
        assertExists(app.staticTexts[title], "Expected header title \"\(title)\"")
    }

    @discardableResult
    func assertIvaRow(visible: Bool) -> Self {
        if visible {
            assertExists(ivaRow, "Expected IVA row to be visible")
        } else {
            assertNotExists(ivaRow, "Expected IVA row to be hidden")
        }
        return self
    }

    @discardableResult
    func assertCardFeeRow(visible: Bool) -> Self {
        if visible {
            assertExists(cardFeeRow, "Expected card-fee row to be visible")
        } else {
            assertNotExists(cardFeeRow, "Expected card-fee row to be hidden")
        }
        return self
    }

    // MARK: Vehicle catalog (pills + optional version)

    @discardableResult
    func tapMakeChip(_ index: Int) -> Self {
        dismissKeyboardIfNeeded()
        scrollToTop()
        return tap(makeChip(index))
    }

    @discardableResult
    func tapModelChip(_ index: Int) -> Self {
        dismissKeyboardIfNeeded()
        scrollToHittable(modelChip(index))
        return tap(modelChip(index))
    }

    @discardableResult
    func openVersionPicker() -> VersionPickerRobot {
        scrollToHittable(versionPill)
        tap(versionPill)
        return VersionPickerRobot(app).assertVisible()
    }

    @discardableResult
    func assertBrand(_ expected: String) -> Self {
        waitFor(vehicleBrandField)
        XCTAssertEqual(vehicleBrandField.value as? String, expected, "Unexpected Marca value")
        return self
    }

    @discardableResult
    func assertModel(_ expected: String) -> Self {
        waitFor(vehicleModelField)
        XCTAssertEqual(vehicleModelField.value as? String, expected, "Unexpected Modelo value")
        return self
    }

    @discardableResult
    func assertModelChipsVisible() -> Self {
        assertExists(modelChip(0), "Expected model pills after picking a make")
    }
}
