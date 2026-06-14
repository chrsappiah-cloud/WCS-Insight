import Foundation
import SwiftData

enum MemoryArtifactKind: String, CaseIterable, Identifiable, Codable {
    case photo = "photo"
    case audio = "audio"
    case video = "video"
    case story = "story"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .photo: "photo"
        case .audio: "music.note"
        case .video: "video"
        case .story: "text.book.closed"
        }
    }
}

enum MoodLevel: String, CaseIterable, Identifiable, Codable {
    case veryCalm = "Very calm"
    case calm = "Calm"
    case okay = "Okay"
    case anxious = "Anxious"
    case upset = "Upset"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .veryCalm: "😌"
        case .calm: "🙂"
        case .okay: "😐"
        case .anxious: "😟"
        case .upset: "😢"
        }
    }
}

enum ProfileDetailTab: String, CaseIterable, Identifiable {
    case memories = "Memories"
    case about = "About"
    case preferences = "Preferences"

    var id: String { rawValue }
}

@Model
final class CaregiverAccount {
    var displayName: String
    var initials: String
    var role: String
    var createdAt: Date

    init(displayName: String, initials: String, role: String, createdAt: Date = .now) {
        self.displayName = displayName
        self.initials = initials
        self.role = role
        self.createdAt = createdAt
    }
}

@Model
final class PersonProfile {
    var id: UUID
    var fullName: String
    var preferredName: String
    var birthDate: Date
    var birthplace: String
    var personalQuote: String
    var diagnosisNotes: String
    var primaryLanguage: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        fullName: String,
        preferredName: String,
        birthDate: Date,
        birthplace: String,
        personalQuote: String,
        diagnosisNotes: String = "",
        primaryLanguage: String = "en",
        isActive: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.fullName = fullName
        self.preferredName = preferredName
        self.birthDate = birthDate
        self.birthplace = birthplace
        self.personalQuote = personalQuote
        self.diagnosisNotes = diagnosisNotes
        self.primaryLanguage = primaryLanguage
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class MemoryArtifact {
    var profileID: UUID
    var title: String
    var kind: String
    var artifactDescription: String
    var capturedAt: Date?
    var tags: [String]
    var durationSeconds: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        profileID: UUID,
        title: String,
        kind: String,
        artifactDescription: String,
        capturedAt: Date? = nil,
        tags: [String] = [],
        durationSeconds: Int? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.profileID = profileID
        self.title = title
        self.kind = kind
        self.artifactDescription = artifactDescription
        self.capturedAt = capturedAt
        self.tags = tags
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class GuidedSession {
    var id: UUID
    var profileID: UUID
    var title: String
    var goal: String
    var sessionDescription: String
    var estimatedDurationMinutes: Int
    var participantMode: String
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        profileID: UUID,
        title: String,
        goal: String,
        sessionDescription: String,
        estimatedDurationMinutes: Int,
        participantMode: String = "1:1 Session",
        isPinned: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.profileID = profileID
        self.title = title
        self.goal = goal
        self.sessionDescription = sessionDescription
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.participantMode = participantMode
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class GuidedSessionStep {
    var sessionID: UUID
    var promptText: String
    var followUpPrompt: String
    var orderIndex: Int
    var durationSeconds: Int?

    init(
        sessionID: UUID,
        promptText: String,
        followUpPrompt: String = "",
        orderIndex: Int,
        durationSeconds: Int? = nil
    ) {
        self.sessionID = sessionID
        self.promptText = promptText
        self.followUpPrompt = followUpPrompt
        self.orderIndex = orderIndex
        self.durationSeconds = durationSeconds
    }
}

@Model
final class SessionRun {
    var sessionID: UUID
    var profileID: UUID
    var startedAt: Date
    var endedAt: Date?
    var currentStepIndex: Int
    var moodBefore: String?
    var moodAfter: String?
    var notes: String

    init(
        sessionID: UUID,
        profileID: UUID,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        currentStepIndex: Int = 0,
        moodBefore: String? = nil,
        moodAfter: String? = nil,
        notes: String = ""
    ) {
        self.sessionID = sessionID
        self.profileID = profileID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.currentStepIndex = currentStepIndex
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
        self.notes = notes
    }
}

@Model
final class CaregiverNote {
    var profileID: UUID
    var body: String
    var createdAt: Date

    init(profileID: UUID, body: String, createdAt: Date = .now) {
        self.profileID = profileID
        self.body = body
        self.createdAt = createdAt
    }
}
