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
        formatter.dateFormat = "d 'de' MMMM, yyyy"
        return formatter
    }()

    // MARK: - Styles

    private let colors = (
        gray: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
        lightGray: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0),
        black: UIColor.black,
        partBlue: UIColor(red: 0.48, green: 0.72, blue: 0.91, alpha: 1.0), // #7ab8e8
        laborGreen: UIColor(red: 0.43, green: 0.81, blue: 0.43, alpha: 1.0) // #6dcf6d
    )

    private let fonts = (
        title: UIFont.boldSystemFont(ofSize: 16),
        subtitle: UIFont.systemFont(ofSize: 9),
        folio: UIFont.boldSystemFont(ofSize: 13),
        date: UIFont.systemFont(ofSize: 9),
        label: UIFont.systemFont(ofSize: 8),
        body: UIFont.systemFont(ofSize: 11),
        total: UIFont.boldSystemFont(ofSize: 14),
        footer: UIFont.systemFont(ofSize: 8)
    )

    func generatePDF(for quote: Quote) throws -> URL {
        let fileName = "Cotizacion-\(quote.folio).pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        try renderer.writePDF(to: fileURL) { context in
            context.beginPage()
            let pageWidth = context.pdfContextBounds.width
            let leftMargin: CGFloat = 40
            let rightMargin: CGFloat = pageWidth - 40
            let contentWidth = rightMargin - leftMargin
            var y: CGFloat = 40

            // 1. Watermark
            if let watermark = UIImage(named: "logo_maximus") {
                let size: CGFloat = 450
                let rect = CGRect(x: (pageWidth - size) / 2, y: (792 - size) / 2, width: size, height: size)
                watermark.draw(in: rect, blendMode: .normal, alpha: 0.08)
            }

            // 2. Header
            drawHeader(quote: quote, y: &y, left: leftMargin, right: rightMargin)
            y += 30

            // 3. Client & Vehicle Info (Two columns)
            drawInfoGrid(quote: quote, y: &y, left: leftMargin, width: contentWidth)
            y += 30

            // 4. Items Table
            drawItemsTable(items: quote.items, y: &y, left: leftMargin, width: contentWidth, context: context)
            y += 20

            // 5. Totals
            drawTotals(quote: quote, y: &y, right: rightMargin)
            
            // 6. Notes
            if !quote.notes.isEmpty {
                y += 20
                drawText("NOTAS", font: fonts.label, color: colors.gray, at: CGPoint(x: leftMargin, y: y))
                y += 12
                drawParagraph(quote.notes, y: &y, left: leftMargin, width: contentWidth, font: fonts.body)
            }

            // 7. Footer
            drawFooter(y: 750, width: pageWidth)
        }

        return fileURL
    }

    // MARK: - Drawing Helpers

    private func drawHeader(quote: Quote, y: inout CGFloat, left: CGFloat, right: CGFloat) {
        // Left side
        drawText("MAXIMUS PRECISION", font: fonts.title, color: colors.black, at: CGPoint(x: left, y: y))
        drawText("Taller Automotriz", font: fonts.subtitle, color: colors.gray, at: CGPoint(x: left, y: y + 18))

        // Right side
        let folioText = "#\(quote.folio)"
        let folioSize = folioText.size(withAttributes: [.font: fonts.folio])
        drawText(folioText, font: fonts.folio, color: colors.black, at: CGPoint(x: right - folioSize.width, y: y))
        
        let dateText = dateFormatter.string(from: quote.date)
        let dateSize = dateText.size(withAttributes: [.font: fonts.date])
        drawText(dateText, font: fonts.date, color: colors.gray, at: CGPoint(x: right - dateSize.width, y: y + 18))

        y += 40
        drawLine(from: CGPoint(x: left, y: y), to: CGPoint(x: right, y: y), width: 2.0, color: colors.black)
    }

    private func drawInfoGrid(quote: Quote, y: inout CGFloat, left: CGFloat, width: CGFloat) {
        let colWidth = width / 2
        let startY = y
        
        // Column 1: Client
        var clientY = startY
        drawField(label: "CLIENTE", value: quote.customer.name, y: &clientY, x: left, width: colWidth)
        drawField(label: "TELÉFONO", value: quote.customer.phone.isEmpty ? "-" : quote.customer.phone, y: &clientY, x: left, width: colWidth)

        // Column 2: Vehicle
        var vehicleY = startY
        let vehicleX = left + colWidth
        drawField(label: "VEHÍCULO", value: "\(quote.vehicle.brand) \(quote.vehicle.model) (\(quote.vehicle.year))", y: &vehicleY, x: vehicleX, width: colWidth)
        drawField(label: "PLACAS", value: quote.vehicle.plate.isEmpty ? "-" : quote.vehicle.plate, y: &vehicleY, x: vehicleX, width: colWidth)
        
        y = max(clientY, vehicleY)
    }

    private func drawField(label: String, value: String, y: inout CGFloat, x: CGFloat, width: CGFloat) {
        drawText(label.uppercased(), font: fonts.label, color: colors.gray, at: CGPoint(x: x, y: y))
        y += 10
        drawText(value, font: fonts.body, color: colors.black, at: CGPoint(x: x, y: y))
        y += 20
    }

    private func drawItemsTable(items: [QuoteItem], y: inout CGFloat, left: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext) {
        let cols = (desc: left + 20, cant: left + width - 180, unit: left + width - 110, total: left + width - 50)
        
        // Header
        drawText("DESCRIPCIÓN", font: fonts.label, color: colors.gray, at: CGPoint(x: left, y: y))
        drawText("CANT", font: fonts.label, color: colors.gray, at: CGPoint(x: cols.cant, y: y))
        drawText("P. UNIT", font: fonts.label, color: colors.gray, at: CGPoint(x: cols.unit, y: y))
        drawText("TOTAL", font: fonts.label, color: colors.gray, at: CGPoint(x: cols.total, y: y))
        y += 16

        for (index, item) in items.enumerated() {
            let detailText = item.detail.isEmpty ? item.title : "\(item.title)\n\(item.detail)"
            let detailHeight = detailText.height(withConstrainedWidth: cols.cant - cols.desc - 10, font: fonts.body)
            let rowHeight = max(30, detailHeight + 12)

            // Page break check
            if y + rowHeight > 720 {
                context.beginPage()
                y = 40
                // Re-draw watermark on new page
                if let watermark = UIImage(named: "logo_maximus") {
                    let size: CGFloat = 450
                    let rect = CGRect(x: (context.pdfContextBounds.width - size) / 2, y: (792 - size) / 2, width: size, height: size)
                    watermark.draw(in: rect, blendMode: .normal, alpha: 0.08)
                }
            }

            // Alternating background
            if index % 2 != 0 {
                let bgRect = CGRect(x: left - 10, y: y - 4, width: width + 20, height: rowHeight)
                colors.lightGray.set()
                UIRectFill(bgRect)
            }

            // Colored Dot
            let dotColor = item.type == .part ? colors.partBlue : colors.laborGreen
            drawDot(at: CGPoint(x: left + 5, y: y + 6), color: dotColor)

            // Row text
            drawText(detailText, font: fonts.body, color: colors.black, in: CGRect(x: cols.desc, y: y, width: cols.cant - cols.desc - 10, height: rowHeight))
            
            let qty = numberString(item.quantity)
            drawText(qty, font: fonts.body, color: colors.black, at: CGPoint(x: cols.cant, y: y))
            
            let unit = currency(item.unitPrice)
            drawText(unit, font: fonts.body, color: colors.black, at: CGPoint(x: cols.unit, y: y))
            
            let total = currency(item.total)
            drawText(total, font: fonts.body, color: colors.black, at: CGPoint(x: cols.total, y: y))

            y += rowHeight
        }
    }

    private func drawTotals(quote: Quote, y: inout CGFloat, right: CGFloat) {
        let partsTotal = quote.items.filter { $0.type == .part }.reduce(0) { $0 + $1.total }
        let laborTotal = quote.items.filter { $0.type == .labor }.reduce(0) { $0 + $1.total }
        
        let labelX = right - 180
        let valX = right - 60

        if partsTotal > 0 {
            drawText("Subtotal Refacciones:", font: fonts.body, color: colors.gray, at: CGPoint(x: labelX, y: y))
            drawText(currency(partsTotal), font: fonts.body, color: colors.black, at: CGPoint(x: valX, y: y))
            y += 18
        }
        
        if laborTotal > 0 {
            drawText("Subtotal Mano de Obra:", font: fonts.body, color: colors.gray, at: CGPoint(x: labelX, y: y))
            drawText(currency(laborTotal), font: fonts.body, color: colors.black, at: CGPoint(x: valX, y: y))
            y += 18
        }

        y += 10
        drawLine(from: CGPoint(x: labelX, y: y), to: CGPoint(x: right, y: y), width: 2.0, color: colors.black)
        y += 8
        
        drawText("TOTAL", font: fonts.total, color: colors.black, at: CGPoint(x: labelX, y: y))
        let totalVal = currency(quote.total)
        drawText(totalVal, font: fonts.total, color: colors.black, at: CGPoint(x: valX, y: y))
        y += 30
    }

    private func drawFooter(y: CGFloat, width: CGFloat) {
        let text = "Esta cotización tiene vigencia de 15 días"
        let size = text.size(withAttributes: [.font: fonts.footer])
        drawText(text, font: fonts.footer, color: colors.gray, at: CGPoint(x: (width - size.width) / 2, y: y))
    }

    // MARK: - Basic Graphics

    private func drawText(_ text: String, font: UIFont, color: UIColor, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        text.draw(at: point, withAttributes: attributes)
    }

    private func drawText(_ text: String, font: UIFont, color: UIColor, in rect: CGRect) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: style]
        text.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }

    private func drawLine(from start: CGPoint, to end: CGPoint, width: CGFloat, color: UIColor) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        color.setStroke()
        path.lineWidth = width
        path.stroke()
    }

    private func drawDot(at point: CGPoint, color: UIColor) {
        let dot = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 6, height: 6))
        color.setFill()
        dot.fill()
    }

    private func drawParagraph(_ text: String, y: inout CGFloat, left: CGFloat, width: CGFloat, font: UIFont) {
        let height = text.height(withConstrainedWidth: width, font: font)
        drawText(text, font: font, color: colors.black, in: CGRect(x: left, y: y, width: width, height: height + 4))
        y += height + 10
    }

    private func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func numberString(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
