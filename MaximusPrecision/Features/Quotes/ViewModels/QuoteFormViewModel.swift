import Foundation

@MainActor
final class QuoteFormViewModel: ObservableObject {
    @Published var customerName: String = ""
    @Published var customerPhone: String = ""

    @Published var vehicleBrand: String = ""
    @Published var vehicleModel: String = ""
    @Published var vehicleYear: String = ""
    @Published var vehiclePlate: String = ""

    @Published var items: [QuoteItem] = []
    @Published var notes: String = ""

    @Published var documentType: DocumentType = .quote
    @Published var includesIVA: Bool = false
    @Published var includesCardFee: Bool = false

    @Published var showError = false
    @Published var errorMessage = ""

    /// Generated once and reused for both the on-screen header and the PDF so
    /// the folio shown to the user always matches the document.
    let folio = String(UUID().uuidString.prefix(8)).uppercased()

    private let calculator = QuoteCalculatorService()

    var subtotal: Double {
        calculator.subtotal(items: items)
    }

    var ivaAmount: Double {
        calculator.iva(subtotal: subtotal, enabled: includesIVA)
    }

    var cardFeeAmount: Double {
        calculator.cardFee(base: subtotal + ivaAmount, enabled: includesCardFee)
    }

    var total: Double {
        subtotal + ivaAmount + cardFeeAmount
    }

    func toggleIVA() { includesIVA.toggle() }
    func toggleCardFee() { includesCardFee.toggle() }

    func addPart() {
        items.append(QuoteItem(type: .part))
    }

    func addLabor() {
        items.append(QuoteItem(type: .labor))
    }

    func addTemplate(_ template: QuoteTemplate) {
        items.append(
            QuoteItem(
                type: template.type,
                title: template.title,
                detail: template.detail,
                quantity: 1,
                unitPrice: 0
            )
        )
    }

    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func buildQuote() -> Quote? {
        guard !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Agrega el nombre del cliente."
            showError = true
            return nil
        }

        guard !vehicleBrand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !vehicleModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Agrega al menos marca y modelo del vehículo."
            showError = true
            return nil
        }

        guard !items.isEmpty else {
            errorMessage = "Agrega al menos un concepto a la cotización."
            showError = true
            return nil
        }

        return Quote(
            folio: folio,
            date: Date(),
            documentType: documentType,
            customer: Customer(name: customerName, phone: customerPhone),
            vehicle: Vehicle(
                brand: vehicleBrand,
                model: vehicleModel,
                year: vehicleYear,
                plate: vehiclePlate
            ),
            items: items,
            notes: notes,
            includesIVA: includesIVA,
            includesCardFee: includesCardFee
        )
    }
}
