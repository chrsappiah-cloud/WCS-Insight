import SwiftUI
import WCSCore

struct MemoryAtlasRootView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memory Atlas")
                            .font(.largeTitle.bold())
                        Text("Guided memory journeys for families, carers, and care teams.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    WCSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today’s calm session")
                                .font(.title2.bold())
                            Text("Start a gentle reminiscence flow with familiar photos, audio, and story prompts.")
                                .foregroundStyle(.secondary)
                            NavigationLink("Open session player") {
                                SessionPlayerView()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    ProfileListView()
                    MemoryArtifactListView()
                    SessionBuilderView()
                }
                .padding()
            }
            .background(WCSColor.cream.opacity(0.35))
        }
    }
}
