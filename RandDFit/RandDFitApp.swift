import SwiftUI
import SwiftData

@main
struct Gate2GoApp: App {
    @StateObject private var settings = Gate2GoSettings()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProjectModel.self,
            GateDesignModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .modelContainer(sharedModelContainer)
    }
}
