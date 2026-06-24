//
//  Robot.swift
//  MaximusPrecisionUITests
//
//  Base class for the Robot Pattern: every screen gets a Robot that exposes
//  intent-level actions ("fill customer", "tap generate") and assertions,
//  hiding XCUIElement lookups from the test bodies. Each action returns Self
//  so tests read as fluent chains.
//

import XCTest

class Robot {
    let app: XCUIApplication
    /// Default wait used by every element interaction.
    let defaultTimeout: TimeInterval = 8

    init(_ app: XCUIApplication) {
        self.app = app
    }

    /// Resolves an element by accessibility identifier regardless of the concrete
    /// element type SwiftUI exposed it as (button / other / text field / …).
    /// Uses `firstMatch` because SwiftUI sometimes mirrors an identifier onto
    /// both a control and its inner label.
    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// All elements whose identifier begins with `prefix` (e.g. line-item cards).
    func elements(prefix: String) -> [XCUIElement] {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        let query = app.descendants(matching: .any).matching(predicate)
        return (0..<query.count).map { query.element(boundBy: $0) }
    }

    // MARK: - Generic interactions

    @discardableResult
    func tap(
        _ element: XCUIElement,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        waitFor(element, timeout: timeout, file: file, line: line)
        element.tap()
        return self
    }

    @discardableResult
    func type(
        _ text: String,
        into element: XCUIElement,
        clearFirst: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        waitFor(element, file: file, line: line)
        element.tap()
        if clearFirst, let current = element.value as? String, !current.isEmpty {
            element.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        element.typeText(text)
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertExists(
        _ element: XCUIElement,
        _ message: String = "",
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout ?? defaultTimeout),
            message.isEmpty ? "Expected element to exist: \(element)" : message,
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func assertNotExists(
        _ element: XCUIElement,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        XCTAssertFalse(
            element.exists,
            message.isEmpty ? "Expected element to be absent: \(element)" : message,
            file: file,
            line: line
        )
        return self
    }

    // MARK: - Helpers

    func waitFor(
        _ element: XCUIElement,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout ?? defaultTimeout),
            "Timed out waiting for element: \(element)",
            file: file,
            line: line
        )
    }

    /// Scrolls down until the element is hittable (or we run out of tries).
    @discardableResult
    func scrollToHittable(_ element: XCUIElement, maxSwipes: Int = 8) -> Self {
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
        return self
    }

    /// Scrolls back to the top of the form.
    @discardableResult
    func scrollToTop(_ times: Int = 5) -> Self {
        for _ in 0..<times { app.swipeDown() }
        return self
    }

    /// Dismiss the software keyboard if it is showing (tap a neutral area).
    @discardableResult
    func dismissKeyboard() -> Self {
        if app.keyboards.element.exists {
            app.toolbars.buttons["Done"].firstMatch.tap()
        }
        return self
    }
}
