//
//  VehicleCatalogSeed.swift
//  MaximusPrecision
//
//  Curated catalog of the most common vehicle makes/models in Mexico (2015+).
//  Organized by tier so it can grow incrementally: tier 1 = top 3 makes; add
//  the next 3 as tier 2, and so on. Trims/versions are optional per model.
//

import Foundation

enum VehicleCatalogSeed {

    struct MakeSeed {
        let name: String
        let rank: Int
        let tier: Int
        let models: [ModelSeed]
    }

    struct ModelSeed {
        let name: String
        let yearStart: Int
        var trims: [String] = []
    }

    /// Tier 1 — the top 3 makes by sales volume in Mexico.
    static let all: [MakeSeed] = [
        MakeSeed(name: "Nissan", rank: 1, tier: 1, models: [
            ModelSeed(name: "Versa", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive"]),
            ModelSeed(name: "Sentra", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive", "SR"]),
            ModelSeed(name: "March", yearStart: 2015, trims: ["Sense", "Advance", "SR"]),
            ModelSeed(name: "Kicks", yearStart: 2017, trims: ["Sense", "Advance", "Exclusive", "Platinum"]),
            ModelSeed(name: "X-Trail", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive"]),
            ModelSeed(name: "Frontier", yearStart: 2015, trims: ["S", "SE", "LE", "PRO-4X", "Platinum"]),
            ModelSeed(name: "Note", yearStart: 2015, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Altima", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive"]),
            ModelSeed(name: "V-Drive", yearStart: 2020, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Pathfinder", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive"]),
            ModelSeed(name: "Murano", yearStart: 2015, trims: ["Exclusive"]),
            ModelSeed(name: "Qashqai", yearStart: 2018, trims: ["Sense", "Advance", "Exclusive", "Platinum"]),
        ]),

        MakeSeed(name: "Chevrolet", rank: 2, tier: 1, models: [
            ModelSeed(name: "Aveo", yearStart: 2015, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Beat", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Spark", yearStart: 2015, trims: ["LT", "LTZ"]),
            ModelSeed(name: "Onix", yearStart: 2021, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Cavalier", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Trax", yearStart: 2015, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Tracker", yearStart: 2021, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Equinox", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Groove", yearStart: 2022, trims: ["LS", "LT", "Premier"]),
            ModelSeed(name: "Captiva", yearStart: 2022, trims: ["LS", "LT", "Premier"]),
            ModelSeed(name: "Tahoe", yearStart: 2015, trims: ["LS", "LT", "Premier", "High Country"]),
            ModelSeed(name: "Suburban", yearStart: 2015, trims: ["LS", "LT", "Premier", "High Country"]),
            ModelSeed(name: "Silverado", yearStart: 2015, trims: ["WT", "LT", "LTZ", "High Country"]),
            ModelSeed(name: "Cheyenne", yearStart: 2015, trims: ["LS", "LT", "LTZ", "High Country"]),
        ]),

        MakeSeed(name: "Volkswagen", rank: 3, tier: 1, models: [
            ModelSeed(name: "Vento", yearStart: 2015, trims: ["Starline", "Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Jetta", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "GLI"]),
            ModelSeed(name: "Polo", yearStart: 2015, trims: ["Startline", "Comfortline", "Highline"]),
            ModelSeed(name: "Virtus", yearStart: 2020, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Gol", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Tiguan", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "R-Line"]),
            ModelSeed(name: "Teramont", yearStart: 2018, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "T-Cross", yearStart: 2020, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Taos", yearStart: 2021, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Saveiro", yearStart: 2015, trims: ["Starline", "Cabina sencilla", "Doble cabina"]),
            ModelSeed(name: "Golf", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "GTI"]),
            ModelSeed(name: "Nivus", yearStart: 2021, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "Amarok", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline"]),
        ]),
    ]
}
