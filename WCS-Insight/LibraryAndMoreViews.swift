import SwiftData
import SwiftUI

struct LibraryView: View {
    @Query(sort: \MemoryArtifact.createdAt, order: .reverse) private var artifacts: [MemoryArtifact]
    @Query private var profiles: [PersonProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Memory Library")
                        .font(MemoryAtlasFont.display(24))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                        .padding(.horizontal, 4)

                    ForEach(artifacts, id: \.persistentModelID) { artifact in
                        libraryRow(artifact)
                    }
                }
                .padding(20)
            }
            .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Library")
        }
    }

    private func libraryRow(_ artifact: MemoryArtifact) -> some View {
        MemoryAtlasCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(artifact.title)
                        .font(MemoryAtlasFont.display(18))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                    Spacer()
                    Image(systemName: (MemoryArtifactKind(rawValue: artifact.kind) ?? .story).systemImage)
                        .foregroundStyle(MemoryAtlasTheme.sage)
                }
                if let profile = profiles.first(where: { $0.id == artifact.profileID }) {
                    Text(profile.preferredName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MemoryAtlasTheme.sageDark)
                }
                Text(artifact.artifactDescription)
                    .font(.caption)
                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                FlowLayoutTags(tags: artifact.tags)
            }
        }
    }
}

struct MoreView: View {
    @Query private var caregivers: [CaregiverAccount]
    @Query private var profiles: [PersonProfile]
    @Query private var artifacts: [MemoryArtifact]
    @Query private var sessions: [GuidedSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    MemoryAtlasCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Care Team")
                                .font(MemoryAtlasFont.display(20))
                            if let caregiver = caregivers.first {
                                Label(caregiver.displayName, systemImage: "person.crop.circle")
                                Text(caregiver.role)
                                    .font(.caption)
                                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    MemoryAtlasCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Workspace")
                                .font(MemoryAtlasFont.display(20))
                            statRow("Profiles", value: "\(profiles.count)")
                            statRow("Memory items", value: "\(artifacts.count)")
                            statRow("Guided sessions", value: "\(sessions.count)")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    MemoryAtlasCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Apple-native roadmap")
                                .font(MemoryAtlasFont.display(20))
                            Label("CloudKit backup scaffold", systemImage: "icloud")
                            Label("WidgetKit daily memory prompts", systemImage: "square.grid.2x2")
                            Label("Live Activities for active sessions", systemImage: "timer")
                            Label("visionOS spatial scenes (Phase 2)", systemImage: "visionpro")
                        }
                        .font(.caption)
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
            }
            .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("More")
        }
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(MemoryAtlasTheme.sageDark)
        }
        .font(.subheadline)
    }
}
