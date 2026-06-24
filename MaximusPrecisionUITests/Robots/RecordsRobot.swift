//
//  RecordsRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the Expedientes tab (clients / vehicles) and the add sheet.
//

import XCTest

final class RecordsRobot: Robot {

    private var root: XCUIElement { element(A11y.Records.root) }
    private var scopePicker: XCUIElement { element(A11y.Records.scopePicker) }
    private var addButton: XCUIElement { element(A11y.Records.add) }
    private var emptyState: XCUIElement { element(A11y.Records.emptyState) }

    // Add sheet
    private var nameField: XCUIElement { element(A11y.RecordEdit.name) }
    private var phoneField: XCUIElement { element(A11y.RecordEdit.phone) }
    private var plateField: XCUIElement { element(A11y.RecordEdit.plate) }
    private var brandField: XCUIElement { element(A11y.RecordEdit.brand) }
    private var modelField: XCUIElement { element(A11y.RecordEdit.model) }
    private var saveButton: XCUIElement { element(A11y.RecordEdit.save) }

    // MARK: Navigation

    @discardableResult
    func open() -> Self {
        app.tabBars.buttons["Expedientes"].firstMatch.tap()
        return assertExists(root, "Records screen did not appear")
    }

    @discardableResult
    func selectClients() -> Self {
        app.buttons["Clientes"].firstMatch.tap()
        return self
    }

    @discardableResult
    func selectVehicles() -> Self {
        app.buttons["Autos"].firstMatch.tap()
        return self
    }

    // MARK: Add flows

    @discardableResult
    func addClient(name: String, phone: String) -> Self {
        tap(addButton)
        type(name, into: nameField)
        type(phone, into: phoneField)
        tap(saveButton)
        return self
    }

    @discardableResult
    func addVehicle(plate: String, brand: String, model: String) -> Self {
        tap(addButton)
        type(plate, into: plateField)
        type(brand, into: brandField)
        type(model, into: modelField)
        tap(saveButton)
        return self
    }

    @discardableResult
    func tapVehicleRow(_ index: Int) -> Self {
        tap(element(A11y.Records.vehicleRow(index)))
        return self
    }

    @discardableResult
    func openSync() -> Self {
        tap(element(A11y.Records.sync))
        // Wait for the sheet to finish presenting before callers snapshot.
        _ = element(A11y.Sync.enableToggle).waitForExistence(timeout: 8)
        return self
    }

    /// Enables sync and triggers a pass against the live backend (best-effort).
    @discardableResult
    func runSync() -> Self {
        let toggle = element(A11y.Sync.enableToggle)
        if toggle.waitForExistence(timeout: 5), (toggle.value as? String) != "1" {
            toggle.tap()
        }
        let button = element(A11y.Sync.syncNow)
        if button.waitForExistence(timeout: 5) { button.tap() }
        // Give the network round trip a moment to land in the history.
        _ = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Enviados' OR label CONTAINS[c] 'Recibidos'")
        ).firstMatch.waitForExistence(timeout: 15)
        return self
    }

    /// iOS 26 only: activate the Liquid Glass search-role tab and type a query.
    /// Best-effort — silently no-ops if the search affordance isn't present.
    @discardableResult
    func searchInTabBar(_ query: String) -> Self {
        let searchTab = app.tabBars.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Search' OR label CONTAINS[c] 'Buscar'")
        ).firstMatch
        if searchTab.waitForExistence(timeout: 5) {
            searchTab.tap()
        }
        let field = app.searchFields.firstMatch
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText(query)
        }
        return self
    }
}
