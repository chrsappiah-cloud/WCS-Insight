import SwiftUI
import WCSCore

@main
struct ScholarSphereStudioApp: App {
    var body: some Scene {
        WindowGroup {
            ScholarSphereRootView()
        }
    }
}

struct ScholarSphereRootView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Label("Projects", systemImage: "folder")
                Label("Assets", systemImage: "photo.on.rectangle")
                Label("Assessment", systemImage: "checklist")
                Label("Publish", systemImage: "paperplane")
                Label("Analytics", systemImage: "chart.xyaxis.line")
            }
            .navigationTitle("ScholarSphere")
        } detail: {
            VStack(alignment: .leading, spacing: 16) {
                Text("Immersive lesson builder")
                    .font(.largeTitle.bold())
                Text("Assemble video, spatial scenes, prompts, quizzes, narration, and publish-ready modules.")
                    .foregroundStyle(.secondary)
                WCSCard {
                    Text("APMP and immersive media export live behind the media processing service boundary.")
                }
            }
            .padding()
        }
    }
}
