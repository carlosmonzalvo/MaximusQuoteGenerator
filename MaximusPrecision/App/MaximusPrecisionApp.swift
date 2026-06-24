import SwiftUI
import SwiftData

@main
struct MaximusPrecisionApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(AppModelContainer.shared)
    }
}
