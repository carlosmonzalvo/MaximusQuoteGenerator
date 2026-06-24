//
//  RecordsSearchView.swift
//  MaximusPrecision
//
//  iOS 26 search-role tab: searches across the expedientes (autos + clientes)
//  from the Liquid Glass tab bar. Backed by the same RecordsViewModel as the
//  browse tab so results stay in sync.
//

import SwiftUI

@available(iOS 26.0, *)
struct RecordsSearchView: View {
    @ObservedObject var vm: RecordsViewModel

    var body: some View {
        NavigationStack {
            List {
                if !vm.filteredVehicles.isEmpty {
                    Section("Autos") {
                        ForEach(vm.filteredVehicles, id: \.persistentModelID) { vehicle in
                            NavigationLink {
                                VehicleDetailView(vehicle: vehicle, vm: vm)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(vehicle.plate.uppercased()).font(.headline)
                                    if !vehicle.displayName.isEmpty {
                                        Text(vehicle.displayName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                if !vm.filteredClients.isEmpty {
                    Section("Clientes") {
                        ForEach(vm.filteredClients, id: \.persistentModelID) { client in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(client.name).font(.headline)
                                if !client.phone.isEmpty {
                                    Text(client.phone)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Buscar")
            .overlay {
                if vm.search.isEmpty {
                    ContentUnavailableView(
                        "Busca en expedientes",
                        systemImage: "magnifyingglass",
                        description: Text("Por placa, auto o cliente.")
                    )
                } else if vm.filteredVehicles.isEmpty && vm.filteredClients.isEmpty {
                    ContentUnavailableView.search(text: vm.search)
                }
            }
        }
        .searchable(text: $vm.search, prompt: "Placa, auto o cliente")
        .onAppear { vm.refresh() }
    }
}
