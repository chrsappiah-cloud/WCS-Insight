import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var caregivers: [CaregiverAccount]
    @Query(filter: #Predicate<PersonProfile> { $0.isActive }, sort: \PersonProfile.fullName) private var profiles: [PersonProfile]
    @Query(sort: \GuidedSession.updatedAt, order: .reverse) private var sessions: [GuidedSession]
    @Query private var artifacts: [MemoryArtifact]
    @Query(sort: \SessionRun.startedAt, order: .reverse) private var runs: [SessionRun]

    @Binding var activeSession: GuidedSession?
    @Binding var showingSessionPlayer: Bool

    private var caregiver: CaregiverAccount? { caregivers.first }
    private var activeProfile: PersonProfile? { profiles.first }
    private var todaysSession: GuidedSession? {
        sessions.first { $0.isPinned } ?? sessions.first
    }

    private var sessionsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return runs.filter { $0.startedAt >= weekAgo }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                greeting
                if let todaysSession, let activeProfile {
                    todaysSessionCard(session: todaysSession, profile: activeProfile)
                }
                atAGlance
                quoteBanner
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(MemoryAtlasTheme.pageBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                MemoryAtlasLogoMark()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Memory Atlas")
                        .font(MemoryAtlasFont.display(22))
                        .foregroundStyle(MemoryAtlasTheme.ink)
                    Text("WCS Dementia-Care Reminiscence")
                        .font(.caption)
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                }
            }
            Spacer()
            if let caregiver {
                CaregiverAvatar(initials: caregiver.initials)
            }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good morning, \(caregiver?.displayName ?? "Carer")")
                .font(MemoryAtlasFont.display(28))
                .foregroundStyle(MemoryAtlasTheme.ink)
            Text("Ready for a gentle reminiscence session?")
                .font(MemoryAtlasFont.body(15))
                .foregroundStyle(MemoryAtlasTheme.secondaryInk)
        }
    }

    private func todaysSessionCard(session: GuidedSession, profile: PersonProfile) -> some View {
        MemoryAtlasCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("TODAY'S SESSION")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(MemoryAtlasTheme.sageDark)

                HStack(alignment: .top, spacing: 14) {
                    sessionArtwork
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.title)
                            .font(MemoryAtlasFont.display(24))
                            .foregroundStyle(MemoryAtlasTheme.ink)
                        Text(session.sessionDescription)
                            .font(MemoryAtlasFont.body(14))
                            .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 14) {
                            Label("\(session.estimatedDurationMinutes) min", systemImage: "clock")
                            Label(session.participantMode, systemImage: "person.2")
                        }
                        .font(.caption)
                        .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    }
                }

                MemoryAtlasPrimaryButton("Start Session", systemImage: "chevron.right") {
                    activeSession = session
                    showingSessionPlayer = true
                }
            }
        }
    }

    private var sessionArtwork: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.35), MemoryAtlasTheme.sage.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
            Image(systemName: "sun.horizon.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }

    private var atAGlance: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("At a Glance")
                .font(MemoryAtlasFont.display(20))
                .foregroundStyle(MemoryAtlasTheme.ink)

            HStack(spacing: 12) {
                glanceCard(
                    title: activeProfile?.preferredName ?? "Profile",
                    value: "Active Profile",
                    systemImage: "person.crop.circle"
                )
                glanceCard(
                    title: "\(artifacts.count)",
                    value: "Favourite Items",
                    systemImage: "heart"
                )
                glanceCard(
                    title: "\(sessionsThisWeek)",
                    value: "Sessions This Week",
                    systemImage: "calendar"
                )
            }
        }
    }

    private func glanceCard(title: String, value: String, systemImage: String) -> some View {
        MemoryAtlasCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(MemoryAtlasTheme.sage)
                Text(title)
                    .font(MemoryAtlasFont.display(18))
                    .foregroundStyle(MemoryAtlasTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(MemoryAtlasTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        }
    }

    private var quoteBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .foregroundStyle(MemoryAtlasTheme.sage)
            Text("Small moments. Lasting connections. Your care makes a world of difference.")
                .font(MemoryAtlasFont.body(14))
                .foregroundStyle(MemoryAtlasTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MemoryAtlasTheme.sageLight.opacity(0.65), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
