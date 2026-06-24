//
//  ItemEditRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the "Editar concepto" sheet.
//

import XCTest

final class ItemEditRobot: Robot {

    private var titleField: XCUIElement { element(A11y.ItemEdit.title) }
    private var detailField: XCUIElement { element(A11y.ItemEdit.detail) }
    private var quantityField: XCUIElement { element(A11y.ItemEdit.quantity) }
    private var unitPriceField: XCUIElement { element(A11y.ItemEdit.unitPrice) }
    private var doneButton: XCUIElement { element(A11y.ItemEdit.done) }
    private var cancelButton: XCUIElement { element(A11y.ItemEdit.cancel) }

    @discardableResult
    func assertVisible() -> Self {
        assertExists(titleField, "Item edit sheet did not appear")
    }

    @discardableResult
    func setTitle(_ text: String) -> Self {
        type(text, into: titleField, clearFirst: true)
    }

    @discardableResult
    func setDetail(_ text: String) -> Self {
        type(text, into: detailField)
    }

    @discardableResult
    func setQuantity(_ value: String) -> Self {
        type(value, into: quantityField, clearFirst: true)
    }

    @discardableResult
    func setUnitPrice(_ value: String) -> Self {
        type(value, into: unitPriceField, clearFirst: true)
    }

    /// Saves the sheet and returns to the quote form.
    @discardableResult
    func tapDone() -> QuoteFormRobot {
        tap(doneButton)
        return QuoteFormRobot(app)
    }

    @discardableResult
    func tapCancel() -> QuoteFormRobot {
        tap(cancelButton)
        return QuoteFormRobot(app)
    }
}
