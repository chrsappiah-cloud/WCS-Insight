import SwiftUI
import WCSCore

struct MemoryArtifactListView: View {
    private let artifacts: [MemoryArtifact] = [
        .init(profileID: UUID(), title: "Wedding Day", kind: .photo, notes: "At the church with family", tags: ["family", "wedding"]),
        .init(profileID: UUID(), title: "Favourite hymn", kind: .audio, notes: "Recorded by Sarah", tags: ["music", "calm"]),
        .init(profileID: UUID(), title: "Home garden", kind: .story, notes: "A prompt about Sunday mornings", tags: ["home", "garden"])
    ]

    var body: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Memory artifacts")
                    .font(.title3.bold())
                ForEach(artifacts) { artifact in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon(for: artifact.kind))
                            .font(.title2)
                            .foregroundStyle(WCSColor.sage)
                            .frame(width: 36)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(artifact.title).font(.headline)
                            Text(artifact.notes).font(.subheadline).foregroundStyle(.secondary)
                            HStack { ForEach(artifact.tags, id: \.self) { WCSPill($0) } }
                        }
                    }
                }
            }
        }
    }

    private func icon(for kind: MemoryArtifact.Kind) -> String {
        switch kind {
        case .photo: "photo"
        case .audio: "waveform"
        case .video: "play.rectangle"
        case .story: "text.book.closed"
        }
    }
}
