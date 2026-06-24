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
