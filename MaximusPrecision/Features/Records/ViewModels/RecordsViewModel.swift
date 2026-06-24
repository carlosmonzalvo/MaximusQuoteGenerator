//
//  RecordsViewModel.swift
//  MaximusPrecision
//
//  Drives the Clientes / Autos browser. Wraps the repository so the views never
//  touch SwiftData directly (MVVM).
//

import Foundation
import SwiftData

@MainActor
final class RecordsViewModel: ObservableObject {
    enum Scope: String, CaseIterable, Identifiable {
        case vehicles = "Autos"
        case clients = "Clientes"
        var id: String { rawValue }
    }

    @Published var scope: Scope = .vehicles
    @Published var search: String = ""
    @Published private(set) var vehicles: [VehicleRecord] = []
    @Published private(set) var clients: [ClientRecord] = []

    private var repository: ClientVehicleRepository?

    func load(context: ModelContext) {
        if repository == nil {
            repository = ClientVehicleRepository(context: context)
        }
        refresh()
    }

    func refresh() {
        guard let repository else { return }
        vehicles = repository.vehicles()
        clients = repository.clients()
    }

    var filteredVehicles: [VehicleRecord] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return vehicles }
        return vehicles.filter {
            $0.plate.lowercased().contains(q) || $0.displayName.lowercased().contains(q)
        }
    }

    var filteredClients: [ClientRecord] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return clients }
        return clients.filter {
            $0.name.lowercased().contains(q) || $0.phone.lowercased().contains(q)
        }
    }

    // MARK: Mutations

    func addClient(name: String, phone: String, email: String) {
        guard let repository,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        repository.insert(ClientRecord(name: name, phone: phone, email: email))
        repository.save()
        refresh()
    }

    func addVehicle(plate: String, brand: String, model: String, year: String) {
        guard let repository,
              !plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        repository.insert(VehicleRecord(plate: plate, brand: brand, model: model, year: year))
        repository.save()
        refresh()
    }

    func link(client: ClientRecord, to vehicle: VehicleRecord) {
        guard let repository else { return }
        repository.link(client: client, to: vehicle)
        repository.save()
        refresh()
    }

    func deleteClient(_ client: ClientRecord) {
        guard let repository else { return }
        repository.delete(client)
        repository.save()
        refresh()
    }

    func deleteVehicle(_ vehicle: VehicleRecord) {
        guard let repository else { return }
        repository.delete(vehicle)
        repository.save()
        refresh()
    }
}
