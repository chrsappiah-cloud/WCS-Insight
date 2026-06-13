import Foundation

public struct PersonProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var fullName: String
    public var preferredName: String?
    public var birthYear: Int?
    public var diagnosisNotes: String?
    public var primaryLanguage: String?
    public var preferredTopics: [String]

    public init(
        id: UUID = UUID(),
        fullName: String,
        preferredName: String? = nil,
        birthYear: Int? = nil,
        diagnosisNotes: String? = nil,
        primaryLanguage: String? = nil,
        preferredTopics: [String] = []
    ) {
        self.id = id
        self.fullName = fullName
        self.preferredName = preferredName
        self.birthYear = birthYear
        self.diagnosisNotes = diagnosisNotes
        self.primaryLanguage = primaryLanguage
        self.preferredTopics = preferredTopics
    }
}

public struct MemoryArtifact: Identifiable, Codable, Hashable, Sendable {
    public enum Kind: String, Codable, CaseIterable, Sendable {
        case photo, audio, video, story
    }

    public let id: UUID
    public var profileID: UUID
    public var title: String
    public var kind: Kind
    public var notes: String
    public var sourceURL: URL?
    public var thumbnailURL: URL?
    public var capturedAt: Date?
    public var tags: [String]

    public init(
        id: UUID = UUID(),
        profileID: UUID,
        title: String,
        kind: Kind,
        notes: String = "",
        sourceURL: URL? = nil,
        thumbnailURL: URL? = nil,
        capturedAt: Date? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.profileID = profileID
        self.title = title
        self.kind = kind
        self.notes = notes
        self.sourceURL = sourceURL
        self.thumbnailURL = thumbnailURL
        self.capturedAt = capturedAt
        self.tags = tags
    }
}

public struct GuidedSession: Identifiable, Codable, Hashable, Sendable {
    public struct Step: Identifiable, Codable, Hashable, Sendable {
        public let id: UUID
        public var artifactID: UUID?
        public var promptText: String
        public var orderIndex: Int
        public var durationSeconds: Int?

        public init(id: UUID = UUID(), artifactID: UUID? = nil, promptText: String, orderIndex: Int, durationSeconds: Int? = nil) {
            self.id = id
            self.artifactID = artifactID
            self.promptText = promptText
            self.orderIndex = orderIndex
            self.durationSeconds = durationSeconds
        }
    }

    public let id: UUID
    public var profileID: UUID
    public var title: String
    public var goal: String?
    public var estimatedDurationMinutes: Int?
    public var steps: [Step]

    public init(id: UUID = UUID(), profileID: UUID, title: String, goal: String? = nil, estimatedDurationMinutes: Int? = nil, steps: [Step] = []) {
        self.id = id
        self.profileID = profileID
        self.title = title
        self.goal = goal
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.steps = steps
    }
}

public struct SessionRun: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var sessionID: UUID
    public var profileID: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var moodBefore: String?
    public var moodAfter: String?
    public var notes: String?

    public init(id: UUID = UUID(), sessionID: UUID, profileID: UUID, startedAt: Date = Date(), endedAt: Date? = nil, moodBefore: String? = nil, moodAfter: String? = nil, notes: String? = nil) {
        self.id = id
        self.sessionID = sessionID
        self.profileID = profileID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
        self.notes = notes
    }
}

public struct Reminder: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var profileID: UUID
    public var sessionID: UUID?
    public var kind: String
    public var scheduledAt: Date?
    public var cronExpression: String?
    public var timeZone: String
    public var isActive: Bool
}
