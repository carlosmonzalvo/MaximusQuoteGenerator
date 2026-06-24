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
    @Published var apiKey: String {
        didSet { defaults.set(apiKey, forKey: Keys.apiKey) }
    }
    @Published var apiSecret: String {
        didSet { defaults.set(apiSecret, forKey: Keys.apiSecret) }
    }
    @Published private(set) var status: Status = .idle
    @Published private(set) var history: [SyncLogEntry] = []

    /// Pull cursor: the highest server sequence this device has merged.
    private var cursor: Int

    private let defaults: UserDefaults

    /// Backend + credentials come from the build configuration (Config.xcconfig
    /// → Info.plist), so the secret stays out of source and no dev has to wire
    /// it by hand beyond creating Secrets.xcconfig once.
    static var defaultURL: String { bundleValue("MaximusAPIURL") }
    static var defaultKey: String { bundleValue("MaximusAPIKey") }
    static var defaultSecret: String { bundleValue("MaximusAPISecret") }

    private static func bundleValue(_ key: String) -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.enabled = defaults.bool(forKey: Keys.enabled)
        self.urlString = defaults.string(forKey: Keys.url) ?? Self.defaultURL
        self.apiKey = defaults.string(forKey: Keys.apiKey) ?? Self.defaultKey
        self.apiSecret = defaults.string(forKey: Keys.apiSecret) ?? Self.defaultSecret
        self.cursor = defaults.integer(forKey: Keys.cursor)
        if let data = defaults.data(forKey: Keys.history),
           let decoded = try? JSONDecoder().decode([SyncLogEntry].self, from: data) {
            self.history = decoded
        }

        // Deterministic state for screenshots (no network).
        if LaunchArgument.shouldSeedSyncDemo {
            self.enabled = true
            self.history = [
                SyncLogEntry(date: Date(), success: true, pushed: 2, pulled: 1, message: "↑2 · ↓1"),
                SyncLogEntry(date: Date().addingTimeInterval(-3600), success: true, pushed: 0, pulled: 3, message: "↑0 · ↓3"),
                SyncLogEntry(date: Date().addingTimeInterval(-7200), success: false, pushed: 0, pulled: 0, message: "El servidor respondió 401."),
            ]
        }
    }

    var transport: SyncTransport? {
        guard enabled, let url = URL(string: urlString), url.scheme?.hasPrefix("http") == true else {
            return nil
        }
        return RemoteSyncTransport(baseURL: url, apiKey: apiKey, apiSecret: apiSecret)
    }

    func syncNow(context: ModelContext) async {
        guard let transport else {
            status = .failed("Activa la sincronización y pon una URL válida.")
            return
        }
        status = .syncing
        do {
            let result = try await SyncEngine(context: context).sync(using: transport, cursor: cursor)
            cursor = result.cursor
            defaults.set(cursor, forKey: Keys.cursor)
            let summary = "↑\(result.pushed) · ↓\(result.pulled)"
            status = .ok("Sincronizado \(summary) · \(Self.timeFormatter.string(from: Date()))")
            log(SyncLogEntry(date: Date(), success: true, pushed: result.pushed,
                             pulled: result.pulled, message: summary))
        } catch {
            status = .failed(error.localizedDescription)
            log(SyncLogEntry(date: Date(), success: false, pushed: 0, pulled: 0,
                             message: error.localizedDescription))
        }
    }

    func clearHistory() {
        history = []
        defaults.removeObject(forKey: Keys.history)
    }

    /// Prepends an entry, caps the log, and persists it.
    private func log(_ entry: SyncLogEntry) {
        history.insert(entry, at: 0)
        if history.count > 50 { history = Array(history.prefix(50)) }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.history)
        }
    }

    private enum Keys {
        static let enabled = "maximus.sync.enabled"
        static let url = "maximus.sync.url"
        static let apiKey = "maximus.sync.apiKey"
        static let apiSecret = "maximus.sync.apiSecret"
        static let cursor = "maximus.sync.cursor"
        static let history = "maximus.sync.history"
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()
}
