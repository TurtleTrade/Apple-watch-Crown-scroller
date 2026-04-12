import Combine
import Foundation
import WatchConnectivity

final class PhoneConnectivity: NSObject, ObservableObject {
    static let shared = PhoneConnectivity()

    /// Accumulated scroll delta from the Watch (points). Consumed by the reader when `scrollPulse` changes.
    @Published private(set) var pendingScrollPoints: CGFloat = 0

    /// Increments on each incoming scroll message so views can react without a timer.
    @Published private(set) var scrollPulse: UInt = 0

    override private init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func consumePendingScroll() -> CGFloat {
        let v = pendingScrollPoints
        pendingScrollPoints = 0
        return v
    }

}

extension PhoneConnectivity: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let raw = message[CrownMessages.deltaKey] as? NSNumber else { return }
        let delta = CGFloat(truncating: raw)
        DispatchQueue.main.async {
            self.pendingScrollPoints += delta
            self.scrollPulse &+= 1
        }
    }
}
