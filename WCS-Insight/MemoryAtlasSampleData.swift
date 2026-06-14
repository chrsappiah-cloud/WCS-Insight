import Foundation
import SwiftData

enum MemoryAtlasSampleData {
    static func insert(into context: ModelContext) {
        context.insert(
            CaregiverAccount(
                displayName: "Claire",
                initials: "CG",
                role: "Family caregiver"
            )
        )

        let maggieID = UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890") ?? UUID()
        let maggie = PersonProfile(
            id: maggieID,
            fullName: "Maggie",
            preferredName: "Maggie",
            birthDate: Calendar.current.date(from: DateComponents(year: 1936, month: 5, day: 12)) ?? .now,
            birthplace: "Belfast, Northern Ireland",
            personalQuote: "Faith, family and flowers have always been my joy.",
            diagnosisNotes: "Early-stage dementia. Responds well to music and familiar places."
        )
        context.insert(maggie)

        [
            MemoryArtifact(
                profileID: maggieID,
                title: "Wedding Day",
                kind: MemoryArtifactKind.photo.rawValue,
                artifactDescription: "St Anne's Cathedral, Belfast — 14 June 1958",
                capturedAt: Calendar.current.date(from: DateComponents(year: 1958, month: 6, day: 14)),
                tags: ["Family", "Marriage", "Joy"]
            ),
            MemoryArtifact(
                profileID: maggieID,
                title: "How Great Thou Art",
                kind: MemoryArtifactKind.audio.rawValue,
                artifactDescription: "Recorded at Sunday service, favourite hymn.",
                tags: ["Faith", "Hymns", "Peace"],
                durationSeconds: 168
            ),
            MemoryArtifact(
                profileID: maggieID,
                title: "Our Home Garden",
                kind: MemoryArtifactKind.story.rawValue,
                artifactDescription: "Roses along the back fence, tomatoes in the sun, and Maggie's chair by the kitchen window.",
                tags: ["Home", "Garden", "Nature"]
            ),
            MemoryArtifact(
                profileID: maggieID,
                title: "Harbour Walk",
                kind: MemoryArtifactKind.photo.rawValue,
                artifactDescription: "Weekly walk along Belfast Lough with Thomas.",
                capturedAt: Calendar.current.date(from: DateComponents(year: 1972, month: 8, day: 3)),
                tags: ["Place", "Routine", "Calm"]
            ),
            MemoryArtifact(
                profileID: maggieID,
                title: "Grandchildren's Visit",
                kind: MemoryArtifactKind.video.rawValue,
                artifactDescription: "Birthday tea in the garden with Emma and James.",
                tags: ["Family", "Joy"]
            ),
        ].forEach(context.insert)

        let eveningCalmID = UUID(uuidString: "B2C3D4E5-F6A7-8901-BCDE-F12345678901") ?? UUID()
        let eveningCalm = GuidedSession(
            id: eveningCalmID,
            profileID: maggieID,
            title: "Evening Calm",
            goal: "evening calm",
            sessionDescription: "A gentle wind-down with familiar places, music, and quiet reflection.",
            estimatedDurationMinutes: 15,
            participantMode: "1:1 Session",
            isPinned: true
        )
        context.insert(eveningCalm)

        [
            GuidedSessionStep(
                sessionID: eveningCalmID,
                promptText: "Let's begin with a deep breath together.",
                followUpPrompt: "How are you feeling right now?",
                orderIndex: 0
            ),
            GuidedSessionStep(
                sessionID: eveningCalmID,
                promptText: "Let's take a moment to think of somewhere that always felt like home.",
                followUpPrompt: "Where was it?",
                orderIndex: 1
            ),
            GuidedSessionStep(
                sessionID: eveningCalmID,
                promptText: "Can you remember a song that always brought comfort?",
                followUpPrompt: "Would you like to listen together?",
                orderIndex: 2
            ),
            GuidedSessionStep(
                sessionID: eveningCalmID,
                promptText: "Think of someone who made you feel safe and loved.",
                followUpPrompt: "Tell me about them.",
                orderIndex: 3
            ),
            GuidedSessionStep(
                sessionID: eveningCalmID,
                promptText: "Let's finish with one thing you feel grateful for today.",
                followUpPrompt: "You can share as much or as little as you like.",
                orderIndex: 4
            ),
        ].forEach(context.insert)

        context.insert(
            GuidedSession(
                profileID: maggieID,
                title: "Morning Connection",
                goal: "family connection",
                sessionDescription: "Start the day with familiar faces, routines, and gentle prompts.",
                estimatedDurationMinutes: 10,
                participantMode: "1:1 Session"
            )
        )

        context.insert(
            CaregiverNote(
                profileID: maggieID,
                body: "Maggie responded warmly to garden memories today. Consider adding more floral photos."
            )
        )

        let weekAgo = Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now
        context.insert(SessionRun(sessionID: eveningCalmID, profileID: maggieID, startedAt: weekAgo, endedAt: weekAgo.addingTimeInterval(900), currentStepIndex: 4, moodAfter: MoodLevel.calm.rawValue))
        context.insert(SessionRun(sessionID: eveningCalmID, profileID: maggieID, startedAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now, endedAt: nil, currentStepIndex: 2, moodAfter: MoodLevel.veryCalm.rawValue))
        context.insert(SessionRun(sessionID: eveningCalmID, profileID: maggieID, startedAt: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now, endedAt: nil, currentStepIndex: 1, moodAfter: MoodLevel.calm.rawValue))
    }
}

enum MemoryAtlasStore {
    static func seedIfNeeded(context: ModelContext, caregivers: [CaregiverAccount]) {
        guard caregivers.isEmpty else { return }
        MemoryAtlasSampleData.insert(into: context)
        try? context.save()
    }
}
