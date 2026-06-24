//
//  SyncSettingsView.swift
//  MaximusPrecision
//
//  Opt-in sync controls. Off by default — the app works fully offline; turning
//  this on lets devices mirror records through the optional backend.
//

import SwiftUI

struct SyncSettingsView: View {
    @ObservedObject var center: SyncCenter
    let onSyncNow: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Activar sincronización", isOn: $center.enabled)
                } footer: {
                    Text("Apagado, la app funciona 100% local. Encendido, los autos y clientes se sincronizan entre dispositivos.")
                }

                if center.enabled {
                    Section("Servidor") {
                        TextField("URL del backend", text: $center.urlString)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .font(.system(.body, design: .monospaced))
                        SecureField("Token (opcional)", text: $center.token)
                    }

                    Section {
                        Button {
                            onSyncNow()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sincronizar ahora")
                            }
                        }
                        .disabled(isSyncing)
                    } footer: {
                        statusText
                    }
                }
            }
            .navigationTitle("Sincronización")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }

    private var isSyncing: Bool {
        if case .syncing = center.status { return true }
        return false
    }

    @ViewBuilder
    private var statusText: some View {
        switch center.status {
        case .idle:
            EmptyView()
        case .syncing:
            Label("Sincronizando…", systemImage: "clock")
        case .ok(let msg):
            Label(msg, systemImage: "checkmark.circle").foregroundStyle(.green)
        case .failed(let msg):
            Label(msg, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
        }
    }
}
