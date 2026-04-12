import Foundation
import WatchConnectivity

final class WatchConnectivitySession: NSObject, ObservableObject {
    static let shared = WatchConnectivitySession()

    @Published private(set) var isPhoneReachable = false

    private var lastCrownValue: Double = 0
    private var lastSendTime: TimeInterval = 0
    private let minInterval: TimeInterval = 1 / 45

    /// Scale crown radians/degrees into scroll points on the phone.
    private let scrollScale: CGFloat = 12

    override private init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func handleCrownValue(_ value: Double) {
        let delta = value - lastCrownValue
        lastCrownValue = value
        guard abs(delta) > 0.000_1 else { return }

        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastSendTime >= minInterval else { return }
        lastSendTime = now

        let points = -CGFloat(delta) * scrollScale
        sendScrollDelta(points)
    }

    private func sendScrollDelta(_ points: CGFloat) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        let message: [String: Any] = [CrownMessages.deltaKey: points]
        session.sendMessage(message, replyHandler: nil) { _ in }
    }
}

extension WatchConnectivitySession: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }
}
