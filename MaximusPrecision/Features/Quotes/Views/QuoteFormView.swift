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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = QuoteFormViewModel()
    @State private var currentStep: Int = 1
    @State private var validationError: String? = nil
    @State private var brandSuggestions: [String] = []
    @State private var modelSuggestions: [String] = []
    @State private var generatedPDFURL: URL?
    @State private var showPDFPreview = false
    @State private var editingItem: QuoteItem?
    
    private let pdfGenerator = PDFGeneratorService()
    private let folio = String(UUID().uuidString.prefix(8)).uppercased()
    
    private var repo: VehicleRepositoryProtocol {
        LocalVehicleRepository(context: modelContext)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MXTheme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    wizardHeader
                    
                    TabView(selection: $currentStep) {
                        step1Cliente.tag(1)
                        step2Vehiculo.tag(2)
                        step3Conceptos.tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea(.keyboard)
                }

                bottomNavigation
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

    // MARK: - Wizard Components

    private var wizardHeader: some View {
        VStack(spacing: 0) {
            HStack {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentStep -= 1
                            validationError = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Text("Atrás")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(MXTheme.muted)
                    }
                } else {
                    Text("Nueva Cotización")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(MXTheme.text)
                }
                
                Spacer()
                
                Text("#\(folio)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(MXTheme.muted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(stepTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(MXTheme.muted)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(step <= currentStep ? MXTheme.accent : MXTheme.border)
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 16)
                .animation(.easeInOut(duration: 0.25), value: currentStep)
            }
            .padding(.bottom, 16)
            
            Rectangle()
                .fill(MXTheme.border)
                .frame(height: 1)
        }
        .background(MXTheme.header)
    }

    private var stepTitle: String {
        switch currentStep {
        case 1: return "Paso 1 de 3 — Cliente"
        case 2: return "Paso 2 de 3 — Vehículo"
        case 3: return "Paso 3 de 3 — Conceptos"
        default: return ""
        }
    }

    private var step1Cliente: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Información del Cliente")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MXTheme.text)
                    .padding(.top, 10)
                
                VStack(spacing: 16) {
                    MXField(label: "Nombre completo", text: $vm.customerName)
                    MXField(label: "Teléfono", text: $vm.customerPhone, keyboard: .phonePad)
                }
                
                if let error = validationError, currentStep == 1 {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(MXTheme.accent)
                        .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }

    private var step2Vehiculo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Detalles del Vehículo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MXTheme.text)
                    .padding(.top, 10)
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        MXAutoField(label: "Marca", text: $vm.vehicleBrand, suggestions: brandSuggestions) { selection in
                            vm.vehicleBrand = selection
                            vm.vehicleModel = ""
                            brandSuggestions = []
                        }
                        .onChange(of: vm.vehicleBrand) { _, newValue in
                            Task {
                                brandSuggestions = await repo.brands(matching: newValue)
                            }
                        }
                        
                        MXAutoField(label: "Modelo", text: $vm.vehicleModel, suggestions: modelSuggestions) { selection in
                            vm.vehicleModel = selection
                            modelSuggestions = []
                            Task {
                                await repo.recordUsage(brand: vm.vehicleBrand, model: selection)
                            }
                        }
                        .onChange(of: vm.vehicleModel) { _, newValue in
                            Task {
                                modelSuggestions = await repo.models(for: vm.vehicleBrand, matching: newValue)
                            }
                        }
                    }
                    
                    HStack(spacing: 16) {
                        MXField(label: "Año", text: $vm.vehicleYear, keyboard: .numberPad)
                        MXField(label: "Placas", text: $vm.vehiclePlate, autocap: .characters)
                    }
                }
                
                if let error = validationError, currentStep == 2 {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(MXTheme.accent)
                        .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }

    private var step3Conceptos: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Conceptos y Trabajo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MXTheme.text)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(defaultTemplates) { tpl in
                            TemplateChipBtn(template: tpl) { vm.addTemplate(tpl) }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 10)

                itemsSection
                    .padding(.horizontal, 16)
                
                notesSection
                    .padding(.horizontal, 16)
                
                if let error = validationError, currentStep == 3 {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(MXTheme.accent)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                }
                
                Color.clear.frame(height: 120)
            }
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

    // MARK: - Navigation

    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(MXTheme.border)
                .frame(height: 1)
            
            HStack(spacing: 12) {
                if currentStep < 3 {
                    Spacer()
                    Button(action: nextStep) {
                        HStack(spacing: 8) {
                            Text("Siguiente")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(hex: "111111"))
                        .padding(.horizontal, 24)
                        .frame(height: 52)
                        .background(MXTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
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

                    Button(action: {
                        if validateStep3() {
                            generatePDF()
                        }
                    }) {
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 34)
            .background(MXTheme.header)
        }
    }

    private func nextStep() {
        validationError = nil
        
        switch currentStep {
        case 1:
            if vm.customerName.trimmingCharacters(in: .whitespaces).isEmpty {
                validationError = "El nombre del cliente es obligatorio"
                return
            }
        case 2:
            if vm.vehicleBrand.trimmingCharacters(in: .whitespaces).isEmpty ||
               vm.vehicleModel.trimmingCharacters(in: .whitespaces).isEmpty {
                validationError = "Marca y modelo son obligatorios"
                return
            }
        default:
            break
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep += 1
        }
    }

    private func validateStep3() -> Bool {
        if vm.items.isEmpty {
            validationError = "Agregue al menos un concepto"
            return false
        }
        return true
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
