import Foundation
import UserNotifications

/// 通知代理 - 让 App 在前台时也能显示通知弹窗和播放声音
/// iOS 默认前台不显示通知，必须通过此代理明确允许
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    /// 前台收到通知时：显示横幅 + 播放声音
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// 用户点击通知上的操作按钮时
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 后续可以在这里处理 "继续" / "停止" 按钮
        completionHandler()
    }
}
