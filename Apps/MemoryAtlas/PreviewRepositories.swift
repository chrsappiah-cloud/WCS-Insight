import Foundation
import WCSCore

struct PreviewPersonProfileRepository: PersonProfileRepository {
    func fetchProfiles() async throws -> [PersonProfile] { [.init(fullName: "Margaret Thompson", preferredName: "Maggie", birthYear: 1942)] }
    func getProfile(id: UUID) async throws -> PersonProfile { .init(id: id, fullName: "Margaret Thompson") }
    func saveProfile(_ profile: PersonProfile) async throws -> PersonProfile { profile }
    func deleteProfile(id: UUID) async throws {}
}

struct PreviewMemoryArtifactRepository: MemoryArtifactRepository {
    func fetchArtifacts(for profileID: UUID) async throws -> [MemoryArtifact] { [] }
    func saveArtifact(_ artifact: MemoryArtifact, for profileID: UUID) async throws -> MemoryArtifact { artifact }
    func deleteArtifact(id: UUID) async throws {}
}

struct PreviewGuidedSessionRepository: GuidedSessionRepository {
    func fetchSessions(for profileID: UUID) async throws -> [GuidedSession] { [] }
    func getSession(id: UUID) async throws -> GuidedSession { .init(id: id, profileID: UUID(), title: "Evening Calm") }
    func saveSession(_ session: GuidedSession, for profileID: UUID) async throws -> GuidedSession { session }
    func updateSteps(sessionID: UUID, steps: [GuidedSession.Step]) async throws {}
}
