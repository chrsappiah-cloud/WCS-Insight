import Foundation

public protocol MemoryAtlasAPIClient: Sendable {
    func listProfiles() async throws -> [ProfileDTO]
    func createProfile(_ request: CreateProfileRequest) async throws -> ProfileDTO
    func getProfile(id: UUID) async throws -> ProfileDTO
    func updateProfile(id: UUID, _ request: CreateProfileRequest) async throws -> ProfileDTO
    func deleteProfile(id: UUID) async throws

    func listArtifacts(profileID: UUID, kind: String?, tag: String?) async throws -> [MemoryArtifactDTO]
    func createArtifact(profileID: UUID, _ request: CreateMemoryArtifactRequest) async throws -> MemoryArtifactDTO
    func getArtifact(id: UUID) async throws -> MemoryArtifactDTO
    func updateArtifact(id: UUID, _ request: CreateMemoryArtifactRequest) async throws -> MemoryArtifactDTO
    func deleteArtifact(id: UUID) async throws

    func listSessions(profileID: UUID) async throws -> [GuidedSessionDTO]
    func createSession(profileID: UUID, _ request: CreateGuidedSessionRequest) async throws -> GuidedSessionDTO
    func getSession(id: UUID) async throws -> GuidedSessionDTO
    func updateSessionSteps(id: UUID, _ request: UpdateSessionStepsRequest) async throws -> GuidedSessionDTO

    func createSessionRun(sessionID: UUID, _ request: CreateSessionRunRequest) async throws -> SessionRunDTO
    func updateSessionRun(runID: UUID, _ request: UpdateSessionRunRequest) async throws -> SessionRunDTO
    func listSessionRuns(profileID: UUID) async throws -> [SessionRunDTO]
    func createSessionRunEvent(runID: UUID, _ request: CreateSessionRunEventRequest) async throws -> EmptyResponse

    func listReminders(profileID: UUID) async throws -> [ReminderDTO]
    func createReminder(profileID: UUID, _ request: CreateReminderRequest) async throws -> ReminderDTO
}

public final class DefaultMemoryAtlasAPIClient: MemoryAtlasAPIClient, Sendable {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func listProfiles() async throws -> [ProfileDTO] {
        try await client.request("profiles", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func createProfile(_ request: CreateProfileRequest) async throws -> ProfileDTO {
        try await client.request("profiles", method: "POST", body: request)
    }

    public func getProfile(id: UUID) async throws -> ProfileDTO {
        try await client.request("profiles/\(id.uuidString)", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func updateProfile(id: UUID, _ request: CreateProfileRequest) async throws -> ProfileDTO {
        try await client.request("profiles/\(id.uuidString)", method: "PATCH", body: request)
    }

    public func deleteProfile(id: UUID) async throws {
        let _: EmptyResponse = try await client.request("profiles/\(id.uuidString)", method: "DELETE", body: Optional<EmptyRequest>.none)
    }

    public func listArtifacts(profileID: UUID, kind: String?, tag: String?) async throws -> [MemoryArtifactDTO] {
        var query: [URLQueryItem] = []
        if let kind { query.append(.init(name: "kind", value: kind)) }
        if let tag { query.append(.init(name: "tag", value: tag)) }
        return try await client.request("profiles/\(profileID.uuidString)/artifacts", method: "GET", queryItems: query, body: Optional<EmptyRequest>.none)
    }

    public func createArtifact(profileID: UUID, _ request: CreateMemoryArtifactRequest) async throws -> MemoryArtifactDTO {
        try await client.request("profiles/\(profileID.uuidString)/artifacts", method: "POST", body: request)
    }

    public func getArtifact(id: UUID) async throws -> MemoryArtifactDTO {
        try await client.request("artifacts/\(id.uuidString)", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func updateArtifact(id: UUID, _ request: CreateMemoryArtifactRequest) async throws -> MemoryArtifactDTO {
        try await client.request("artifacts/\(id.uuidString)", method: "PATCH", body: request)
    }

    public func deleteArtifact(id: UUID) async throws {
        let _: EmptyResponse = try await client.request("artifacts/\(id.uuidString)", method: "DELETE", body: Optional<EmptyRequest>.none)
    }

    public func listSessions(profileID: UUID) async throws -> [GuidedSessionDTO] {
        try await client.request("profiles/\(profileID.uuidString)/sessions", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func createSession(profileID: UUID, _ request: CreateGuidedSessionRequest) async throws -> GuidedSessionDTO {
        try await client.request("profiles/\(profileID.uuidString)/sessions", method: "POST", body: request)
    }

    public func getSession(id: UUID) async throws -> GuidedSessionDTO {
        try await client.request("sessions/\(id.uuidString)", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func updateSessionSteps(id: UUID, _ request: UpdateSessionStepsRequest) async throws -> GuidedSessionDTO {
        try await client.request("sessions/\(id.uuidString)/steps", method: "PUT", body: request)
    }

    public func createSessionRun(sessionID: UUID, _ request: CreateSessionRunRequest) async throws -> SessionRunDTO {
        try await client.request("sessions/\(sessionID.uuidString)/runs", method: "POST", body: request)
    }

    public func updateSessionRun(runID: UUID, _ request: UpdateSessionRunRequest) async throws -> SessionRunDTO {
        try await client.request("session-runs/\(runID.uuidString)", method: "PATCH", body: request)
    }

    public func listSessionRuns(profileID: UUID) async throws -> [SessionRunDTO] {
        try await client.request("profiles/\(profileID.uuidString)/session-runs", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func createSessionRunEvent(runID: UUID, _ request: CreateSessionRunEventRequest) async throws -> EmptyResponse {
        try await client.request("session-runs/\(runID.uuidString)/events", method: "POST", body: request)
    }

    public func listReminders(profileID: UUID) async throws -> [ReminderDTO] {
        try await client.request("profiles/\(profileID.uuidString)/reminders", method: "GET", body: Optional<EmptyRequest>.none)
    }

    public func createReminder(profileID: UUID, _ request: CreateReminderRequest) async throws -> ReminderDTO {
        try await client.request("profiles/\(profileID.uuidString)/reminders", method: "POST", body: request)
    }
}
