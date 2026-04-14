import SwiftUI
import UIKit

struct ReaderView: View {
    @ObservedObject var connectivity: PhoneConnectivity
    @Binding var bookText: String

    @State private var scrollTick: CGFloat = 0
    @State private var fontSize: Double = 20

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Crown Reader")
                    .font(.headline)
                Spacer()
                Stepper("Size \(Int(fontSize))", value: $fontSize, in: 14 ... 32, step: 1)
                    .labelsHidden()
                Text("\(Int(fontSize)) pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            CrownScrollView(
                text: bookText,
                font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                externalScrollDelta: $scrollTick
            )
        }
        .onChange(of: connectivity.scrollPulse) { _, _ in
            let pending = connectivity.consumePendingScroll()
            guard pending != 0 else { return }
            scrollTick = pending
        }
        .onAppear { connectivity.activate() }
    }
}
