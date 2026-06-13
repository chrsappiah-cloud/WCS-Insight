import SwiftUI
import WCSCore

@main
struct MemoryAtlasApp: App {
    @StateObject private var container = MemoryAtlasContainer.preview

    var body: some Scene {
        WindowGroup {
            MemoryAtlasRootView()
                .environmentObject(container)
        }
    }
}

@MainActor
final class MemoryAtlasContainer: ObservableObject {
    let profileRepository: PersonProfileRepository
    let artifactRepository: MemoryArtifactRepository
    let sessionRepository: GuidedSessionRepository

    init(profileRepository: PersonProfileRepository, artifactRepository: MemoryArtifactRepository, sessionRepository: GuidedSessionRepository) {
        self.profileRepository = profileRepository
        self.artifactRepository = artifactRepository
        self.sessionRepository = sessionRepository
    }

    static let preview = MemoryAtlasContainer(
        profileRepository: PreviewPersonProfileRepository(),
        artifactRepository: PreviewMemoryArtifactRepository(),
        sessionRepository: PreviewGuidedSessionRepository()
    )
}
