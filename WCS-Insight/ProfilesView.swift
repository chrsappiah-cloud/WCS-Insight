import SwiftData
import SwiftUI

struct ProfilesListView: View {
    @Query(sort: \PersonProfile.fullName) private var profiles: [PersonProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(profiles, id: \.id) { profile in
                        NavigationLink {
                            ProfileDetailView(profile: profile)
                        } label: {
                            profileRow(profile)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Profiles")
        }
    }

    private func profileRow(_ profile: PersonProfile) -> some View {
        MemoryAtlasCard {
            HStack(spacing: 14) {
                profilePortrait(for: profile)
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.preferredName)
                        .font(MemoryAtlasFont.display(22))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                    Text(profile.birthplace)
                        .font(.caption)
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    if profile.isActive {
                        Text("Active profile")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MemoryAtlasTheme.sageDark)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)
            }
        }
    }

    private func profilePortrait(for profile: PersonProfile) -> some View {
        ZStack {
            Circle()
                .fill(MemoryAtlasTheme.sageLight)
                .frame(width: 56, height: 56)
            Text(String(profile.preferredName.prefix(1)))
                .font(MemoryAtlasFont.display(24))
                .foregroundStyle(MemoryAtlasTheme.sageDark)
        }
    }
}

struct ProfileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var artifacts: [MemoryArtifact]

    let profile: PersonProfile
    @State private var selectedTab: ProfileDetailTab = .memories

    private var profileArtifacts: [MemoryArtifact] {
        artifacts
            .filter { $0.profileID == profile.id }
            .sorted { ($0.capturedAt ?? $0.createdAt) > ($1.capturedAt ?? $1.createdAt) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                tabPicker
                tabContent
                MemoryAtlasPrimaryButton("Add Memory Item", systemImage: "plus") {
                    addMemoryItem()
                }
            }
            .padding(20)
        }
        .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
        .navigationTitle(profile.preferredName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {}
                    .foregroundStyle(MemoryAtlasTheme.sage)
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MemoryAtlasTheme.sageLight, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(MemoryAtlasTheme.sage.opacity(0.55))
            }

            Text(profile.preferredName)
                .font(MemoryAtlasFont.display(30))
                .foregroundStyle(MemoryAtlasTheme.ink)

            Text("Born \(profile.birthDate.formatted(.dateTime.day().month(.wide).year()))")
                .font(MemoryAtlasFont.body(14))
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)

            Text(profile.birthplace)
                .font(MemoryAtlasFont.body(14))
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)

            Text("\"\(profile.personalQuote)\"")
                .font(.system(.body, design: .serif).italic())
                .foregroundStyle(MemoryAtlasTheme.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(ProfileDetailTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedTab == tab ? .white : MemoryAtlasTheme.secondaryInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab ? MemoryAtlasTheme.sage : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.7), in: Capsule())
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .memories:
            VStack(spacing: 12) {
                ForEach(profileArtifacts, id: \.persistentModelID) { artifact in
                    MemoryArtifactRow(artifact: artifact)
                }
            }
        case .about:
            MemoryAtlasCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("About \(profile.preferredName)")
                        .font(MemoryAtlasFont.display(20))
                    Text(profile.diagnosisNotes.isEmpty ? "No clinical notes recorded yet." : profile.diagnosisNotes)
                        .font(MemoryAtlasFont.body(14))
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                }
            }
        case .preferences:
            MemoryAtlasCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Preferences")
                        .font(MemoryAtlasFont.display(20))
                    Label("Primary language: \(profile.primaryLanguage.uppercased())", systemImage: "globe")
                    Label("Prefers audio-led prompts", systemImage: "speaker.wave.2")
                    Label("Large typography enabled", systemImage: "textformat.size")
                }
                .font(MemoryAtlasFont.body(14))
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)
            }
        }
    }

    private func addMemoryItem() {
        let artifact = MemoryArtifact(
            profileID: profile.id,
            title: "New Memory",
            kind: MemoryArtifactKind.story.rawValue,
            artifactDescription: "Tap edit to add details about this memory.",
            tags: ["New"]
        )
        modelContext.insert(artifact)
        try? modelContext.save()
    }
}

struct MemoryArtifactRow: View {
    let artifact: MemoryArtifact

    private var kind: MemoryArtifactKind {
        MemoryArtifactKind(rawValue: artifact.kind) ?? .story
    }

    var body: some View {
        MemoryAtlasCard {
            HStack(alignment: .top, spacing: 12) {
                artifactThumbnail
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(artifact.title)
                            .font(MemoryAtlasFont.display(18))
                            .foregroundStyle(MemoryAtlasTheme.ink)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    }
                    Text(artifact.artifactDescription)
                        .font(.caption)
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    if let duration = artifact.durationSeconds {
                        Text(formatDuration(duration))
                            .font(.caption2)
                            .foregroundStyle(MemoryAtlasTheme.sageDark)
                    }
                    FlowLayoutTags(tags: artifact.tags)
                }
            }
        }
    }

    @ViewBuilder
    private var artifactThumbnail: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(thumbnailColor)
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: kind.systemImage)
                    .foregroundStyle(.white)
            }
    }

    private var thumbnailColor: Color {
        switch kind {
        case .photo: MemoryAtlasTheme.sage
        case .audio: MemoryAtlasTheme.sageDark
        case .video: MemoryAtlasTheme.gold
        case .story: MemoryAtlasTheme.secondaryInk.opacity(0.55)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}

struct FlowLayoutTags: View {
    let tags: [String]

    var body: some View {
        FlexibleTagWrap(tags: tags) { tag in
            MemoryAtlasTag(text: tag)
        }
    }
}

struct FlexibleTagWrap<TagContent: View>: View {
    let tags: [String]
    let content: (String) -> TagContent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tagRows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        content(tag)
                    }
                }
            }
        }
    }

    private var tagRows: [[String]] {
        var rows: [[String]] = [[]]
        var currentWidth = 0
        for tag in tags {
            let tagWidth = tag.count * 8 + 28
            if currentWidth + tagWidth > 260, !rows[rows.count - 1].isEmpty {
                rows.append([tag])
                currentWidth = tagWidth
            } else {
                rows[rows.count - 1].append(tag)
                currentWidth += tagWidth
            }
        }
        return rows
    }
}
