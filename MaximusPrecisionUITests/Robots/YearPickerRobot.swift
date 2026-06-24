//
//  YearPickerRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the year picker sheet.
//

import XCTest

final class YearPickerRobot: Robot {

    func yearCell(_ index: Int) -> XCUIElement { element(A11y.YearPicker.year(index)) }

    @discardableResult
    func assertVisible() -> Self {
        assertExists(yearCell(0), "Year picker did not appear")
    }

    /// Flips the "más de 10 años" flag to reveal manual year entry.
    @discardableResult
    func enableManualEntry() -> Self {
        tap(element(A11y.YearPicker.manualToggle))
        return assertExists(element(A11y.YearPicker.manualField), "Manual year field did not appear")
    }

    /// Picks the year at `index` (0 = newest) and returns its label.
    @discardableResult
    func pickYear(_ index: Int) -> (robot: QuoteFormRobot, year: String) {
        let cell = yearCell(index)
        waitFor(cell)
        let year = cell.label
        cell.tap()
        return (QuoteFormRobot(app), year)
    }
}
