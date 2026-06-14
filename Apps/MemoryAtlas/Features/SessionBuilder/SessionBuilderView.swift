import SwiftUI
import WCSCore

struct SessionBuilderView: View {
    private let steps = [
        "Look at the wedding photo together.",
        "Ask: who was with you that day?",
        "Play the favourite hymn softly.",
        "End with a calm check-in."
    ]

    var body: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Guided session builder")
                    .font(.title3.bold())
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .frame(width: 26, height: 26)
                            .background(WCSColor.softGold.opacity(0.2), in: Circle())
                        Text(step)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}
