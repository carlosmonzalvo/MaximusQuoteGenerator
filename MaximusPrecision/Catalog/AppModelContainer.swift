//
//  AppModelContainer.swift
//  MaximusPrecision
//
//  Single shared SwiftData container for the whole process. Using one instance
//  (instead of one per call site) avoids creating multiple containers for the
//  same schema in a single process — which SwiftData can trap on, e.g. when the
//  unit-test host app and a test both spin one up.
//

import Foundation
import SwiftData

enum AppModelContainer {
    static let shared: ModelContainer = {
        // Tests use an ephemeral in-memory store; production persists on disk.
        let config = ModelConfiguration(isStoredInMemoryOnly: LaunchArgument.isRunningTests)
        do {
            return try ModelContainer(
                for: CatalogMake.self, CatalogModel.self,
                ClientRecord.self, VehicleRecord.self, ServiceRecord.self,
                configurations: config
            )
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }()
}
