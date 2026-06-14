import SwiftUI
import WCSCore

@main
struct PresencePlayVisionApp: App {
    var body: some Scene {
        WindowGroup {
            PresencePlayRootView()
        }

        ImmersiveSpace(id: "presence-preview") {
            PresencePlayImmersivePlaceholder()
        }
    }
}

struct PresencePlayRootView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Presence Play")
                .font(.largeTitle.bold())
            Text("Shared presence for care, learning, and story.")
                .font(.title3)
                .foregroundStyle(.secondary)
            WCSCard {
                VStack(alignment: .leading) {
                    Text("Single-user prototype first")
                        .font(.headline)
                    Text("RealityKit scene orchestration and shared sync are intentionally isolated behind service boundaries.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

struct PresencePlayImmersivePlaceholder: View {
    var body: some View {
        Text("Presence Play immersive scene boundary")
    }
}
