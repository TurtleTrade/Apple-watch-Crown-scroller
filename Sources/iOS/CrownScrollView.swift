import SwiftUI
import UIKit

/// Vertical `UIScrollView` so crown deltas map cleanly to `contentOffset` without fighting SwiftUI's scroll APIs.
struct CrownScrollView: UIViewRepresentable {
    var text: String
    var font: UIFont
    @Binding var externalScrollDelta: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = true
        scroll.backgroundColor = .systemBackground

        let label = UILabel()
        label.numberOfLines = 0
        label.font = font
        label.textColor = .label
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false

        scroll.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -32),
            label.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40),
        ])

        context.coordinator.label = label
        context.coordinator.scrollView = scroll
        return scroll
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        if context.coordinator.label.text != text {
            context.coordinator.label.text = text
        }
        if context.coordinator.label.font != font {
            context.coordinator.label.font = font
        }

        let delta = externalScrollDelta
        guard delta != 0, let sv = context.coordinator.scrollView else { return }

        var y = sv.contentOffset.y - delta
        let maxY = max(0, sv.contentSize.height - sv.bounds.height + sv.adjustedContentInset.bottom)
        y = min(maxY, max(-sv.adjustedContentInset.top, y))
        sv.setContentOffset(CGPoint(x: 0, y: y), animated: false)
        let deltaBinding = $externalScrollDelta
        DispatchQueue.main.async {
            deltaBinding.wrappedValue = 0
        }
    }

    final class Coordinator {
        var scrollView: UIScrollView?
        var label: UILabel!
    }
}
