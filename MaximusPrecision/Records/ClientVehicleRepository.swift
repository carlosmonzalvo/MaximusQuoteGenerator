//
//  ClientVehicleRepository.swift
//  MaximusPrecision
//
//  CRUD + association layer over the SwiftData records. Keeps SwiftData calls
//  out of the views/view-models and centralizes the upsert/link rules for the
//  patient (vehicle) ↔ payer (client) relationship.
//

import Foundation
import SwiftData

@MainActor
final class ClientVehicleRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Fetch

    func clients() -> [ClientRecord] {
        let descriptor = FetchDescriptor<ClientRecord>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func vehicles() -> [VehicleRecord] {
        let descriptor = FetchDescriptor<VehicleRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: Upsert

    /// Finds a client by case-insensitive name + phone, or creates one.
    @discardableResult
    func upsertClient(name: String, phone: String = "", email: String = "") -> ClientRecord? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let existing = clients().first(where: {
            $0.name.caseInsensitiveCompare(trimmed) == .orderedSame && $0.phone == phone
        }) {
            if existing.email.isEmpty, !email.isEmpty {
                existing.email = email
                existing.updatedAt = .now; existing.needsPush = true
            }
            return existing
        }

        let client = ClientRecord(name: trimmed, phone: phone, email: email)
        context.insert(client)
        return client
    }

    /// Finds a vehicle by case-insensitive plate, or creates one. The plate is
    /// the patient's identity.
    @discardableResult
    func upsertVehicle(
        plate: String,
        brand: String = "",
        model: String = "",
        year: String = ""
    ) -> VehicleRecord? {
        let trimmed = plate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let existing = vehicles().first(where: {
            $0.plate.caseInsensitiveCompare(trimmed) == .orderedSame
        }) {
            // Keep the latest descriptive fields if they were filled in.
            if !brand.isEmpty { existing.brand = brand }
            if !model.isEmpty { existing.model = model }
            if !year.isEmpty { existing.year = year }
            existing.updatedAt = .now; existing.needsPush = true
            return existing
        }

        let vehicle = VehicleRecord(plate: trimmed, brand: brand, model: model, year: year)
        context.insert(vehicle)
        return vehicle
    }

    // MARK: Association

    /// Links a client (payer) to a vehicle (patient) if not already linked.
    /// Non-exclusive: a vehicle keeps every client it has ever been linked to.
    func link(client: ClientRecord, to vehicle: VehicleRecord) {
        guard !vehicle.clients.contains(where: { $0.persistentModelID == client.persistentModelID }) else { return }
        vehicle.clients.append(client)
        vehicle.updatedAt = .now; vehicle.needsPush = true
    }

    // MARK: Insert / Delete

    func insert(_ client: ClientRecord) { context.insert(client) }
    func insert(_ vehicle: VehicleRecord) { context.insert(vehicle) }

    func delete(_ client: ClientRecord) { context.delete(client) }
    func delete(_ vehicle: VehicleRecord) { context.delete(vehicle) }

    // MARK: Service history

    /// Persists a generated document as a service on the vehicle's history,
    /// upserting/linking the patient and payer. Returns the stored record.
    @discardableResult
    func recordService(from quote: Quote) -> ServiceRecord? {
        let vehicle = upsertVehicle(
            plate: quote.vehicle.plate,
            brand: quote.vehicle.brand,
            model: quote.vehicle.model,
            year: quote.vehicle.year
        )
        let payer = upsertClient(name: quote.customer.name, phone: quote.customer.phone)

        // Need at least a patient to file a visit under.
        guard let vehicle else { return nil }
        if let payer { link(client: payer, to: vehicle) }

        let service = ServiceRecord(
            folio: quote.folio,
            date: quote.date,
            documentType: quote.documentType,
            notes: quote.notes,
            includesIVA: quote.includesIVA,
            includesCardFee: quote.includesCardFee,
            items: quote.items,
            subtotal: quote.subtotal,
            ivaAmount: quote.ivaAmount,
            cardFeeAmount: quote.cardFeeAmount,
            total: quote.total,
            vehicle: vehicle,
            payer: payer
        )
        context.insert(service)
        return service
    }

    func save() {
        try? context.save()
    }
}
