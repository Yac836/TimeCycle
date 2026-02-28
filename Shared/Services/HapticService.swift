import Foundation

#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

/// 震动反馈服务 - 跨平台处理 iOS 和 watchOS 的触觉反馈
/// iOS 使用 UIKit 的 FeedbackGenerator，watchOS 使用 WatchKit
final class HapticService {

    /// 段完成时的强提醒震动
    func segmentComplete() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.notification)
        #else
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// 轻微的点击反馈（按钮交互等）
    func lightTap() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #else
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
