import Foundation
import SwiftData

@Model
class VehicleBrand {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \VehicleModel.brand) 
    var models: [VehicleModel] = []

    init(name: String) {
        self.name = name
    }
}
