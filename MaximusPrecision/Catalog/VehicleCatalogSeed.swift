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
            ModelSeed(name: "X-Trail", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive", "e-Power"]),
            ModelSeed(name: "Frontier", yearStart: 2015, trims: ["S", "SE", "LE", "PRO-4X", "Platinum"]),
            ModelSeed(name: "NP300", yearStart: 2015, trims: ["Estacas", "Doble cabina", "Frontier"]),
            ModelSeed(name: "Note", yearStart: 2015, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Altima", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive", "SR"]),
            ModelSeed(name: "V-Drive", yearStart: 2020, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Pathfinder", yearStart: 2015, trims: ["Sense", "Advance", "Exclusive"]),
            ModelSeed(name: "Murano", yearStart: 2015, trims: ["Advance", "Exclusive"]),
            ModelSeed(name: "Qashqai", yearStart: 2018, trims: ["Sense", "Advance", "Exclusive", "Platinum"]),
            ModelSeed(name: "Tiida", yearStart: 2015, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Tsuru", yearStart: 2015, trims: ["GS I", "GS II"]),
            ModelSeed(name: "Urvan", yearStart: 2015, trims: ["Panel", "15 pasajeros", "Amplia"]),
            ModelSeed(name: "Leaf", yearStart: 2018, trims: ["Sense", "Advance"]),
            ModelSeed(name: "Maxima", yearStart: 2016, trims: ["Exclusive", "SR"]),
            ModelSeed(name: "Sentra Nismo", yearStart: 2017, trims: ["Nismo"]),
            ModelSeed(name: "GT-R", yearStart: 2015, trims: ["Premium", "Track Edition", "Nismo"]),
            ModelSeed(name: "370Z", yearStart: 2015, trims: ["Touring", "Nismo"]),
            ModelSeed(name: "Z", yearStart: 2023, trims: ["Performance", "Nismo"]),
            ModelSeed(name: "Armada", yearStart: 2017, trims: ["Exclusive", "Platinum"]),
        ]),

        MakeSeed(name: "Chevrolet", rank: 2, tier: 1, models: [
            ModelSeed(name: "Aveo", yearStart: 2015, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Beat", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Beat Notchback", yearStart: 2019, trims: ["LT", "LTZ"]),
            ModelSeed(name: "Spark", yearStart: 2015, trims: ["LT", "LTZ"]),
            ModelSeed(name: "Onix", yearStart: 2021, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Cavalier", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Sonic", yearStart: 2015, trims: ["LS", "LT", "LTZ"]),
            ModelSeed(name: "Cruze", yearStart: 2015, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Malibu", yearStart: 2016, trims: ["LS", "LT", "Premier"]),
            ModelSeed(name: "Trax", yearStart: 2015, trims: ["LS", "LT", "LTZ", "Premier"]),
            ModelSeed(name: "Tracker", yearStart: 2021, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Equinox", yearStart: 2018, trims: ["LS", "LT", "LTZ", "Premier", "RS"]),
            ModelSeed(name: "Blazer", yearStart: 2019, trims: ["LT", "RS", "Premier"]),
            ModelSeed(name: "Traverse", yearStart: 2018, trims: ["LT", "Premier", "High Country"]),
            ModelSeed(name: "Groove", yearStart: 2022, trims: ["LS", "LT", "Premier"]),
            ModelSeed(name: "Captiva", yearStart: 2022, trims: ["LS", "LT", "Premier"]),
            ModelSeed(name: "Tahoe", yearStart: 2015, trims: ["LS", "LT", "Premier", "High Country"]),
            ModelSeed(name: "Suburban", yearStart: 2015, trims: ["LS", "LT", "Premier", "High Country"]),
            ModelSeed(name: "Silverado", yearStart: 2015, trims: ["WT", "LT", "LTZ", "High Country", "ZR2"]),
            ModelSeed(name: "Cheyenne", yearStart: 2015, trims: ["LS", "LT", "LTZ", "High Country"]),
            ModelSeed(name: "S10 Max", yearStart: 2023, trims: ["LS", "LT", "LTZ"]),
            ModelSeed(name: "Tornado", yearStart: 2015, trims: ["LS", "LT"]),
            ModelSeed(name: "Camaro", yearStart: 2015, trims: ["LT", "RS", "SS", "ZL1"]),
            ModelSeed(name: "Corvette", yearStart: 2015, trims: ["Stingray", "Z06"]),
            ModelSeed(name: "Bolt EV", yearStart: 2017, trims: ["LT", "Premier"]),
            ModelSeed(name: "Bolt EUV", yearStart: 2022, trims: ["LT", "Premier"]),
        ]),

        MakeSeed(name: "Volkswagen", rank: 3, tier: 1, models: [
            ModelSeed(name: "Vento", yearStart: 2015, trims: ["Starline", "Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Jetta", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "GLI"]),
            ModelSeed(name: "Polo", yearStart: 2015, trims: ["Startline", "Comfortline", "Highline"]),
            ModelSeed(name: "Virtus", yearStart: 2020, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Gol", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Gol Sedán", yearStart: 2015, trims: ["Trendline", "Comfortline"]),
            ModelSeed(name: "Up!", yearStart: 2016, trims: ["Take Up!", "Move Up!", "High Up!"]),
            ModelSeed(name: "Beetle", yearStart: 2015, trims: ["Sport", "Sportline", "Turbo"]),
            ModelSeed(name: "CrossFox", yearStart: 2015, trims: ["Estándar"]),
            ModelSeed(name: "Tiguan", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "R-Line"]),
            ModelSeed(name: "Teramont", yearStart: 2018, trims: ["Comfortline", "Highline", "R-Line"]),
            ModelSeed(name: "Cross Sport", yearStart: 2021, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "T-Cross", yearStart: 2020, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Taos", yearStart: 2021, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "Saveiro", yearStart: 2015, trims: ["Starline", "Cabina sencilla", "Doble cabina"]),
            ModelSeed(name: "Golf", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline", "GTI", "R"]),
            ModelSeed(name: "Golf Sportwagen", yearStart: 2015, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "Passat", yearStart: 2015, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "Nivus", yearStart: 2021, trims: ["Comfortline", "Highline"]),
            ModelSeed(name: "Amarok", yearStart: 2015, trims: ["Trendline", "Comfortline", "Highline"]),
            ModelSeed(name: "ID.4", yearStart: 2023, trims: ["Pro", "Pro S"]),
        ]),

        // Tier 2 — the next 3 makes.
        MakeSeed(name: "KIA", rank: 4, tier: 2, models: [
            ModelSeed(name: "Rio", yearStart: 2016, trims: ["LX", "EX", "SX"]),
            ModelSeed(name: "Río Sedán", yearStart: 2018, trims: ["LX", "EX"]),
            ModelSeed(name: "Forte", yearStart: 2017, trims: ["LX", "EX", "GT", "GT-Line"]),
            ModelSeed(name: "Forte5", yearStart: 2017, trims: ["LX", "EX", "GT"]),
            ModelSeed(name: "K3", yearStart: 2024, trims: ["LX", "EX", "GT-Line"]),
            ModelSeed(name: "K4", yearStart: 2025, trims: ["LX", "EX", "GT-Line"]),
            ModelSeed(name: "K5", yearStart: 2021, trims: ["LX", "EX", "GT-Line"]),
            ModelSeed(name: "Optima", yearStart: 2016, trims: ["LX", "EX", "SX"]),
            ModelSeed(name: "Picanto", yearStart: 2018, trims: ["LX", "EX"]),
            ModelSeed(name: "Soul", yearStart: 2015, trims: ["LX", "EX", "GT-Line"]),
            ModelSeed(name: "Sportage", yearStart: 2015, trims: ["LX", "EX", "SX", "GT-Line"]),
            ModelSeed(name: "Seltos", yearStart: 2021, trims: ["LX", "EX", "SX"]),
            ModelSeed(name: "Sorento", yearStart: 2016, trims: ["LX", "EX", "SX"]),
            ModelSeed(name: "Sonet", yearStart: 2024, trims: ["LX", "EX", "GT-Line"]),
            ModelSeed(name: "Carnival", yearStart: 2022, trims: ["EX", "SX"]),
            ModelSeed(name: "Niro", yearStart: 2017, trims: ["EX", "SX"]),
            ModelSeed(name: "Stinger", yearStart: 2018, trims: ["GT-Line", "GT"]),
            ModelSeed(name: "EV6", yearStart: 2023, trims: ["GT-Line", "GT"]),
        ]),

        MakeSeed(name: "Toyota", rank: 5, tier: 2, models: [
            ModelSeed(name: "Yaris", yearStart: 2015, trims: ["Core", "S", "Premium"]),
            ModelSeed(name: "Yaris Sedán", yearStart: 2015, trims: ["Core", "S", "Premium"]),
            ModelSeed(name: "Yaris Cross", yearStart: 2024, trims: ["LE", "XLE"]),
            ModelSeed(name: "Corolla", yearStart: 2015, trims: ["Base", "LE", "SE", "XSE", "Hybrid"]),
            ModelSeed(name: "Corolla Cross", yearStart: 2022, trims: ["Base", "XLE", "Hybrid"]),
            ModelSeed(name: "C-HR", yearStart: 2018, trims: ["Base", "Limited"]),
            ModelSeed(name: "RAV4", yearStart: 2015, trims: ["LE", "XLE", "Limited", "Adventure", "Hybrid"]),
            ModelSeed(name: "Hilux", yearStart: 2015, trims: ["Base", "SR", "SRV", "GR-Sport"]),
            ModelSeed(name: "Tacoma", yearStart: 2016, trims: ["SR", "TRD Sport", "TRD Off-Road", "Limited"]),
            ModelSeed(name: "Tundra", yearStart: 2015, trims: ["SR5", "Limited", "Platinum", "1794 Edition"]),
            ModelSeed(name: "Avanza", yearStart: 2015, trims: ["LE", "XLE"]),
            ModelSeed(name: "Raize", yearStart: 2023, trims: ["LE", "XLE"]),
            ModelSeed(name: "Highlander", yearStart: 2015, trims: ["LE", "XLE", "Limited"]),
            ModelSeed(name: "4Runner", yearStart: 2015, trims: ["SR5", "TRD Off-Road", "Limited"]),
            ModelSeed(name: "Sequoia", yearStart: 2015, trims: ["SR5", "Limited", "Platinum"]),
            ModelSeed(name: "Land Cruiser", yearStart: 2015, trims: ["GX-R", "VX"]),
            ModelSeed(name: "Camry", yearStart: 2015, trims: ["LE", "XLE", "XSE", "Hybrid"]),
            ModelSeed(name: "Prius", yearStart: 2016, trims: ["Base", "Premium"]),
            ModelSeed(name: "Sienna", yearStart: 2015, trims: ["LE", "XLE", "Limited"]),
            ModelSeed(name: "GR86", yearStart: 2022, trims: ["Base", "Premium"]),
            ModelSeed(name: "GR Corolla", yearStart: 2023, trims: ["Core", "Circuit"]),
            ModelSeed(name: "GR Supra", yearStart: 2020, trims: ["3.0", "3.0 Premium"]),
        ]),

        MakeSeed(name: "Mazda", rank: 6, tier: 2, models: [
            ModelSeed(name: "Mazda 2", yearStart: 2015, trims: ["i", "Sport", "Touring", "Grand Touring"]),
            ModelSeed(name: "Mazda 2 Sedán", yearStart: 2016, trims: ["i", "Grand Touring"]),
            ModelSeed(name: "Mazda 3", yearStart: 2015, trims: ["i", "Sport", "Grand Touring", "Signature"]),
            ModelSeed(name: "Mazda 3 Sedán", yearStart: 2015, trims: ["i", "Grand Touring", "Signature"]),
            ModelSeed(name: "Mazda 6", yearStart: 2015, trims: ["i Sport", "i Grand Touring", "Signature"]),
            ModelSeed(name: "CX-3", yearStart: 2016, trims: ["i Sport", "i Grand Touring"]),
            ModelSeed(name: "CX-30", yearStart: 2020, trims: ["i Sport", "i Grand Touring", "Signature"]),
            ModelSeed(name: "CX-5", yearStart: 2015, trims: ["i Sport", "i Grand Touring", "Signature", "Carbon Edition"]),
            ModelSeed(name: "CX-50", yearStart: 2023, trims: ["Sport", "Grand Touring", "Signature"]),
            ModelSeed(name: "CX-9", yearStart: 2016, trims: ["Sport", "Grand Touring", "Signature"]),
            ModelSeed(name: "CX-70", yearStart: 2025, trims: ["Preferred", "Premium", "Signature"]),
            ModelSeed(name: "CX-90", yearStart: 2024, trims: ["Preferred", "Premium", "Signature"]),
            ModelSeed(name: "MX-5", yearStart: 2016, trims: ["i Sport", "Grand Touring", "RF"]),
        ]),
    ]
}
