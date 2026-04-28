import Foundation
import SwiftData

struct VehicleSeedRow: Codable {
    let brand: String
    let models: [String]
}

@MainActor
class VehicleSeeder {
    static func seed(context: ModelContext) async {
        // Check if already seeded
        let descriptor = FetchDescriptor<VehicleBrand>()
        do {
            let count = try context.fetchCount(descriptor)
            if count > 0 { return } // Already seeded
            
            guard let url = Bundle.main.url(forResource: "vehicles", withExtension: "json") else {
                print("Seeder: vehicles.json not found")
                return
            }
            
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([VehicleSeedRow].self, from: data)
            
            for row in decoded {
                let brand = VehicleBrand(name: row.brand)
                context.insert(brand)
                
                for modelName in row.models {
                    let model = VehicleModel(name: modelName, brand: brand)
                    context.insert(model)
                }
            }
            
            try context.save()
            print("Seeder: Database successfully seeded")
            
        } catch {
            print("Seeder Error: \(error.localizedDescription)")
        }
    }
}
