//
//  SyncTransport.swift
//  MaximusPrecision
//
//  Abstraction over "how" sync happens. A backend (Railway + Redis) and a
//  peer-to-peer Bluetooth transport (MultipeerConnectivity) plug in here in
//  later MRs. When no transport is configured the app is fully offline.
//

import Foundation

protocol SyncTransport: AnyObject {
    /// Human label for diagnostics / settings UI.
    var name: String { get }
    /// Whether the transport is currently usable (reachable / connected).
    var isAvailable: Bool { get }
    /// Sends local changes and returns the remote's changes to merge.
    func exchange(_ payload: SyncPayload) async throws -> SyncPayload
}

enum SyncError: Error, LocalizedError {
    case noTransport
    case transportUnavailable
    case encoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .noTransport: return "No hay un método de sincronización configurado."
        case .transportUnavailable: return "El método de sincronización no está disponible."
        case .encoding(let e): return "Error al preparar los datos: \(e.localizedDescription)"
        case .transport(let e): return "Error de sincronización: \(e.localizedDescription)"
        }
    }
}
