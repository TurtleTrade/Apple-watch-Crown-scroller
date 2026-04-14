import SwiftUI

struct WatchContentView: View {
    @StateObject private var session = WatchConnectivitySession.shared
    @State private var crownRotation: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("Crown Reader")
                .font(.headline)
            Text(session.isPhoneReachable
                ? "Turn the crown to scroll on iPhone"
                : "Open Crown Reader on iPhone and keep it in view")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundColor(session.isPhoneReachable ? .secondary : .orange)
            Spacer(minLength: 0)
        }
        .padding()
        .focusable()
        .digitalCrownRotation(
            $crownRotation,
            from: -1_000_000,
            through: 1_000_000,
            by: 0.1,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            session.activate()
        }
        .onChange(of: crownRotation) { newValue in
            session.handleCrownValue(newValue)
        }
    }
}
