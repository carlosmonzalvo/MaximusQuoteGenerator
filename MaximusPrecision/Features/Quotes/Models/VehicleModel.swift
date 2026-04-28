import Foundation
import SwiftData

@Model
class VehicleModel {
    @Attribute(.unique) var name: String
    var brand: VehicleBrand?
    var usageCount: Int = 0

    init(name: String, brand: VehicleBrand? = nil) {
        self.name = name
        self.brand = brand
        self.usageCount = 0
    }
}
