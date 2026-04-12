import Foundation
import WatchConnectivity

final class WatchConnectivitySession: NSObject, ObservableObject {
    static let shared = WatchConnectivitySession()

    @Published private(set) var isPhoneReachable = false

    private var lastCrownValue: Double = 0
    private var lastSendTime: TimeInterval = 0
    private let minInterval: TimeInterval = 1 / 45

    private var accumulatedPoints: CGFloat = 0
    private var flushWorkItem: DispatchWorkItem?

    /// Scale crown rotation into scroll points on the phone.
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

        let points = -CGFloat(delta) * scrollScale
        accumulatedPoints += points
        kickTransport()
    }

    /// Sends accumulated scroll delta when rate-limit and reachability allow; reschedules if data remains.
    private func kickTransport() {
        flushWorkItem?.cancel()
        flushWorkItem = nil

        guard accumulatedPoints != 0 else { return }

        let session = WCSession.default
        let now = ProcessInfo.processInfo.systemUptime

        if now - lastSendTime < minInterval {
            scheduleKick(delay: lastSendTime + minInterval - now)
            return
        }

        guard session.activationState == .activated, session.isReachable else {
            scheduleKick(delay: 0.5)
            return
        }

        let batch = accumulatedPoints
        accumulatedPoints = 0
        lastSendTime = now
        let message: [String: Any] = [CrownMessages.deltaKey: batch]
        session.sendMessage(message, replyHandler: nil) { [weak self] _ in
            DispatchQueue.main.async {
                self?.accumulatedPoints += batch
                self?.kickTransport()
            }
        }
    }

    private func scheduleKick(delay: TimeInterval) {
        flushWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.flushWorkItem = nil
            self?.kickTransport()
        }
        flushWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + max(delay, 0.01), execute: work)
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
            self.kickTransport()
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
            self.kickTransport()
        }
    }
}
