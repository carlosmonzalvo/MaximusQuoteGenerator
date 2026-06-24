//
//  PDFPreviewRobot.swift
//  MaximusPrecisionUITests
//
//  Drives the generated-PDF preview screen.
//

import XCTest

final class PDFPreviewRobot: Robot {

    private var whatsAppButton: XCUIElement { app.buttons["WhatsApp"] }

    @discardableResult
    func assertVisible() -> Self {
        assertExists(whatsAppButton, "PDF preview did not appear")
    }

    @discardableResult
    func assertShareOptionsVisible() -> Self {
        assertExists(whatsAppButton, "Expected the WhatsApp share button")
    }
}
