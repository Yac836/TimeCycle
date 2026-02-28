import Foundation
import WatchConnectivity

/// Watch 连接服务 - 管理 iOS 和 Apple Watch 之间的数据同步
/// 使用三种通信方式：
/// - transferUserInfo: 可靠传输循环配置（iOS → Watch）
/// - sendMessage: 实时传输计时器命令（双向）
/// - updateApplicationContext: 同步最新计时器状态
final class WatchConnectivityService: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivityService()
    private var session: WCSession?

    private override init() {
        super.init()
    }

    /// 激活 WatchConnectivity 会话
    func activate() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // MARK: - 发送数据

    /// 同步循环配置到 Watch（可靠传输，排队发送）
    func syncCycles(_ cycles: [TimeCycle]) {
        let payload = cycles.map { SyncPayload.Cycle(from: $0) }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        session?.transferUserInfo(["cycles": data])
    }

    /// 发送计时器控制命令（实时，双向）
    func sendTimerCommand(_ command: TimerCommand) {
        guard let data = try? JSONEncoder().encode(command) else { return }
        session?.sendMessage(["timerCommand": data], replyHandler: nil)
    }

    /// 同步计时器状态快照（最新状态覆盖模式）
    func sendTimerState(_ state: TimerStateSnapshot) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? session?.updateApplicationContext(["timerState": data])
    }

    // MARK: - 接收数据（WCSessionDelegate）

    /// 收到实时消息（计时器命令）
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        if let data = message["timerCommand"] as? Data,
           let command = try? JSONDecoder().decode(TimerCommand.self, from: data) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .timerCommandReceived,
                    object: nil,
                    userInfo: ["command": command]
                )
            }
        }
    }

    /// 收到可靠传输的数据（循环配置）
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        if let data = userInfo["cycles"] as? Data,
           let cycles = try? JSONDecoder().decode(
               [SyncPayload.Cycle].self, from: data
           ) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .cyclesReceived,
                    object: nil,
                    userInfo: ["cycles": cycles]
                )
            }
        }
    }

    // MARK: - 必需的代理方法

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // 激活完成回调，可在此处理错误
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // 重新激活（多 Watch 切换场景）
        session.activate()
    }
    #endif
}

// MARK: - 通知名称扩展

extension Notification.Name {
    /// 收到计时器控制命令
    static let timerCommandReceived = Notification.Name("timerCommandReceived")
    /// 收到循环配置同步
    static let cyclesReceived = Notification.Name("cyclesReceived")
}