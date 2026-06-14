import SwiftData
import SwiftUI

@main
struct WCS_InsightApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CaregiverAccount.self,
            PersonProfile.self,
            MemoryArtifact.self,
            GuidedSession.self,
            GuidedSessionStep.self,
            SessionRun.self,
            CaregiverNote.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
