import SwiftUI

struct QuoteFormView: View {
    @StateObject private var viewModel = QuoteFormViewModel()
    @State private var generatedPDFURL: URL?
    @State private var showPDFPreview = false

    private let pdfGenerator = PDFGeneratorService()

    var body: some View {
        NavigationStack {
            Form {
                clientSection
                vehicleSection
                templatesSection
                itemsSection
                notesSection
                summarySection
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Nueva cotización")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("PDF") {
                        generatePDF()
                    }
                }
            }
            .alert("Aviso", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .navigationDestination(isPresented: $showPDFPreview) {
                if let url = generatedPDFURL {
                    PDFPreviewView(url: url)
                }
            }
        }
    }

    private var clientSection: some View {
        Section("Cliente") {
            TextField("Nombre", text: $viewModel.customerName)
            TextField("Teléfono", text: $viewModel.customerPhone)
                .keyboardType(.phonePad)
        }
    }

    private var vehicleSection: some View {
        Section("Vehículo") {
            TextField("Marca", text: $viewModel.vehicleBrand)
            TextField("Modelo", text: $viewModel.vehicleModel)
            TextField("Año", text: $viewModel.vehicleYear)
                .keyboardType(.numberPad)
            TextField("Placas", text: $viewModel.vehiclePlate)
                .textInputAutocapitalization(.characters)
        }
    }

    private var templatesSection: some View {
        Section("Plantillas rápidas") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(defaultTemplates) { template in
                        Button {
                            viewModel.addTemplate(template)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.title)
                                    .font(.subheadline.weight(.semibold))
                                    .multilineTextAlignment(.leading)
                                Text(template.type.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(10)
                            .frame(width: 180, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var itemsSection: some View {
        Section("Conceptos") {
            if viewModel.items.isEmpty {
                Text("Agrega una refacción, mano de obra o una plantilla.")
                    .foregroundStyle(.secondary)
            }

            ForEach($viewModel.items) { $item in
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Tipo", selection: $item.type) {
                        ForEach(QuoteItemType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Concepto", text: $item.title)
                    TextField("Descripción", text: $item.detail, axis: .vertical)
                        .lineLimit(2...4)

                    HStack {
                        TextField("Cantidad", value: $item.quantity, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Costo unitario", value: $item.unitPrice, format: .number)
                            .keyboardType(.decimalPad)
                    }

                    Text("Total: \(item.total, format: .currency(code: "MXN"))")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 6)
            }
            .onDelete(perform: viewModel.removeItem)

            HStack {
                Button {
                    viewModel.addPart()
                } label: {
                    Label("Agregar refacción", systemImage: "wrench.and.screwdriver")
                }

                Spacer()

                Button {
                    viewModel.addLabor()
                } label: {
                    Label("Agregar mano de obra", systemImage: "hammer")
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Notas") {
            TextField("Observaciones", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var summarySection: some View {
        Section("Resumen") {
            HStack {
                Text("Subtotal")
                Spacer()
                Text(viewModel.subtotal, format: .currency(code: "MXN"))
            }

            HStack {
                Text("Total")
                    .fontWeight(.bold)
                Spacer()
                Text(viewModel.total, format: .currency(code: "MXN"))
                    .fontWeight(.bold)
            }
        }
    }

    private func generatePDF() {
        guard let quote = viewModel.buildQuote() else { return }

        do {
            generatedPDFURL = try pdfGenerator.generatePDF(for: quote)
            showPDFPreview = true
        } catch {
            viewModel.errorMessage = "No se pudo generar el PDF. \(error.localizedDescription)"
            viewModel.showError = true
        }
    }
}
