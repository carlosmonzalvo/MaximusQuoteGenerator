import UIKit

final class PDFGeneratorService {
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
        let fileName = "Cotizacion-\(quote.folio).pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        try renderer.writePDF(to: fileURL) { context in
            context.beginPage()

            if let watermark = UIImage(named: "logo_maximus") {
                let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
                
                let imageWidth: CGFloat = 500
                let imageHeight: CGFloat = 500
                
                let x = (pageBounds.width - imageWidth) / 2
                let y = (pageBounds.height - imageHeight) / 2
                
                let rect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
                
                watermark.draw(in: rect, blendMode: .normal, alpha: 0.08)
            }

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headerFont = UIFont.boldSystemFont(ofSize: 14)
            let bodyFont = UIFont.systemFont(ofSize: 11)
            let smallFont = UIFont.systemFont(ofSize: 10)

            var y: CGFloat = 32
            let left: CGFloat = 32
            let right: CGFloat = 580
            let width: CGFloat = right - left

            drawText("MAXIMUS PRECISION", font: titleFont, at: CGPoint(x: left, y: y))
            y += 30
            drawText("Cotización", font: headerFont, at: CGPoint(x: left, y: y))
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

            drawLine(from: CGPoint(x: left, y: tableTop), to: CGPoint(x: right, y: tableTop))
            drawText("Tipo", font: smallFont, at: CGPoint(x: col1 + 4, y: tableTop + 5))
            drawText("Concepto / Descripción", font: smallFont, at: CGPoint(x: col2 + 4, y: tableTop + 5))
            drawText("Cant.", font: smallFont, at: CGPoint(x: col3 + 4, y: tableTop + 5))
            drawText("P. Unit.", font: smallFont, at: CGPoint(x: col4 + 4, y: tableTop + 5))
            drawText("Total", font: smallFont, at: CGPoint(x: col5 + 4, y: tableTop + 5))
            drawLine(from: CGPoint(x: left, y: tableTop + rowHeight), to: CGPoint(x: right, y: tableTop + rowHeight))

            y = tableTop + rowHeight + 4

            for item in quote.items {
                let detail = "\(item.title)\n\(item.detail)"
                let detailHeight = detail.height(withConstrainedWidth: 232, font: bodyFont)
                let dynamicRowHeight = max(36, detailHeight + 8)

                if y + dynamicRowHeight + 80 > 792 {
                    context.beginPage()
                    y = 32
                }

                drawText(item.type.rawValue, font: smallFont, in: CGRect(x: col1 + 4, y: y, width: 90, height: dynamicRowHeight))
                drawText(detail, font: bodyFont, in: CGRect(x: col2 + 4, y: y, width: 232, height: dynamicRowHeight))
                drawText(numberString(item.quantity), font: smallFont, in: CGRect(x: col3 + 4, y: y, width: 70, height: dynamicRowHeight))
                drawText(currency(item.unitPrice), font: smallFont, in: CGRect(x: col4 + 4, y: y, width: 76, height: dynamicRowHeight))
                drawText(currency(item.total), font: smallFont, in: CGRect(x: col5 + 4, y: y, width: 76, height: dynamicRowHeight))
                drawLine(from: CGPoint(x: left, y: y + dynamicRowHeight), to: CGPoint(x: right, y: y + dynamicRowHeight))
                y += dynamicRowHeight
            }

            y += 18
            drawText("Total: \(currency(quote.total))", font: UIFont.boldSystemFont(ofSize: 16), at: CGPoint(x: 410, y: y))
            y += 32

            drawSectionTitle("Notas", y: &y, left: left, font: headerFont)
            drawParagraph(quote.notes.isEmpty ? "Sin observaciones." : quote.notes, y: &y, left: left, width: width, font: bodyFont)
            y += 24

            drawParagraph("Gracias por su preferencia.", y: &y, left: left, width: width, font: bodyFont)
        }

        return fileURL
    }

    private func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func numberString(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }

    private func drawSectionTitle(_ text: String, y: inout CGFloat, left: CGFloat, font: UIFont) {
        drawText(text, font: font, at: CGPoint(x: left, y: y))
        y += 20
    }

    private func drawParagraph(_ text: String, y: inout CGFloat, left: CGFloat, width: CGFloat, font: UIFont) {
        let rect = CGRect(x: left, y: y, width: width, height: 200)
        let height = text.height(withConstrainedWidth: width, font: font)
        drawText(text, font: font, in: CGRect(x: left, y: y, width: width, height: height + 4))
        y = rect.minY + height + 6
    }

    private func drawText(_ text: String, font: UIFont, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        text.draw(at: point, withAttributes: attributes)
    }

    private func drawText(_ text: String, font: UIFont, in rect: CGRect) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style
        ]
        text.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }

    private func drawLine(from start: CGPoint, to end: CGPoint) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        UIColor.black.setStroke()
        path.lineWidth = 0.6
        path.stroke()
    }
}

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
