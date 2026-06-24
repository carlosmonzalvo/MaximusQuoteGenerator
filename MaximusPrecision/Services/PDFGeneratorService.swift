//
//  PDFGeneratorService.swift
//  MaximusPrecision
//
//  Cross-platform (iOS + macOS) PDF generation. Draws with Core Graphics into a
//  PDF-backed context so the same layout code runs on both platforms. Text is
//  laid out top-left (the context is flipped to match) using NSAttributedString,
//  which is available on both AppKit and UIKit.
//

import Foundation
import CoreGraphics
import CoreText

#if os(macOS)
import AppKit
typealias PlatformFont = NSFont
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformFont = UIFont
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
#endif

final class PDFGeneratorService {
    private let pageWidth: CGFloat = 612
    private let pageHeight: CGFloat = 792

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func generatePDF(for quote: Quote) throws -> URL {
        let fileName = "\(quote.documentType.fileNamePrefix)-\(quote.folio).pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let consumer = CGDataConsumer(url: fileURL as CFURL),
              let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw PDFError.couldNotCreateContext
        }

        beginPage(ctx)
        draw(quote: quote, in: ctx)
        endPage(ctx)
        ctx.closePDF()

        return fileURL
    }

    // MARK: Page lifecycle

    private func beginPage(_ ctx: CGContext) {
        var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        ctx.beginPage(mediaBox: &box)
        // Flip to a top-left origin so the layout math reads naturally.
        ctx.translateBy(x: 0, y: pageHeight)
        ctx.scaleBy(x: 1, y: -1)
        pushGraphics(ctx)
    }

    private func endPage(_ ctx: CGContext) {
        popGraphics()
        ctx.endPage()
    }

    private func newPage(_ ctx: CGContext) {
        endPage(ctx)
        beginPage(ctx)
    }

    private func pushGraphics(_ ctx: CGContext) {
        #if os(macOS)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)
        #else
        UIGraphicsPushContext(ctx)
        #endif
    }

    private func popGraphics() {
        #if os(macOS)
        NSGraphicsContext.restoreGraphicsState()
        #else
        UIGraphicsPopContext()
        #endif
    }

    // MARK: Layout

    private func draw(quote: Quote, in ctx: CGContext) {
        let titleFont = PlatformFont.boldSystemFont(ofSize: 24)
        let headerFont = PlatformFont.boldSystemFont(ofSize: 14)
        let bodyFont = PlatformFont.systemFont(ofSize: 11)
        let smallFont = PlatformFont.systemFont(ofSize: 10)

        let left: CGFloat = 32
        let right: CGFloat = 580
        let width: CGFloat = right - left
        var y: CGFloat = 32

        drawWatermark()

        drawText("MAXIMUS PRECISION", font: titleFont, at: CGPoint(x: left, y: y))
        y += 30
        drawText(quote.documentType.title, font: headerFont, at: CGPoint(x: left, y: y))
        y += 22

        drawText("Folio: \(quote.folio)", font: bodyFont, at: CGPoint(x: left, y: y))
        drawText("Fecha: \(dateFormatter.string(from: quote.date))", font: bodyFont, at: CGPoint(x: 380, y: y))
        y += 26

        drawSectionTitle("Cliente", y: &y, left: left, font: headerFont)
        drawParagraph("Nombre: \(quote.customer.name)", y: &y, left: left, width: width, font: bodyFont)
        drawParagraph("Teléfono: \(quote.customer.phone.isEmpty ? "-" : quote.customer.phone)", y: &y, left: left, width: width, font: bodyFont)
        y += 10

        drawSectionTitle("Vehículo", y: &y, left: left, font: headerFont)
        drawParagraph("Marca: \(quote.vehicle.brand)", y: &y, left: left, width: width, font: bodyFont)
        drawParagraph("Modelo: \(quote.vehicle.model)", y: &y, left: left, width: width, font: bodyFont)
        drawParagraph("Año: \(quote.vehicle.year.isEmpty ? "-" : quote.vehicle.year)", y: &y, left: left, width: width, font: bodyFont)
        drawParagraph("Placas: \(quote.vehicle.plate.isEmpty ? "-" : quote.vehicle.plate)", y: &y, left: left, width: width, font: bodyFont)
        y += 14

        drawSectionTitle("Conceptos", y: &y, left: left, font: headerFont)

        let tableTop = y
        let col1: CGFloat = left
        let col2: CGFloat = 100
        let col3: CGFloat = 342
        let col4: CGFloat = 420
        let col5: CGFloat = 500
        let rowHeight: CGFloat = 22

        drawLine(from: CGPoint(x: left, y: tableTop), to: CGPoint(x: right, y: tableTop), in: ctx)
        drawText("Tipo", font: smallFont, at: CGPoint(x: col1 + 4, y: tableTop + 5))
        drawText("Concepto / Descripción", font: smallFont, at: CGPoint(x: col2 + 4, y: tableTop + 5))
        drawText("Cant.", font: smallFont, at: CGPoint(x: col3 + 4, y: tableTop + 5))
        drawText("P. Unit.", font: smallFont, at: CGPoint(x: col4 + 4, y: tableTop + 5))
        drawText("Total", font: smallFont, at: CGPoint(x: col5 + 4, y: tableTop + 5))
        drawLine(from: CGPoint(x: left, y: tableTop + rowHeight), to: CGPoint(x: right, y: tableTop + rowHeight), in: ctx)

        y = tableTop + rowHeight + 4

        for item in quote.items {
            let detail = "\(item.title)\n\(item.detail)"
            let detailHeight = detail.height(withConstrainedWidth: 232, font: bodyFont)
            let dynamicRowHeight = max(36, detailHeight + 8)

            if y + dynamicRowHeight + 80 > pageHeight {
                newPage(ctx)
                y = 32
            }

            drawText(item.type.rawValue, font: smallFont, in: CGRect(x: col1 + 4, y: y, width: 90, height: dynamicRowHeight))
            drawText(detail, font: bodyFont, in: CGRect(x: col2 + 4, y: y, width: 232, height: dynamicRowHeight))
            drawText(numberString(item.quantity), font: smallFont, in: CGRect(x: col3 + 4, y: y, width: 70, height: dynamicRowHeight))
            drawText(currency(item.unitPrice), font: smallFont, in: CGRect(x: col4 + 4, y: y, width: 76, height: dynamicRowHeight))
            drawText(currency(item.total), font: smallFont, in: CGRect(x: col5 + 4, y: y, width: 76, height: dynamicRowHeight))
            drawLine(from: CGPoint(x: left, y: y + dynamicRowHeight), to: CGPoint(x: right, y: y + dynamicRowHeight), in: ctx)
            y += dynamicRowHeight
        }

        y += 14
        let totalsLabelX: CGFloat = 360
        let totalsValueX: CGFloat = 470

        drawText("Subtotal:", font: bodyFont, at: CGPoint(x: totalsLabelX, y: y))
        drawText(currency(quote.subtotal), font: bodyFont, at: CGPoint(x: totalsValueX, y: y))
        y += 18

        if quote.includesIVA {
            drawText("IVA (16%):", font: bodyFont, at: CGPoint(x: totalsLabelX, y: y))
            drawText(currency(quote.ivaAmount), font: bodyFont, at: CGPoint(x: totalsValueX, y: y))
            y += 18
        }

        if quote.includesCardFee {
            drawText("Comisión tarjeta (4.5%):", font: bodyFont, at: CGPoint(x: totalsLabelX - 70, y: y))
            drawText(currency(quote.cardFeeAmount), font: bodyFont, at: CGPoint(x: totalsValueX, y: y))
            y += 18
        }

        drawLine(from: CGPoint(x: totalsLabelX, y: y + 2), to: CGPoint(x: right, y: y + 2), in: ctx)
        y += 8
        drawText("Total:", font: PlatformFont.boldSystemFont(ofSize: 16), at: CGPoint(x: totalsLabelX, y: y))
        drawText(currency(quote.total), font: PlatformFont.boldSystemFont(ofSize: 16), at: CGPoint(x: totalsValueX, y: y))
        y += 32

        drawSectionTitle("Notas", y: &y, left: left, font: headerFont)
        drawParagraph(quote.notes.isEmpty ? "Sin observaciones." : quote.notes, y: &y, left: left, width: width, font: bodyFont)
        y += 24

        drawParagraph("Gracias por su preferencia.", y: &y, left: left, width: width, font: bodyFont)
    }

    // MARK: Drawing primitives

    private func drawWatermark() {
        guard let watermark = PlatformImage(named: "logo_maximus") else { return }
        let size: CGFloat = 500
        let rect = CGRect(x: (pageWidth - size) / 2, y: (pageHeight - size) / 2, width: size, height: size)
        #if os(macOS)
        watermark.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 0.08)
        #else
        watermark.draw(in: rect, blendMode: .normal, alpha: 0.08)
        #endif
    }

    private func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func numberString(_ value: Double) -> String {
        value == floor(value) ? String(Int(value)) : String(format: "%.2f", value)
    }

    private func drawSectionTitle(_ text: String, y: inout CGFloat, left: CGFloat, font: PlatformFont) {
        drawText(text, font: font, at: CGPoint(x: left, y: y))
        y += 20
    }

    private func drawParagraph(_ text: String, y: inout CGFloat, left: CGFloat, width: CGFloat, font: PlatformFont) {
        let height = text.height(withConstrainedWidth: width, font: font)
        drawText(text, font: font, in: CGRect(x: left, y: y, width: width, height: height + 4))
        y += height + 6
    }

    private func drawText(_ text: String, font: PlatformFont, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        NSAttributedString(string: text, attributes: attributes).draw(at: point)
    }

    private func drawText(_ text: String, font: PlatformFont, in rect: CGRect) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: style]
        NSAttributedString(string: text, attributes: attributes).draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }

    private func drawLine(from start: CGPoint, to end: CGPoint, in ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(PlatformColor.black.cgColor)
        ctx.setLineWidth(0.6)
        ctx.move(to: start)
        ctx.addLine(to: end)
        ctx.strokePath()
        ctx.restoreGState()
    }

    enum PDFError: Error { case couldNotCreateContext }
}

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: PlatformFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = NSAttributedString(string: self, attributes: [.font: font]).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
