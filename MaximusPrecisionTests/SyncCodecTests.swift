//
//  SyncCodecTests.swift
//  MaximusPrecisionTests
//
//  Guards the wire format the backend expects: dates as milliseconds since 1970
//  (a JSON number), so the server's numeric `updatedAt` comparison stays valid.
//

import XCTest
@testable import MaximusPrecision

final class SyncCodecTests: XCTestCase {

    func test_datesEncodeAsMillisecondsNumber() throws {
        var payload = SyncPayload(deviceID: "x")
        let when = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14
        payload.clients = [ClientDTO(syncID: "C1", updatedAt: when, deletedAt: nil,
                                     name: "Ana", phone: "", email: "", notes: "")]

        let data = try RemoteSyncTransport.encoder.encode(payload)
        let json = String(data: data, encoding: .utf8) ?? ""
        // 1_700_000_000 s → 1_700_000_000_000 ms, encoded as a bare number.
        XCTAssertTrue(json.contains("1700000000000"), "updatedAt should be ms since 1970: \(json)")
    }

    func test_payloadRoundTrips() throws {
        var payload = SyncPayload(deviceID: "dev")
        payload.vehicles = [VehicleDTO(syncID: "V1", updatedAt: Date(timeIntervalSince1970: 1_000),
                                       deletedAt: nil, plate: "ABC-1", brand: "Nissan", model: "Versa",
                                       year: "2020", color: "", vin: "", notes: "", clientSyncIDs: ["C1"])]

        let data = try RemoteSyncTransport.encoder.encode(payload)
        let back = try RemoteSyncTransport.decoder.decode(SyncPayload.self, from: data)

        XCTAssertEqual(back.vehicles.first?.plate, "ABC-1")
        XCTAssertEqual(back.vehicles.first?.clientSyncIDs, ["C1"])
        XCTAssertEqual(back.vehicles.first?.updatedAt, Date(timeIntervalSince1970: 1_000))
    }
}
