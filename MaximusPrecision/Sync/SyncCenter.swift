//
//  SyncCenter.swift
//  MaximusPrecision
//
//  User-facing sync coordinator. Holds the (opt-in) settings and runs a sync
//  pass through the configured transport. Disabled by default → the app is
//  fully local until the user turns it on.
//

import Foundation
import SwiftData

@MainActor
final class SyncCenter: ObservableObject {
    enum Status: Equatable {
        case idle
        case syncing
        case ok(String)
        case failed(String)
    }

    // Persisted settings (UserDefaults).
    @Published var enabled: Bool {
        didSet { defaults.set(enabled, forKey: Keys.enabled) }
    }
    @Published var urlString: String {
        didSet { defaults.set(urlString, forKey: Keys.url) }
    }
    @Published var token: String {
        didSet { defaults.set(token, forKey: Keys.token) }
    }
    @Published private(set) var status: Status = .idle

    private let defaults: UserDefaults

    /// The deployed backend, prefilled so it works out of the box once enabled.
    static let defaultURL = "https://maximus-api-production-e2bd.up.railway.app"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.enabled = defaults.bool(forKey: Keys.enabled)
        self.urlString = defaults.string(forKey: Keys.url) ?? Self.defaultURL
        self.token = defaults.string(forKey: Keys.token) ?? ""
    }

    var transport: SyncTransport? {
        guard enabled, let url = URL(string: urlString), url.scheme?.hasPrefix("http") == true else {
            return nil
        }
        return RemoteSyncTransport(baseURL: url, token: token)
    }

    func syncNow(context: ModelContext) async {
        guard let transport else {
            status = .failed("Activa la sincronización y pon una URL válida.")
            return
        }
        status = .syncing
        do {
            try await SyncEngine(context: context).sync(using: transport)
            status = .ok("Sincronizado · \(Self.timeFormatter.string(from: Date()))")
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    private enum Keys {
        static let enabled = "maximus.sync.enabled"
        static let url = "maximus.sync.url"
        static let token = "maximus.sync.token"
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()
}
