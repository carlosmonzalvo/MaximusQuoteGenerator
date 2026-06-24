//
//  RecordEditSheet.swift
//  MaximusPrecision
//
//  Add sheet for a client (payer) or a vehicle (patient), depending on the
//  active scope.
//

import SwiftUI

struct RecordEditSheet: View {
    enum Result {
        case client(name: String, phone: String, email: String)
        case vehicle(plate: String, brand: String, model: String, year: String)
    }

    let scope: RecordsViewModel.Scope
    let onSave: (Result) -> Void

    @Environment(\.dismiss) private var dismiss

    // Client fields
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    // Vehicle fields
    @State private var plate = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var year = ""

    var body: some View {
        NavigationStack {
            Form {
                if scope == .clients {
                    Section("Cliente") {
                        TextField("Nombre", text: $name)
                            .accessibilityIdentifier(A11y.RecordEdit.name)
                        TextField("Teléfono", text: $phone)
                            .keyboardType(.phonePad)
                            .accessibilityIdentifier(A11y.RecordEdit.phone)
                        TextField("Correo (opcional)", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .accessibilityIdentifier(A11y.RecordEdit.email)
                    }
                } else {
                    Section("Auto") {
                        TextField("Placa", text: $plate)
                            .autocapitalization(.allCharacters)
                            .accessibilityIdentifier(A11y.RecordEdit.plate)
                        TextField("Marca", text: $brand)
                            .accessibilityIdentifier(A11y.RecordEdit.brand)
                        TextField("Modelo", text: $model)
                            .accessibilityIdentifier(A11y.RecordEdit.model)
                        TextField("Año", text: $year)
                            .keyboardType(.numberPad)
                            .accessibilityIdentifier(A11y.RecordEdit.year)
                    }
                }
            }
            .navigationTitle(scope == .clients ? "Nuevo cliente" : "Nuevo auto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .accessibilityIdentifier(A11y.RecordEdit.cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!canSave)
                        .accessibilityIdentifier(A11y.RecordEdit.save)
                }
            }
            .accessibilityIdentifier(A11y.RecordEdit.root)
        }
    }

    private var canSave: Bool {
        scope == .clients
            ? !name.trimmingCharacters(in: .whitespaces).isEmpty
            : !plate.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        switch scope {
        case .clients:
            onSave(.client(name: name, phone: phone, email: email))
        case .vehicles:
            onSave(.vehicle(plate: plate, brand: brand, model: model, year: year))
        }
        dismiss()
    }
}
