//
//  XCUIApplication+Maximus.swift
//  MaximusPrecisionUITests
//
//  One place to launch the app in a deterministic, test-friendly state.
//

import XCTest

extension XCUIApplication {
    /// Launches the app configured for UI testing: the animated splash is
    /// skipped so tests land directly on the quote form.
    @discardableResult
    static func launchForTesting(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(LaunchArgument.uiTesting)
        app.launchArguments.append(contentsOf: extraArguments)
        app.launch()
        return app
    }
}
