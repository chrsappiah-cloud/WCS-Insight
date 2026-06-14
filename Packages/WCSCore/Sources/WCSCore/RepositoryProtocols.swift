import Foundation

public protocol PersonProfileRepository: Sendable {
    func fetchProfiles() async throws -> [PersonProfile]
    func getProfile(id: UUID) async throws -> PersonProfile
    func saveProfile(_ profile: PersonProfile) async throws -> PersonProfile
    func deleteProfile(id: UUID) async throws
}

public protocol MemoryArtifactRepository: Sendable {
    func fetchArtifacts(for profileID: UUID) async throws -> [MemoryArtifact]
    func saveArtifact(_ artifact: MemoryArtifact, for profileID: UUID) async throws -> MemoryArtifact
    func deleteArtifact(id: UUID) async throws
}

public protocol GuidedSessionRepository: Sendable {
    func fetchSessions(for profileID: UUID) async throws -> [GuidedSession]
    func getSession(id: UUID) async throws -> GuidedSession
    func saveSession(_ session: GuidedSession, for profileID: UUID) async throws -> GuidedSession
    func updateSteps(sessionID: UUID, steps: [GuidedSession.Step]) async throws
}

public protocol SessionRunRepository: Sendable {
    func startRun(sessionID: UUID, profileID: UUID, moodBefore: String?) async throws -> SessionRun
    func finishRun(runID: UUID, moodAfter: String?, notes: String?) async throws -> SessionRun
    func listRuns(profileID: UUID) async throws -> [SessionRun]
}
