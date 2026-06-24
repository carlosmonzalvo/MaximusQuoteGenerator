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
}
