//
//  CatalogModels.swift
//  MaximusPrecision
//
//  SwiftData entities for the vehicle catalog (makes → models, with optional
//  trims/versions) plus a lightweight value type used by the UI and the cache.
//

import Foundation
import SwiftData

@Model
final class CatalogMake {
    // Not marked `.unique`: seeding only runs on an empty store, and a unique
    // index can trap when multiple in-process containers share the schema.
    var name: String
    /// Lower rank = more common in Mexico (1 = most common).
    var rank: Int
    /// Tier of rollout: tier 1 = top 3 makes, tier 2 = next 3, etc.
    var tier: Int
    @Relationship(deleteRule: .cascade, inverse: \CatalogModel.make)
    var models: [CatalogModel]

    init(name: String, rank: Int, tier: Int, models: [CatalogModel] = []) {
        self.name = name
        self.rank = rank
        self.tier = tier
        self.models = models
    }
}

@Model
final class CatalogModel {
    var name: String
    /// First model year available in Mexico (catalog starts at 2015).
    var yearStart: Int
    /// Curated commonality order within the make (0 = most common).
    var order: Int
    /// Optional trims/versions (e.g. "Sense", "Advance", "Exclusive"). May be empty.
    var trims: [String]
    var make: CatalogMake?

    init(name: String, yearStart: Int, order: Int, trims: [String] = [], make: CatalogMake? = nil) {
        self.name = name
        self.yearStart = yearStart
        self.order = order
        self.trims = trims
        self.make = make
    }
}

/// Immutable snapshot of a catalog model for the UI / LRU cache, so views never
/// hold on to live SwiftData objects.
struct ModelOption: Hashable, Identifiable {
    let name: String
    let yearStart: Int
    let trims: [String]
    var id: String { name }

    var hasTrims: Bool { !trims.isEmpty }
}
