import SwiftUI

// MARK: - Shared sub-components

private struct MXField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocap: TextInputAutocapitalization = .sentences
    var identifier: String? = nil

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
                .mxFieldBackground()
                .accessibilityIdentifier(identifier ?? "")
        }
    }
}

/// A field that looks like `MXField` but opens a picker instead of a keyboard.
private struct MXPickerField: View {
    let label: String
    let value: String
    var placeholder: String = "Elegir"
    var identifier: String? = nil
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(MXTheme.muted)
                .kerning(0.8)
            Button(action: onTap) {
                HStack(spacing: 6) {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.system(size: 15))
                        .foregroundStyle(value.isEmpty ? MXTheme.dim : MXTheme.text)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(MXTheme.muted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .mxFieldBackground()
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(identifier ?? "")
        }
    }
}

private struct TemplateChipBtn: View {
    let template: QuoteTemplate
    var identifier: String? = nil
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
            .mxFieldBackground()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier ?? "")
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
    var identifier: String? = nil
    var deleteIdentifier: String? = nil
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onTap) {
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
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(identifier ?? "")

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MXTheme.dim)
                    .frame(width: 28, height: 28)
                    .background(MXTheme.surfaceAlt)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(deleteIdentifier ?? "")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(MXTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(MXTheme.border, lineWidth: 1)
        )
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
                        .accessibilityIdentifier(A11y.ItemEdit.typePicker)
                    }

                    MXField(label: "Concepto", text: $item.title, identifier: A11y.ItemEdit.title)

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
                            .mxFieldBackground()
                            .accessibilityIdentifier(A11y.ItemEdit.detail)
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
                                .mxFieldBackground()
                                .accessibilityIdentifier(A11y.ItemEdit.quantity)
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
                                .mxFieldBackground()
                                .accessibilityIdentifier(A11y.ItemEdit.unitPrice)
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
                            .accessibilityIdentifier(A11y.ItemEdit.total)
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
            .navBarDarkChrome(MXTheme.header)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        onSave(item)
                        dismiss()
                    }
                    .foregroundStyle(MXTheme.accent)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier(A11y.ItemEdit.done)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(MXTheme.muted)
                        .accessibilityIdentifier(A11y.ItemEdit.cancel)
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

    // Vehicle catalog state lives in the view model; the view only needs the
    // SwiftData context to hand it over.
    @Environment(\.modelContext) private var modelContext
    @State private var showVersionPicker = false
    @State private var showYearPicker = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MXTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        VStack(spacing: 0) {
                            itemsSection
                            totalsSection
                            notesSection
                            Color.clear.frame(height: 110)
                        }
                        .padding(.horizontal, 14)
                    }
                }

                bottomBar
            }
            .hiddenNavBar()
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
            .sheet(isPresented: $showVersionPicker) {
                if let model = vm.selectedModel {
                    VersionPickerSheet(modelName: model.name, trims: model.trims) { trim in
                        vm.applyVersion(trim)
                    }
                }
            }
            .sheet(isPresented: $showYearPicker) {
                YearPickerSheet(
                    minYear: vm.minYear(forModelYearStart: vm.selectedModel?.yearStart),
                    maxYear: vm.currentYear,
                    selected: Int(vm.vehicleYear)
                ) { year in
                    vm.vehicleYear = String(year)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            vm.loadCatalog(context: modelContext)
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(vm.documentType.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(MXTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text("#\(vm.folio)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(MXTheme.muted)
            }

            docTypeSwitcher

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                MXField(label: "Nombre", text: $vm.customerName, identifier: A11y.QuoteForm.customerName)
                MXField(label: "Teléfono", text: $vm.customerPhone, keyboard: .phonePad, identifier: A11y.QuoteForm.customerPhone)
                MXField(label: "Marca", text: $vm.vehicleBrand, identifier: A11y.QuoteForm.vehicleBrand)
                MXField(label: "Modelo", text: $vm.vehicleModel, identifier: A11y.QuoteForm.vehicleModel)
                MXPickerField(label: "Año", value: vm.vehicleYear, identifier: A11y.QuoteForm.yearField) {
                    hideKeyboard()
                    showYearPicker = true
                }
                MXField(label: "Placas", text: $vm.vehiclePlate, autocap: .characters, identifier: A11y.QuoteForm.vehiclePlate)
            }

            vehicleCatalogSection

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(defaultTemplates.enumerated()), id: \.element.id) { index, tpl in
                        TemplateChipBtn(template: tpl, identifier: A11y.QuoteForm.templateChip(index)) {
                            vm.addTemplate(tpl)
                        }
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
        // Tap anywhere on the header chrome to dismiss the keyboard.
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
    }

    private var docTypeSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(DocumentType.allCases, id: \.self) { type in
                Button {
                    vm.documentType = type
                } label: {
                    Text(type.shortLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(vm.documentType == type ? Color(hex: "111111") : MXTheme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(vm.documentType == type ? MXTheme.accent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(type == .quote
                    ? A11y.QuoteForm.docTypeQuote
                    : A11y.QuoteForm.docTypeRemision)
            }
        }
        .padding(3)
        .background(MXTheme.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(MXTheme.borderLight, lineWidth: 1)
        )
    }

    // MARK: Vehicle catalog (pills + optional version)

    @ViewBuilder
    private var vehicleCatalogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !vm.makeNames.isEmpty {
                catalogChipRow(label: "MARCAS") {
                    ForEach(Array(vm.visibleMakeNames.enumerated()), id: \.element) { index, name in
                        catalogPill(
                            title: name,
                            selected: vm.vehicleBrand == name,
                            identifier: A11y.QuoteForm.makeChip(index)
                        ) { vm.selectMake(name) }
                    }
                    if vm.hasMoreMakes {
                        morePill(identifier: A11y.QuoteForm.makeShowMore) { vm.showMoreMakes() }
                    }
                }
            }

            if !vm.modelOptions.isEmpty {
                catalogChipRow(label: "MODELOS") {
                    ForEach(Array(vm.visibleModelOptions.enumerated()), id: \.element.id) { index, option in
                        catalogPill(
                            title: option.name,
                            selected: vm.selectedModel?.name == option.name,
                            identifier: A11y.QuoteForm.modelChip(index)
                        ) { vm.selectModel(option) }
                    }
                    if vm.hasMoreModels {
                        morePill(identifier: A11y.QuoteForm.modelShowMore) { vm.showMoreModels() }
                    }
                }
            }

            if let model = vm.selectedModel, model.hasTrims {
                Button {
                    showVersionPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12))
                        Text(versionPillLabel(for: model))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(MXTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassCard(cornerRadius: 10, fallbackFill: MXTheme.accent.opacity(0.12))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11y.QuoteForm.versionPill)
            }
        }
    }

    private func versionPillLabel(for model: ModelOption) -> String {
        let prefix = model.name + " "
        if vm.vehicleModel.hasPrefix(prefix) {
            return "Versión: \(vm.vehicleModel.dropFirst(prefix.count))"
        }
        return "Versión (opcional)"
    }

    private func catalogChipRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(MXTheme.muted)
                .kerning(0.8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) { content() }
            }
        }
    }

    private func catalogPill(
        title: String,
        selected: Bool,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(selected ? Color(hex: "111111") : MXTheme.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassPill(selected: selected, tint: MXTheme.accent)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    /// "Ver más" chip shown at the end of a catalog row to reveal the rest.
    private func morePill(identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("Ver más")
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(MXTheme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassCard(cornerRadius: 10, fallbackFill: MXTheme.accent.opacity(0.12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
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
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(A11y.QuoteForm.emptyState)
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                        LineItemCard(
                            item: item,
                            identifier: A11y.QuoteForm.lineItem(index),
                            deleteIdentifier: A11y.QuoteForm.deleteItem(index),
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
                    identifier: A11y.QuoteForm.addPart,
                    action: {
                        vm.addPart()
                        editingItem = vm.items.last
                    }
                )
                addButton(
                    label: "+ M. de obra",
                    color: MXTheme.laborGreen,
                    identifier: A11y.QuoteForm.addLabor,
                    action: {
                        vm.addLabor()
                        editingItem = vm.items.last
                    }
                )
            }
            .padding(.top, 10)
        }
    }

    private func addButton(label: String, color: Color, identifier: String, action: @escaping () -> Void) -> some View {
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
        .accessibilityIdentifier(identifier)
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
                .mxFieldBackground(borderWidth: 1)
                .accessibilityIdentifier(A11y.QuoteForm.notes)
        }
    }

    // MARK: Totales

    private var totalsSection: some View {
        VStack(spacing: 0) {
            MXSectionDivider(label: "Totales")

            HStack(spacing: 8) {
                toggleChip(
                    label: "IVA 16%",
                    active: vm.includesIVA,
                    color: MXTheme.partBlue,
                    identifier: A11y.QuoteForm.ivaToggle,
                    action: { vm.toggleIVA() }
                )
                toggleChip(
                    label: "Tarjeta 4.5%",
                    active: vm.includesCardFee,
                    color: MXTheme.laborGreen,
                    identifier: A11y.QuoteForm.cardFeeToggle,
                    action: { vm.toggleCardFee() }
                )
            }

            VStack(spacing: 8) {
                summaryRow("Subtotal", vm.subtotal, identifier: A11y.QuoteForm.subtotalAmount)
                if vm.includesIVA {
                    summaryRow("IVA (16%)", vm.ivaAmount, identifier: A11y.QuoteForm.ivaAmount)
                }
                if vm.includesCardFee {
                    summaryRow("Comisión tarjeta (4.5%)", vm.cardFeeAmount, identifier: A11y.QuoteForm.cardFeeAmount)
                }
            }
            .padding(.top, 12)
        }
    }

    private func toggleChip(
        label: String,
        active: Bool,
        color: Color,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: active ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(active ? color : MXTheme.dim)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MXTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(active ? color.opacity(0.12) : MXTheme.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(active ? color : MXTheme.borderLight, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func summaryRow(_ label: String, _ value: Double, identifier: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(MXTheme.muted)
            Spacer()
            Text(value, format: .currency(code: "MXN"))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(MXTheme.muted)
                .accessibilityIdentifier(identifier)
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
                    .accessibilityIdentifier(A11y.QuoteForm.total)
            }

            Spacer()

            Button(action: generatePDF) {
                Text("Generar PDF →")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: "111111"))
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .glassAction(tint: MXTheme.accent)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11y.QuoteForm.generatePDF)
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
            // File the document under the vehicle's expediente (patient ↔ payer).
            let repo = ClientVehicleRepository(context: modelContext)
            repo.recordService(from: quote)
            repo.save()
            showPDFPreview = true
        } catch {
            vm.errorMessage = "No se pudo generar el PDF. \(error.localizedDescription)"
            vm.showError = true
        }
    }
}
