import Foundation

extension PersonProfile {
    public init(dto: ProfileDTO) {
        self.init(
            id: dto.id,
            fullName: dto.full_name,
            preferredName: dto.preferred_name,
            birthYear: dto.birth_year,
            diagnosisNotes: dto.diagnosis_notes,
            primaryLanguage: dto.primary_language,
            preferredTopics: []
        )
    }

    public var createRequest: CreateProfileRequest {
        CreateProfileRequest(
            fullName: fullName,
            preferredName: preferredName,
            birthYear: birthYear,
            diagnosisNotes: diagnosisNotes,
            primaryLanguage: primaryLanguage
        )
    }
}

extension MemoryArtifact {
    public init(dto: MemoryArtifactDTO) {
        self.init(
            id: dto.id,
            profileID: dto.profile_id,
            title: dto.title,
            kind: Kind(rawValue: dto.kind) ?? .photo,
            notes: dto.description ?? "",
            sourceURL: dto.source_url.flatMap(URL.init(string:)),
            thumbnailURL: dto.thumbnail_url.flatMap(URL.init(string:)),
            capturedAt: dto.captured_at,
            tags: dto.tags
        )
    }

    public var createRequest: CreateMemoryArtifactRequest {
        CreateMemoryArtifactRequest(
            title: title,
            kind: kind.rawValue,
            description: notes,
            source_url: sourceURL?.absoluteString,
            thumbnail_url: thumbnailURL?.absoluteString,
            captured_at: capturedAt,
            tags: tags
        )
    }
}

extension GuidedSession.Step {
    public init(dto: GuidedSessionStepDTO) {
        self.init(id: dto.id, artifactID: dto.artifact_id, promptText: dto.prompt_text, orderIndex: dto.order_index, durationSeconds: dto.duration_seconds)
    }

    public var updateRequestStep: UpdateSessionStepsRequest.Step {
        .init(artifact_id: artifactID, prompt_text: promptText, order_index: orderIndex, duration_seconds: durationSeconds)
    }
}

extension GuidedSession {
    public init(dto: GuidedSessionDTO) {
        self.init(
            id: dto.id,
            profileID: dto.profile_id,
            title: dto.title,
            goal: dto.goal,
            estimatedDurationMinutes: dto.estimated_duration_minutes,
            steps: dto.steps?.map(GuidedSession.Step.init(dto:)) ?? []
        )
    }

    public var createRequest: CreateGuidedSessionRequest {
        .init(title: title, goal: goal, estimated_duration_minutes: estimatedDurationMinutes)
    }
}

extension SessionRun {
    public init(dto: SessionRunDTO) {
        self.init(id: dto.id, sessionID: dto.session_id, profileID: dto.profile_id, startedAt: dto.started_at, endedAt: dto.ended_at, moodBefore: dto.mood_before, moodAfter: dto.mood_after, notes: dto.notes)
    }
}
