import SwiftUI

// MARK: - Shared sub-components

private struct MXField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocap: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(MXTheme.muted)
                .kerning(0.8)
            TextField("", text: $text)
                .font(.system(size: 15))
                .foregroundStyle(MXTheme.text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocap)
                .tint(MXTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(MXTheme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(MXTheme.borderLight, lineWidth: 1.5)
                )
        }
    }
}

private struct TemplateChipBtn: View {
    let template: QuoteTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(template.type == .part ? MXTheme.partBlue : MXTheme.laborGreen)
                    .frame(width: 6, height: 6)
                Text(shortTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MXTheme.text)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(MXTheme.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(MXTheme.borderLight, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var shortTitle: String {
        let words = template.title.split(separator: " ")
        return words.count > 2 ? words.prefix(2).joined(separator: " ") : template.title
    }
}

private struct MXSectionDivider: View {
    let label: String
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(MXTheme.border).frame(height: 1)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(MXTheme.muted)
                .kerning(1.5)
                .fixedSize()
            Rectangle().fill(MXTheme.border).frame(height: 1)
        }
        .padding(.vertical, 14)
    }
}

private struct LineItemCard: View {
    let item: QuoteItem
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(item.type == .part ? MXTheme.partBlue : MXTheme.laborGreen)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title.isEmpty ? "Sin título" : item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(item.title.isEmpty ? MXTheme.muted : MXTheme.text)
                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(MXTheme.muted)
                        .lineLimit(1)
                }
                if item.quantity != 1 || item.unitPrice == 0 {
                    Text("Cant: \(item.quantity.formatted(.number)) · \(item.type.rawValue)")
                        .font(.system(size: 11))
                        .foregroundStyle(MXTheme.dim)
                }
            }

            Spacer()

            Text(item.total, format: .currency(code: "MXN"))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(MXTheme.accent)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MXTheme.dim)
                    .frame(width: 28, height: 28)
                    .background(MXTheme.surfaceAlt)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(MXTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(MXTheme.border, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Item Edit Sheet

struct ItemEditSheet: View {
    @State private var item: QuoteItem
    let onSave: (QuoteItem) -> Void
    @Environment(\.dismiss) private var dismiss

    init(item: QuoteItem, onSave: @escaping (QuoteItem) -> Void) {
        _item = State(initialValue: item)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIPO")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(MXTheme.muted)
                            .kerning(0.8)
                        Picker("Tipo", selection: $item.type) {
                            ForEach(QuoteItemType.allCases, id: \.self) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    MXField(label: "Concepto", text: $item.title)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("DESCRIPCIÓN")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(MXTheme.muted)
                            .kerning(0.8)
                        TextField("", text: $item.detail, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundStyle(MXTheme.text)
                            .lineLimit(2...5)
                            .tint(MXTheme.accent)
                            .padding(12)
                            .background(MXTheme.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(MXTheme.borderLight, lineWidth: 1.5)
                            )
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("CANTIDAD")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(MXTheme.muted)
                                .kerning(0.8)
                            TextField("", value: $item.quantity, format: .number)
                                .font(.system(size: 15))
                                .foregroundStyle(MXTheme.text)
                                .keyboardType(.decimalPad)
                                .tint(MXTheme.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 11)
                                .background(MXTheme.surfaceAlt)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(MXTheme.borderLight, lineWidth: 1.5)
                                )
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("PRECIO UNITARIO")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(MXTheme.muted)
                                .kerning(0.8)
                            TextField("", value: $item.unitPrice, format: .currency(code: "MXN"))
                                .font(.system(size: 15))
                                .foregroundStyle(MXTheme.text)
                                .keyboardType(.decimalPad)
                                .tint(MXTheme.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 11)
                                .background(MXTheme.surfaceAlt)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(MXTheme.borderLight, lineWidth: 1.5)
                                )
                        }
                    }

                    HStack {
                        Text("Total")
                            .font(.system(size: 14))
                            .foregroundStyle(MXTheme.muted)
                        Spacer()
                        Text(item.total, format: .currency(code: "MXN"))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(MXTheme.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .background(MXTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MXTheme.border, lineWidth: 1)
                    )
                }
                .padding(16)
            }
            .background(MXTheme.bg.ignoresSafeArea())
            .navigationTitle("Editar concepto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MXTheme.header, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        onSave(item)
                        dismiss()
                    }
                    .foregroundStyle(MXTheme.accent)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(MXTheme.muted)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Form View

struct QuoteFormView: View {
    @StateObject private var vm = QuoteFormViewModel()
    @State private var generatedPDFURL: URL?
    @State private var showPDFPreview = false
    @State private var editingItem: QuoteItem?
    private let pdfGenerator = PDFGeneratorService()
    private let folio = String(UUID().uuidString.prefix(8)).uppercased()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MXTheme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection
                    ScrollView {
                        VStack(spacing: 0) {
                            itemsSection
                            notesSection
                            Color.clear.frame(height: 110)
                        }
                        .padding(.horizontal, 14)
                    }
                }

                bottomBar
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showPDFPreview) {
                if let url = generatedPDFURL { PDFPreviewView(url: url) }
            }
            .alert("Aviso", isPresented: $vm.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage)
            }
            .sheet(item: $editingItem) { item in
                ItemEditSheet(item: item) { updated in
                    if let idx = vm.items.firstIndex(where: { $0.id == updated.id }) {
                        vm.items[idx] = updated
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Nueva Cotización")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(MXTheme.text)
                Spacer()
                Text("#\(folio)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(MXTheme.muted)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                MXField(label: "Nombre", text: $vm.customerName)
                MXField(label: "Teléfono", text: $vm.customerPhone, keyboard: .phonePad)
                MXField(label: "Marca", text: $vm.vehicleBrand)
                MXField(label: "Modelo", text: $vm.vehicleModel)
                MXField(label: "Año", text: $vm.vehicleYear, keyboard: .numberPad)
                MXField(label: "Placas", text: $vm.vehiclePlate, autocap: .characters)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(defaultTemplates) { tpl in
                        TemplateChipBtn(template: tpl) { vm.addTemplate(tpl) }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .background(MXTheme.header)
        .overlay(alignment: .bottom) {
            Rectangle().fill(MXTheme.border).frame(height: 1)
        }
    }

    // MARK: Items

    private var itemsSection: some View {
        VStack(spacing: 0) {
            MXSectionDivider(label: "Conceptos (\(vm.items.count))")

            if vm.items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 30))
                        .foregroundStyle(MXTheme.border)
                    Text("Sin conceptos")
                        .font(.system(size: 15))
                        .foregroundStyle(MXTheme.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                VStack(spacing: 6) {
                    ForEach(vm.items) { item in
                        LineItemCard(
                            item: item,
                            onTap: { editingItem = item },
                            onDelete: { vm.items.removeAll { $0.id == item.id } }
                        )
                    }
                }
            }

            HStack(spacing: 8) {
                addButton(
                    label: "+ Refacción",
                    color: MXTheme.partBlue,
                    action: {
                        vm.addPart()
                        editingItem = vm.items.last
                    }
                )
                addButton(
                    label: "+ M. de obra",
                    color: MXTheme.laborGreen,
                    action: {
                        vm.addLabor()
                        editingItem = vm.items.last
                    }
                )
            }
            .padding(.top, 10)
        }
    }

    private func addButton(label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MXTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(MXTheme.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(MXTheme.borderLight, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Notes

    private var notesSection: some View {
        VStack(spacing: 0) {
            MXSectionDivider(label: "Notas")
            TextField("Observaciones adicionales…", text: $vm.notes, axis: .vertical)
                .font(.system(size: 15))
                .foregroundStyle(MXTheme.text)
                .lineLimit(3...6)
                .tint(MXTheme.accent)
                .padding(12)
                .background(MXTheme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(MXTheme.borderLight, lineWidth: 1)
                )
        }
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("TOTAL")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(MXTheme.muted)
                    .kerning(1)
                Text(vm.total, format: .currency(code: "MXN"))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(MXTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            Button(action: generatePDF) {
                Text("Generar PDF →")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: "111111"))
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .background(MXTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(MXTheme.header)
        .overlay(alignment: .top) {
            Rectangle().fill(MXTheme.border).frame(height: 1.5)
        }
    }

    private func generatePDF() {
        guard let quote = vm.buildQuote() else { return }
        do {
            generatedPDFURL = try pdfGenerator.generatePDF(for: quote)
            showPDFPreview = true
        } catch {
            vm.errorMessage = "No se pudo generar el PDF. \(error.localizedDescription)"
            vm.showError = true
        }
    }
}
