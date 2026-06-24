import Foundation
import SwiftData

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

    // Vehicle catalog state (owned by the VM, not the view).
    @Published var makeNames: [String] = []
    @Published var modelOptions: [ModelOption] = []
    @Published var selectedModel: ModelOption?

    // Chip "Ver más" expansion. The catalog has grown a lot, so the make/model
    // rows show a preview first and reveal the rest on demand.
    @Published var showAllMakes = false
    @Published var showAllModels = false

    /// How many chips to show before the "Ver más" button.
    let makesPreviewCount = 6
    let modelsPreviewCount = 8

    var visibleMakeNames: [String] {
        showAllMakes ? makeNames : Array(makeNames.prefix(makesPreviewCount))
    }

    var hasMoreMakes: Bool { !showAllMakes && makeNames.count > makesPreviewCount }

    var visibleModelOptions: [ModelOption] {
        showAllModels ? modelOptions : Array(modelOptions.prefix(modelsPreviewCount))
    }

    var hasMoreModels: Bool { !showAllModels && modelOptions.count > modelsPreviewCount }

    func showMoreMakes() { showAllMakes = true }
    func showMoreModels() { showAllModels = true }

    /// Generated once and reused for both the on-screen header and the PDF so
    /// the folio shown to the user always matches the document.
    let folio = String(UUID().uuidString.prefix(8)).uppercased()

    private let calculator = QuoteCalculatorService()
    private var catalog: VehicleCatalog?

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

    // MARK: Vehicle catalog

    /// Wires up the catalog (seeding on first run) and loads the make list.
    /// Call once with the SwiftData context from the environment.
    func loadCatalog(context: ModelContext) {
        guard catalog == nil else { return }
        let catalog = VehicleCatalog(context: context)
        catalog.seedIfNeeded()
        self.catalog = catalog
        makeNames = catalog.makes()
    }

    func selectMake(_ name: String) {
        vehicleBrand = name
        vehicleModel = ""
        selectedModel = nil
        showAllModels = false
        modelOptions = catalog?.models(forMake: name) ?? []
    }

    func selectModel(_ option: ModelOption) {
        selectedModel = option
        vehicleModel = option.name
    }

    /// Applies the optional trim/version to the selected model.
    func applyVersion(_ trim: String?) {
        guard let model = selectedModel else { return }
        vehicleModel = trim.map { "\(model.name) \($0)" } ?? model.name
    }

    // MARK: Year range

    /// Catalog floor — models earlier than this are out of scope.
    let catalogStartYear = 2015

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    /// Lower bound for the year picker: the model's first year when known,
    /// otherwise the catalog floor.
    func minYear(forModelYearStart yearStart: Int?) -> Int {
        max(catalogStartYear, yearStart ?? catalogStartYear)
    }

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
