//
//  VehicleDetailView.swift
//  MaximusPrecision
//
//  The patient's expediente: who has paid for it (payers) and its full service
//  history. Lets you associate an existing client as a payer.
//

import SwiftUI

struct VehicleDetailView: View {
    let vehicle: VehicleRecord
    @ObservedObject var vm: RecordsViewModel
    @State private var showingLinkPicker = false

    private var history: [ServiceRecord] {
        vehicle.services.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Placa", value: vehicle.plate.uppercased())
                if !vehicle.displayName.isEmpty {
                    LabeledContent("Vehículo", value: vehicle.displayName)
                }
                if !vehicle.color.isEmpty {
                    LabeledContent("Color", value: vehicle.color)
                }
            } header: {
                Text("Paciente")
            }

            Section {
                if vehicle.clients.isEmpty {
                    Text("Sin clientes ligados")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vehicle.clients, id: \.persistentModelID) { client in
                        HStack {
                            Image(systemName: "person.fill").foregroundStyle(.green)
                            Text(client.name)
                            Spacer()
                            if client.persistentModelID == vehicle.currentPayer?.persistentModelID {
                                Text("Actual")
                                    .font(.caption.bold())
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                Button {
                    showingLinkPicker = true
                } label: {
                    Label("Ligar cliente", systemImage: "link")
                }
            } header: {
                Text("Pagadores")
            }
            .accessibilityIdentifier(A11y.VehicleDetail.payers)

            Section {
                if history.isEmpty {
                    Text("Sin servicios registrados")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(history, id: \.persistentModelID) { service in
                        ServiceHistoryRow(service: service)
                    }
                }
            } header: {
                Text("Historial de servicios")
            }
            .accessibilityIdentifier(A11y.VehicleDetail.history)
        }
        .navigationTitle(vehicle.plate.uppercased())
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11y.VehicleDetail.root)
        .sheet(isPresented: $showingLinkPicker) {
            LinkClientSheet(vm: vm) { client in
                vm.link(client: client, to: vehicle)
            }
        }
    }
}

private struct ServiceHistoryRow: View {
    let service: ServiceRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(service.documentType.shortLabel)
                    .font(.subheadline.bold())
                Spacer()
                Text(service.total, format: .currency(code: "MXN"))
                    .font(.subheadline.bold())
            }
            HStack {
                Text("Folio \(service.folio)")
                Spacer()
                Text(service.date, style: .date)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if let payer = service.payer {
                Text("Pagó: \(payer.name)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private struct LinkClientSheet: View {
    @ObservedObject var vm: RecordsViewModel
    let onPick: (ClientRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(vm.clients, id: \.persistentModelID) { client in
                Button {
                    onPick(client)
                    dismiss()
                } label: {
                    Text(client.name)
                }
            }
            .navigationTitle("Ligar cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .overlay {
                if vm.clients.isEmpty {
                    Text("Agrega clientes primero.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
