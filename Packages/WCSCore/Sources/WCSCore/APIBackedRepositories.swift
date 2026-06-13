import Foundation

public final class APIBackedPersonProfileRepository: PersonProfileRepository, @unchecked Sendable {
    private let api: MemoryAtlasAPIClient

    public init(api: MemoryAtlasAPIClient) {
        self.api = api
    }

    public func fetchProfiles() async throws -> [PersonProfile] {
        try await api.listProfiles().map(PersonProfile.init(dto:))
    }

    public func getProfile(id: UUID) async throws -> PersonProfile {
        try await PersonProfile(dto: api.getProfile(id: id))
    }

    public func saveProfile(_ profile: PersonProfile) async throws -> PersonProfile {
        let dto = try await api.updateProfile(id: profile.id, profile.createRequest)
        return PersonProfile(dto: dto)
    }

    public func deleteProfile(id: UUID) async throws {
        try await api.deleteProfile(id: id)
    }
}

public final class APIBackedMemoryArtifactRepository: MemoryArtifactRepository, @unchecked Sendable {
    private let api: MemoryAtlasAPIClient

    public init(api: MemoryAtlasAPIClient) {
        self.api = api
    }

    public func fetchArtifacts(for profileID: UUID) async throws -> [MemoryArtifact] {
        try await api.listArtifacts(profileID: profileID, kind: nil, tag: nil).map(MemoryArtifact.init(dto:))
    }

    public func saveArtifact(_ artifact: MemoryArtifact, for profileID: UUID) async throws -> MemoryArtifact {
        let dto = try await api.updateArtifact(id: artifact.id, artifact.createRequest)
        return MemoryArtifact(dto: dto)
    }

    public func deleteArtifact(id: UUID) async throws {
        try await api.deleteArtifact(id: id)
    }
}

public final class APIBackedGuidedSessionRepository: GuidedSessionRepository, @unchecked Sendable {
    private let api: MemoryAtlasAPIClient

    public init(api: MemoryAtlasAPIClient) {
        self.api = api
    }

    public func fetchSessions(for profileID: UUID) async throws -> [GuidedSession] {
        try await api.listSessions(profileID: profileID).map(GuidedSession.init(dto:))
    }

    public func getSession(id: UUID) async throws -> GuidedSession {
        try await GuidedSession(dto: api.getSession(id: id))
    }

    public func saveSession(_ session: GuidedSession, for profileID: UUID) async throws -> GuidedSession {
        let dto = try await api.createSession(profileID: profileID, session.createRequest)
        let steps = UpdateSessionStepsRequest(steps: session.steps.map(\.updateRequestStep))
        let updated = try await api.updateSessionSteps(id: dto.id, steps)
        return GuidedSession(dto: updated)
    }

    public func updateSteps(sessionID: UUID, steps: [GuidedSession.Step]) async throws {
        _ = try await api.updateSessionSteps(id: sessionID, .init(steps: steps.map(\.updateRequestStep)))
    }
}

public final class APIBackedSessionRunRepository: SessionRunRepository, @unchecked Sendable {
    private let api: MemoryAtlasAPIClient

    public init(api: MemoryAtlasAPIClient) {
        self.api = api
    }

    public func startRun(sessionID: UUID, profileID: UUID, moodBefore: String?) async throws -> SessionRun {
        let dto = try await api.createSessionRun(sessionID: sessionID, .init(profile_id: profileID, started_at: Date(), mood_before: moodBefore))
        return SessionRun(dto: dto)
    }

    public func finishRun(runID: UUID, moodAfter: String?, notes: String?) async throws -> SessionRun {
        let dto = try await api.updateSessionRun(runID: runID, .init(ended_at: Date(), mood_after: moodAfter, notes: notes))
        return SessionRun(dto: dto)
    }

    public func listRuns(profileID: UUID) async throws -> [SessionRun] {
        try await api.listSessionRuns(profileID: profileID).map(SessionRun.init(dto:))
    }
}
