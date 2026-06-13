import SwiftUI
import WCSCore

struct SessionPlayerView: View {
    @State private var progress: Double = 0.35

    var body: some View {
        VStack(spacing: 24) {
            Text("Evening Calm")
                .font(.largeTitle.bold())
            Text("Tell me about this day. Who was with you? What music do you remember?")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            ProgressView(value: progress)
                .tint(WCSColor.sage)
            Button("Mark step complete") {
                progress = min(progress + 0.2, 1)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Guided session")
    }
}
