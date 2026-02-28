import Foundation
import UserNotifications

/// 通知服务 - 管理本地通知的权限请求、调度和取消
/// 用于在 App 后台时提醒用户段切换和循环完成
final class NotificationService {

    // 通知分类 ID，用于区分不同类型的通知动作
    static let segmentCategoryId = "SEGMENT_TRANSITION"
    static let cycleCategoryId = "CYCLE_COMPLETE"

    // MARK: - 权限

    /// 请求通知权限，返回是否授权成功
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            return false
        }
    }

    /// 注册通知动作分类（继续 / 停止按钮）
    func registerCategories() {
        let continueAction = UNNotificationAction(
            identifier: "CONTINUE",
            title: "继续",
            options: .foreground
        )
        let stopAction = UNNotificationAction(
            identifier: "STOP",
            title: "停止",
            options: .destructive
        )

        let segmentCategory = UNNotificationCategory(
            identifier: Self.segmentCategoryId,
            actions: [continueAction, stopAction],
            intentIdentifiers: []
        )
        let cycleCategory = UNNotificationCategory(
            identifier: Self.cycleCategoryId,
            actions: [continueAction, stopAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current()
            .setNotificationCategories([segmentCategory, cycleCategory])
    }

    // MARK: - 调度通知

    /// 调度一条延迟触发的本地通知
    /// - Parameters:
    ///   - title: 通知标题
    ///   - body: 通知内容
    ///   - delay: 延迟秒数（至少 1 秒）
    ///   - identifier: 通知唯一标识（默认自动生成）
    func scheduleNotification(
        title: String,
        body: String,
        delay: TimeInterval,
        identifier: String? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = Self.segmentCategoryId

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, delay),
            repeats: false
        )
        let id = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 便捷方法

    /// 发送段完成通知，提示用户下一段信息
    func sendSegmentEndNotification(nextSegment: TimeSegment) {
        let minutes = Int(nextSegment.duration / 60)
        scheduleNotification(
            title: "时间到，该切换了！",
            body: "下一段：\(nextSegment.name)（\(minutes)分钟）",
            delay: 1
        )
    }

    /// 发送循环完成通知
    func sendCycleCompleteNotification(cycleName: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(cycleName) 完成"
        content.body = "干得漂亮！循环已结束。"
        content.sound = .default
        content.categoryIdentifier = Self.cycleCategoryId

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1, repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// 取消所有待触发的通知（回到前台时调用）
    func cancelPendingSegmentNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}