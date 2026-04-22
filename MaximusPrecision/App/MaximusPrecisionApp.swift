import SwiftUI
import SwiftData

@main
struct MaximusPrecisionApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([VehicleBrand.self, VehicleModel.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .task {
                    await VehicleSeeder.seed(context: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
