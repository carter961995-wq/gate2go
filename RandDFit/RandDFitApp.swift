//
//  RandDFitApp.swift
//  RandDFit
//
//  Created by Logan Carter on 1/9/26.
//

import SwiftUI
import SwiftData

@main
struct RandDFitApp: App {
    @StateObject private var settings = Gate2GoSettings()

    private static let modelSchema = Schema([
        ProjectModel.self,
        GateDesignModel.self,
        Item.self,
    ])

    private static func storeURL() throws -> URL {
        let appSupport = try FileManager.default.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
        let bundleID = Bundle.main.bundleIdentifier ?? "RandDFit"
        let directory = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("RandDFit.sqlite")
    }

    private static func destroyStore(at url: URL) throws {
        let fileManager = FileManager.default
        let walURL = URL(fileURLWithPath: url.path + "-wal")
        let shmURL = URL(fileURLWithPath: url.path + "-shm")
        for file in [url, walURL, shmURL] {
            if fileManager.fileExists(atPath: file.path) {
                try fileManager.removeItem(at: file)
            }
        }
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = modelSchema
        do {
            let storeURL = try storeURL()
            let config = ModelConfiguration(schema: schema, url: storeURL)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("SwiftData store failed to load: \(error)")
            do {
                let storeURL = try storeURL()
                try destroyStore(at: storeURL)
                let config = ModelConfiguration(schema: schema, url: storeURL)
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                let resetError = error
                print("SwiftData store reset failed: \(resetError)")
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                if let container = try? ModelContainer(for: schema, configurations: [memoryConfig]) {
                    return container
                }
                fatalError("Could not create in-memory ModelContainer: \(resetError)")
            }
        }
    }

    var sharedModelContainer: ModelContainer = RandDFitApp.makeModelContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .modelContainer(sharedModelContainer)
    }
}
