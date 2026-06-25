//
//  PeerSyncTransport.swift
//  MaximusPrecision
//
//  Peer-to-peer sync over MultipeerConnectivity (Bluetooth / peer Wi-Fi), so a
//  Mac and an iPhone can sync directly with no backend. It advertises and
//  browses for the same service, auto-connects nearby peers, and exchanges
//  SyncPayloads. Works on iOS and macOS.
//
//  Exchange protocol: the initiator sends a request envelope; the responder
//  merges it (via `onReceive`) and replies with its own snapshot; the initiator
//  merges that reply. Conflict resolution stays last-write-wins in SyncEngine.
//

import Foundation
import MultipeerConnectivity

@MainActor
final class PeerSyncTransport: NSObject, SyncTransport, ObservableObject {
    let name = "Bluetooth (cercanos)"

    /// MultipeerConnectivity service type: 1–15 chars, lowercase/digits/hyphen.
    static let serviceType = "maximus-sync"

    @Published private(set) var connectedPeers: [String] = []

    /// Called on the main actor whenever the connected-peer list changes.
    var onPeersChanged: (([String]) -> Void)?

    /// Merges an incoming payload and returns the local snapshot to send back.
    private let onReceive: (SyncPayload) -> SyncPayload

    private let peerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    private var pending: CheckedContinuation<SyncPayload, Error>?

    init(displayName: String, onReceive: @escaping (SyncPayload) -> SyncPayload) {
        self.onReceive = onReceive
        let trimmed = String(displayName.prefix(63))
        self.peerID = MCPeerID(displayName: trimmed.isEmpty ? "Maximus" : trimmed)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: Self.serviceType)
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        connectedPeers = []
    }

    var isAvailable: Bool { !session.connectedPeers.isEmpty }

    func exchange(_ payload: SyncPayload) async throws -> SyncPayload {
        guard !session.connectedPeers.isEmpty else { throw SyncError.transportUnavailable }
        let envelope = PeerEnvelope(isReply: false, payload: payload)
        let data = try PeerEnvelope.encoder.encode(envelope)

        return try await withCheckedThrowingContinuation { continuation in
            self.pending = continuation
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                self.pending = nil
                continuation.resume(throwing: SyncError.transport(error))
                return
            }
            // Bound the wait so a silent peer can't hang the sync.
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                guard let self, let cont = self.pending else { return }
                self.pending = nil
                cont.resume(throwing: SyncError.transport(
                    NSError(domain: "PeerSync", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "El dispositivo cercano no respondió."])))
            }
        }
    }

    private func handle(_ data: Data, from peer: MCPeerID) {
        guard let envelope = try? PeerEnvelope.decoder.decode(PeerEnvelope.self, from: data) else { return }
        if envelope.isReply {
            // We initiated; deliver the reply to the awaiting exchange().
            if let cont = pending {
                pending = nil
                cont.resume(returning: envelope.payload)
            }
        } else {
            // We are the responder: merge and reply with our snapshot.
            let reply = onReceive(envelope.payload)
            if let out = try? PeerEnvelope.encoder.encode(PeerEnvelope(isReply: true, payload: reply)) {
                try? session.send(out, toPeers: [peer], with: .reliable)
            }
        }
    }

    private func refreshPeers() {
        connectedPeers = session.connectedPeers.map(\.displayName)
        onPeersChanged?(connectedPeers)
    }
}

// MARK: - MultipeerConnectivity delegates

extension PeerSyncTransport: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in self.refreshPeers() }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Task { @MainActor in self.handle(data, from: peerID) }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension PeerSyncTransport: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations from peers using the same service.
        Task { @MainActor in invitationHandler(true, self.session) }
    }
}

extension PeerSyncTransport: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            self.browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 15)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in self.refreshPeers() }
    }
}

// MARK: - Wire envelope

struct PeerEnvelope: Codable {
    var isReply: Bool
    var payload: SyncPayload

    static let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .millisecondsSince1970; return e
    }()
    static let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .millisecondsSince1970; return d
    }()
}
