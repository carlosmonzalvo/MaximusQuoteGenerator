//
//  RemoteSyncTransport.swift
//  MaximusPrecision
//
//  Optional backend transport: POSTs a SyncPayload to the Maximus sync server
//  (Railway + Redis) and merges the response. Dates are encoded as milliseconds
//  since 1970 to match the server's numeric `updatedAt` comparison.
//
//  This is only used when the user turns sync on; by default the app is fully
//  local and never touches the network.
//

import Foundation

final class RemoteSyncTransport: SyncTransport {
    let name = "Servidor (Railway)"

    private let baseURL: URL
    private let apiKey: String
    private let apiSecret: String
    private let session: URLSession

    init(baseURL: URL, apiKey: String, apiSecret: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.session = session
    }

    /// A reachable URL is considered available; real reachability is confirmed by
    /// the request itself.
    var isAvailable: Bool { true }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .millisecondsSince1970
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .millisecondsSince1970
        return d
    }()

    func exchange(_ payload: SyncPayload) async throws -> SyncPayload {
        var request = URLRequest(url: baseURL.appendingPathComponent("sync"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue(apiSecret, forHTTPHeaderField: "X-API-Secret")
        request.httpBody = try Self.encoder.encode(payload)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw SyncError.transport(NSError(domain: "RemoteSync", code: code,
                userInfo: [NSLocalizedDescriptionKey: "El servidor respondió \(code)."]))
        }
        return try Self.decoder.decode(SyncPayload.self, from: data)
    }
}
