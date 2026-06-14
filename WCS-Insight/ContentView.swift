import SwiftData
import SwiftUI

private enum MemoryAtlasTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case profiles = "Profiles"
    case sessions = "Sessions"
    case library = "Library"
    case more = "More"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .profiles: "person.2.fill"
        case .sessions: "play.circle.fill"
        case .library: "books.vertical.fill"
        case .more: "ellipsis.circle.fill"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var caregivers: [CaregiverAccount]
    @Query private var profiles: [PersonProfile]

    @State private var selectedTab: MemoryAtlasTab = .home
    @State private var activeSession: GuidedSession?
    @State private var showingSessionPlayer = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(activeSession: $activeSession, showingSessionPlayer: $showingSessionPlayer)
                .tabItem { Label(MemoryAtlasTab.home.rawValue, systemImage: MemoryAtlasTab.home.systemImage) }
                .tag(MemoryAtlasTab.home)

            ProfilesListView()
                .tabItem { Label(MemoryAtlasTab.profiles.rawValue, systemImage: MemoryAtlasTab.profiles.systemImage) }
                .tag(MemoryAtlasTab.profiles)

            SessionsListView(activeSession: $activeSession, showingSessionPlayer: $showingSessionPlayer)
                .tabItem { Label(MemoryAtlasTab.sessions.rawValue, systemImage: MemoryAtlasTab.sessions.systemImage) }
                .tag(MemoryAtlasTab.sessions)

            LibraryView()
                .tabItem { Label(MemoryAtlasTab.library.rawValue, systemImage: MemoryAtlasTab.library.systemImage) }
                .tag(MemoryAtlasTab.library)

            MoreView()
                .tabItem { Label(MemoryAtlasTab.more.rawValue, systemImage: MemoryAtlasTab.more.systemImage) }
                .tag(MemoryAtlasTab.more)
        }
        .tint(MemoryAtlasTheme.sage)
        .preferredColorScheme(.light)
        .task {
            MemoryAtlasStore.seedIfNeeded(context: modelContext, caregivers: caregivers)
        }
        .fullScreenCover(isPresented: $showingSessionPlayer) {
            if let activeSession, let profile = profiles.first(where: { $0.id == activeSession.profileID }) ?? profiles.first {
                SessionPlayerView(session: activeSession, profile: profile)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            CaregiverAccount.self,
            PersonProfile.self,
            MemoryArtifact.self,
            GuidedSession.self,
            GuidedSessionStep.self,
            SessionRun.self,
            CaregiverNote.self,
        ], inMemory: true)
}
