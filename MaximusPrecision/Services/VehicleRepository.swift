import Foundation
import SwiftData

protocol VehicleRepositoryProtocol {
    func brands(matching query: String) async -> [String]
    func models(for brand: String, matching query: String) async -> [String]
    func recordUsage(brand: String, model: String) async
}

@MainActor
class LocalVehicleRepository: VehicleRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func normalize(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: #"\b(sport|sr|limited|trendline|at|mt|plus|pro|max)\b"#,
                                   with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
    
    func brands(matching query: String) async -> [String] {
        if query.isEmpty { return [] }
        let normalizedQuery = normalize(query)
        
        // Fetch all brands and filter/sort in memory for better fuzzy control
        let descriptor = FetchDescriptor<VehicleBrand>()
        
        do {
            let allBrands = try context.fetch(descriptor)
            let matches = allBrands.filter { 
                $0.name.localizedCaseInsensitiveContains(normalizedQuery)
            }
            
            return matches.sorted { b1, b2 in
                let s1 = b1.name.lowercased().hasPrefix(normalizedQuery)
                let s2 = b2.name.lowercased().hasPrefix(normalizedQuery)
                if s1 != s2 { return s1 }
                return b1.name < b2.name
            }.prefix(5).map { $0.name }
        } catch {
            return []
        }
    }
    
    func models(for brand: String, matching query: String) async -> [String] {
        if query.isEmpty { return [] }
        let normalizedQuery = normalize(query)
        
        let descriptor = FetchDescriptor<VehicleModel>(
            predicate: #Predicate<VehicleModel> { model in
                model.brand?.name == brand
            }
        )
        
        do {
            let allModels = try context.fetch(descriptor)
            let matches = allModels.filter {
                $0.name.localizedCaseInsensitiveContains(normalizedQuery)
            }
            
            return matches.sorted { m1, m2 in
                let s1 = m1.name.lowercased().hasPrefix(normalizedQuery)
                let s2 = m2.name.lowercased().hasPrefix(normalizedQuery)
                if s1 != s2 { return s1 }
                if m1.usageCount != m2.usageCount { return m1.usageCount > m2.usageCount }
                return m1.name < m2.name
            }.prefix(5).map { $0.name }
        } catch {
            return []
        }
    }
    
    func recordUsage(brand: String, model: String) async {
        let descriptor = FetchDescriptor<VehicleModel>(
            predicate: #Predicate<VehicleModel> { m in
                m.brand?.name == brand && m.name == model
            }
        )
        
        do {
            if let match = try context.fetch(descriptor).first {
                match.usageCount += 1
                try context.save()
            }
        } catch {
            print("Record usage error: \(error)")
        }
    }
}
