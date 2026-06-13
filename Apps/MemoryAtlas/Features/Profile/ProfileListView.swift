import SwiftUI
import WCSCore

struct ProfileListView: View {
    @State private var profiles: [PersonProfile] = [
        .init(fullName: "Margaret Thompson", preferredName: "Maggie", birthYear: 1942, primaryLanguage: "en", preferredTopics: ["family", "music", "home"])
    ]

    var body: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Memory profiles")
                    .font(.title3.bold())
                ForEach(profiles) { profile in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.preferredName ?? profile.fullName)
                            .font(.headline)
                        Text("Born \(profile.birthYear.map(String.init) ?? "—") · \(profile.preferredTopics.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
