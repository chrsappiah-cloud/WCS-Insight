import Foundation

public struct ProfileDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let full_name: String
    public let preferred_name: String?
    public let birth_year: Int?
    public let diagnosis_notes: String?
    public let primary_language: String?
}

public struct CreateProfileRequest: Codable, Sendable {
    public let full_name: String
    public let preferred_name: String?
    public let birth_year: Int?
    public let diagnosis_notes: String?
    public let primary_language: String?

    public init(fullName: String, preferredName: String? = nil, birthYear: Int? = nil, diagnosisNotes: String? = nil, primaryLanguage: String? = nil) {
        self.full_name = fullName
        self.preferred_name = preferredName
        self.birth_year = birthYear
        self.diagnosis_notes = diagnosisNotes
        self.primary_language = primaryLanguage
    }
}

public struct MemoryArtifactDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let profile_id: UUID
    public let title: String
    public let kind: String
    public let description: String?
    public let source_url: String?
    public let thumbnail_url: String?
    public let captured_at: Date?
    public let tags: [String]
}

public struct CreateMemoryArtifactRequest: Codable, Sendable {
    public let title: String
    public let kind: String
    public let description: String?
    public let source_url: String?
    public let thumbnail_url: String?
    public let captured_at: Date?
    public let tags: [String]
}

public struct GuidedSessionStepDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let artifact_id: UUID?
    public let prompt_text: String
    public let order_index: Int
    public let duration_seconds: Int?
}

public struct GuidedSessionDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let profile_id: UUID
    public let title: String
    public let goal: String?
    public let estimated_duration_minutes: Int?
    public let steps: [GuidedSessionStepDTO]?
}

public struct CreateGuidedSessionRequest: Codable, Sendable {
    public let title: String
    public let goal: String?
    public let estimated_duration_minutes: Int?
}

public struct UpdateSessionStepsRequest: Codable, Sendable {
    public struct Step: Codable, Sendable {
        public let artifact_id: UUID?
        public let prompt_text: String
        public let order_index: Int
        public let duration_seconds: Int?
    }
    public let steps: [Step]
}

public struct SessionRunDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let session_id: UUID
    public let profile_id: UUID
    public let started_at: Date
    public let ended_at: Date?
    public let mood_before: String?
    public let mood_after: String?
    public let notes: String?
}

public struct CreateSessionRunRequest: Codable, Sendable {
    public let profile_id: UUID
    public let started_at: Date
    public let mood_before: String?
}

public struct UpdateSessionRunRequest: Codable, Sendable {
    public let ended_at: Date?
    public let mood_after: String?
    public let notes: String?
}

public struct CreateSessionRunEventRequest: Codable, Sendable {
    public let step_id: UUID?
    public let event_type: String
    public let payload: [String: String]?
}

public struct ReminderDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let profile_id: UUID
    public let session_id: UUID?
    public let kind: String
    public let scheduled_at: Date?
    public let cron_expression: String?
    public let time_zone: String?
    public let is_active: Bool
}

public struct CreateReminderRequest: Codable, Sendable {
    public let session_id: UUID?
    public let kind: String
    public let scheduled_at: Date?
    public let cron_expression: String?
    public let time_zone: String
}
