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
    var onTogglePeer: (Bool) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Activar sincronización", isOn: $center.enabled)
                        .accessibilityIdentifier(A11y.Sync.enableToggle)
                } footer: {
                    Text("Apagado, la app funciona 100% local. Encendido, los autos y clientes se sincronizan entre dispositivos.")
                }

                if center.enabled {
                    Section {
                        TextField("URL del backend", text: $center.urlString)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .font(.system(.body, design: .monospaced))
                        SecureField("API Key", text: $center.apiKey)
                        SecureField("API Secret", text: $center.apiSecret)
                    } header: {
                        Text("Servidor")
                    } footer: {
                        Label("Protegido con API key + secret", systemImage: "lock.fill")
                            .font(.caption)
                    }
                }

                Section {
                    Toggle("Sincronizar por Bluetooth", isOn: Binding(
                        get: { center.peerEnabled },
                        set: { onTogglePeer($0) }
                    ))
                    .accessibilityIdentifier(A11y.Sync.peerToggle)
                    if center.peerEnabled {
                        if center.connectedPeers.isEmpty {
                            Label("Buscando dispositivos cercanos…", systemImage: "antenna.radiowaves.left.and.right")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(center.connectedPeers, id: \.self) { peer in
                                Label(peer, systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                } header: {
                    Text("Bluetooth (sin servidor)")
                } footer: {
                    Text("Sincroniza directo con un Mac o iPhone cercano, sin internet ni backend.")
                }

                if center.enabled || center.peerEnabled {
                    Section {
                        Button {
                            onSyncNow()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sincronizar ahora")
                                Spacer()
                                if isSyncing { ProgressView() }
                            }
                        }
                        .disabled(isSyncing)
                        .accessibilityIdentifier(A11y.Sync.syncNow)
                    } footer: {
                        statusText
                    }

                    Section("Historial") {
                        if center.history.isEmpty {
                            Text("Aún no hay sincronizaciones.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(center.history) { entry in
                                SyncLogRow(entry: entry)
                            }
                            Button("Limpiar historial", role: .destructive) {
                                center.clearHistory()
                            }
                        }
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

private struct SyncLogRow: View {
    let entry: SyncLogEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(entry.success ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, format: .dateTime.month().day().hour().minute())
                    .font(.subheadline.weight(.medium))
                Text(entry.success ? "Enviados ↑\(entry.pushed) · Recibidos ↓\(entry.pulled)" : entry.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
    }
}
