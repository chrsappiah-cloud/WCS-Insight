import SwiftUI
import WCSCore

@main
struct PresencePlayCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 16) {
                Text("Presence Play Companion")
                    .font(.largeTitle.bold())
                Text("Schedule shared sessions, invite participants, and review reflections.")
                    .foregroundStyle(.secondary)
                WCSCard {
                    Label("Session invites and post-session summaries", systemImage: "person.2.wave.2")
                }
            }
            .padding()
        }
    }
}
