//
//  VehicleCatalog.swift
//  MaximusPrecision
//
//  Reads the vehicle catalog out of SwiftData, seeding it on first launch.
//  Model lookups (which are the hot path while the user taps make pills) are
//  served from an LRU cache so repeated taps don't re-hit the store.
//

import Foundation
import SwiftData

@MainActor
final class VehicleCatalog {

    private let context: ModelContext
    private let modelsCache = LRUCache<String, [ModelOption]>(capacity: 16)

    init(context: ModelContext) {
        self.context = context
    }

    /// Inserts the curated catalog the first time the app runs (idempotent).
    func seedIfNeeded() {
        let existing = (try? context.fetchCount(FetchDescriptor<CatalogMake>())) ?? 0
        guard existing == 0 else { return }

        for makeSeed in VehicleCatalogSeed.all {
            let make = CatalogMake(name: makeSeed.name, rank: makeSeed.rank, tier: makeSeed.tier)
            context.insert(make)
            for (index, model) in makeSeed.models.enumerated() {
                let entry = CatalogModel(
                    name: model.name,
                    yearStart: model.yearStart,
                    order: index,
                    trims: model.trims
                )
                context.insert(entry)
                entry.make = make
            }
        }
        try? context.save()
    }

    /// Make names ordered by commonality, limited to the given tier.
    func makes(maxTier: Int = .max) -> [String] {
        var descriptor = FetchDescriptor<CatalogMake>(
            predicate: #Predicate { $0.tier <= maxTier },
            sortBy: [SortDescriptor(\.rank)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.models]
        let makes = (try? context.fetch(descriptor)) ?? []
        return makes.map(\.name)
    }

    /// Models for a make, ordered by commonality. Cached (LRU) by make name.
    func models(forMake makeName: String) -> [ModelOption] {
        let key = makeName.lowercased()
        if let cached = modelsCache.value(forKey: key) {
            return cached
        }

        // The catalog is small, so fetch makes and match case-insensitively.
        let makes = (try? context.fetch(FetchDescriptor<CatalogMake>())) ?? []
        let match = makes.first { $0.name.lowercased() == key }
        let options = (match?.models ?? [])
            .sorted { $0.order < $1.order }
            .map { ModelOption(name: $0.name, yearStart: $0.yearStart, trims: $0.trims) }

        modelsCache.set(options, forKey: key)
        return options
    }
}
