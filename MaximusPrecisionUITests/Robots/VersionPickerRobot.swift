//
//  VersionPickerRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the optional version/trim picker sheet.
//

import XCTest

final class VersionPickerRobot: Robot {

    private var noneRow: XCUIElement { element(A11y.VersionPicker.none) }
    func trimRow(_ index: Int) -> XCUIElement { element(A11y.VersionPicker.trim(index)) }

    @discardableResult
    func assertVisible() -> Self {
        assertExists(noneRow, "Version picker did not appear")
    }

    @discardableResult
    func pickNone() -> QuoteFormRobot {
        tap(noneRow)
        return QuoteFormRobot(app)
    }

    @discardableResult
    func pickTrim(_ index: Int) -> QuoteFormRobot {
        tap(trimRow(index))
        return QuoteFormRobot(app)
    }
}
