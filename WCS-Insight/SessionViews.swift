import SwiftData
import SwiftUI

struct SessionsListView: View {
    @Query(sort: \GuidedSession.updatedAt, order: .reverse) private var sessions: [GuidedSession]
    @Query private var profiles: [PersonProfile]

    @Binding var activeSession: GuidedSession?
    @Binding var showingSessionPlayer: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(sessions, id: \.id) { session in
                        sessionCard(session)
                    }
                }
                .padding(20)
            }
            .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Sessions")
        }
    }

    private func sessionCard(_ session: GuidedSession) -> some View {
        MemoryAtlasCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(session.title)
                        .font(MemoryAtlasFont.display(22))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                    Spacer()
                    if session.isPinned {
                        Text("Today")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MemoryAtlasTheme.sageDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(MemoryAtlasTheme.sageLight, in: Capsule())
                    }
                }

                Text(session.sessionDescription)
                    .font(.caption)
                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)

                HStack {
                    Label("\(session.estimatedDurationMinutes) min", systemImage: "clock")
                    Label(session.participantMode, systemImage: "person.2")
                    if let profile = profiles.first(where: { $0.id == session.profileID }) {
                        Label(profile.preferredName, systemImage: "person.crop.circle")
                    }
                }
                .font(.caption)
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)

                MemoryAtlasPrimaryButton("Start Session", systemImage: "play.fill") {
                    activeSession = session
                    showingSessionPlayer = true
                }
            }
        }
    }
}

struct SessionPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var steps: [GuidedSessionStep]

    let session: GuidedSession
    let profile: PersonProfile

    @State private var currentStepIndex = 1
    @State private var selectedMood: MoodLevel = .veryCalm
    @State private var isPaused = false

    private var sessionSteps: [GuidedSessionStep] {
        steps
            .filter { $0.sessionID == session.id }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    private var currentStep: GuidedSessionStep? {
        guard sessionSteps.indices.contains(currentStepIndex) else { return sessionSteps.last }
        return sessionSteps[currentStepIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader
                ScrollView {
                    VStack(spacing: 24) {
                        promptCard
                        playbackControls
                        moodPicker
                    }
                    .padding(20)
                }
            }
            .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
            .navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .accessibilityLabel("Close")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(currentStepIndex + 1) of \(max(sessionSteps.count, 1))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)
            ProgressView(value: Double(currentStepIndex + 1), total: Double(max(sessionSteps.count, 1)))
                .tint(MemoryAtlasTheme.sage)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var promptCard: some View {
        MemoryAtlasCard {
            VStack(spacing: 18) {
                Image(systemName: "leaf.fill")
                    .font(.title3)
                    .foregroundStyle(MemoryAtlasTheme.gold)

                if let currentStep {
                    Text(currentStep.promptText)
                        .font(MemoryAtlasFont.display(24))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                        .multilineTextAlignment(.center)

                    if !currentStep.followUpPrompt.isEmpty {
                        Text(currentStep.followUpPrompt)
                            .font(.system(.title3, design: .serif).italic())
                            .foregroundStyle(MemoryAtlasTheme.sageDark)
                            .multilineTextAlignment(.center)
                    }
                }

                Text("You can share as much or as little as you like.")
                    .font(.caption)
                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 28) {
            controlButton(title: "Back", systemImage: "backward.fill") {
                currentStepIndex = max(currentStepIndex - 1, 0)
            }

            Button {
                isPaused.toggle()
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(MemoryAtlasTheme.sage, in: Circle())
                    Text(isPaused ? "Play" : "Pause")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                }
            }
            .buttonStyle(.plain)

            controlButton(title: "Next", systemImage: "forward.fill") {
                advanceStep()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func controlButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(MemoryAtlasTheme.ink)
                    .frame(width: 52, height: 52)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().stroke(MemoryAtlasTheme.hairline))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MemoryAtlasTheme.ink)
            }
        }
        .buttonStyle(.plain)
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How is \(profile.preferredName) feeling?")
                .font(MemoryAtlasFont.display(20))
                .foregroundStyle(MemoryAtlasTheme.ink)

            HStack(spacing: 10) {
                ForEach(MoodLevel.allCases) { mood in
                    Button {
                        selectedMood = mood
                        saveMood(mood)
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.title2)
                                .frame(width: 52, height: 52)
                                .background(
                                    selectedMood == mood ? MemoryAtlasTheme.sageLight : Color.white,
                                    in: Circle()
                                )
                                .overlay(
                                    Circle().stroke(selectedMood == mood ? MemoryAtlasTheme.sage : MemoryAtlasTheme.hairline, lineWidth: 1)
                                )
                            Text(mood.rawValue)
                                .font(.caption2)
                                .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                                .multilineTextAlignment(.center)
                                .frame(width: 64)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func advanceStep() {
        if currentStepIndex < sessionSteps.count - 1 {
            currentStepIndex += 1
        } else {
            saveMood(selectedMood)
            dismiss()
        }
    }

    private func saveMood(_ mood: MoodLevel) {
        let run = SessionRun(
            sessionID: session.id,
            profileID: profile.id,
            currentStepIndex: currentStepIndex,
            moodAfter: mood.rawValue
        )
        modelContext.insert(run)
        try? modelContext.save()
    }
}
