//
//  RecordsView.swift
//  MaximusPrecision
//
//  Browser for the patients (Autos) and payers (Clientes). The vehicle is the
//  central record; tapping one opens its expediente.
//

import SwiftUI
import SwiftData

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = RecordsViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $vm.scope) {
                    ForEach(RecordsViewModel.Scope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .accessibilityIdentifier(A11y.Records.scopePicker)

                list
            }
            .navigationTitle("Expedientes")
            .searchable(text: $vm.search, prompt: searchPrompt)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier(A11y.Records.add)
                }
            }
            .sheet(isPresented: $showingAdd) {
                RecordEditSheet(scope: vm.scope) { result in
                    switch result {
                    case let .client(name, phone, email):
                        vm.addClient(name: name, phone: phone, email: email)
                    case let .vehicle(plate, brand, model, year):
                        vm.addVehicle(plate: plate, brand: brand, model: model, year: year)
                    }
                }
            }
            .accessibilityIdentifier(A11y.Records.root)
        }
        .onAppear { vm.load(context: modelContext) }
    }

    private var searchPrompt: String {
        vm.scope == .vehicles ? "Placa o vehículo" : "Nombre o teléfono"
    }

    @ViewBuilder
    private var list: some View {
        switch vm.scope {
        case .vehicles:
            if vm.filteredVehicles.isEmpty {
                emptyState("Sin autos todavía", systemImage: "car")
            } else {
                List {
                    ForEach(Array(vm.filteredVehicles.enumerated()), id: \.element.persistentModelID) { index, vehicle in
                        NavigationLink {
                            VehicleDetailView(vehicle: vehicle, vm: vm)
                        } label: {
                            VehicleRow(vehicle: vehicle)
                        }
                        .accessibilityIdentifier(A11y.Records.vehicleRow(index))
                    }
                    .onDelete { offsets in
                        offsets.map { vm.filteredVehicles[$0] }.forEach(vm.deleteVehicle)
                    }
                }
            }
        case .clients:
            if vm.filteredClients.isEmpty {
                emptyState("Sin clientes todavía", systemImage: "person")
            } else {
                List {
                    ForEach(Array(vm.filteredClients.enumerated()), id: \.element.persistentModelID) { index, client in
                        ClientRow(client: client)
                            .accessibilityIdentifier(A11y.Records.clientRow(index))
                    }
                    .onDelete { offsets in
                        offsets.map { vm.filteredClients[$0] }.forEach(vm.deleteClient)
                    }
                }
            }
        }
    }

    private func emptyState(_ title: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .foregroundStyle(.secondary)
            Text("Toca + para agregar.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(A11y.Records.emptyState)
    }
}

private struct VehicleRow: View {
    let vehicle: VehicleRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "car.fill")
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.plate.uppercased())
                    .font(.headline)
                Text(vehicle.displayName.isEmpty ? "Sin datos del vehículo" : vehicle.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let payer = vehicle.currentPayer {
                    Text("Paga: \(payer.name)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            if !vehicle.services.isEmpty {
                Text("\(vehicle.services.count)")
                    .font(.caption.bold())
                    .padding(6)
                    .background(Color.blue.opacity(0.15), in: Circle())
            }
        }
    }
}

private struct ClientRow: View {
    let client: ClientRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .foregroundStyle(.green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(client.name)
                    .font(.headline)
                if !client.phone.isEmpty {
                    Text(client.phone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !client.vehicles.isEmpty {
                Label("\(client.vehicles.count)", systemImage: "car")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
