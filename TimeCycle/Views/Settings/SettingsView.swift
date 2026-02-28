import SwiftUI

/// 设置视图 - App 全局设置
struct SettingsView: View {

    /// 是否启用通知提醒
    @AppStorage("enableNotifications") private var enableNotifications = true
    /// 是否启用震动反馈
    @AppStorage("enableHaptics") private var enableHaptics = true
    /// 是否保持屏幕常亮（计时时）
    @AppStorage("keepScreenOn") private var keepScreenOn = true

    var body: some View {
        NavigationStack {
            Form {
                notificationSection
                hapticSection
                displaySection
                aboutSection
            }
            .navigationTitle("设置")
        }
    }

    /// 通知设置
    private var notificationSection: some View {
        Section("通知") {
            Toggle("段切换提醒", isOn: $enableNotifications)
            if enableNotifications {
                Button("测试通知") {
                    let svc = NotificationService()
                    svc.scheduleNotification(
                        title: "TimeCycle 测试",
                        body: "通知功能正常工作！",
                        delay: 1
                    )
                    // 同时测试震动
                    if enableHaptics {
                        HapticService().segmentComplete()
                    }
                }
            }
        }
    }

    /// 震动设置
    private var hapticSection: some View {
        Section("震动") {
            Toggle("震动反馈", isOn: $enableHaptics)
        }
    }

    /// 显示设置
    private var displaySection: some View {
        Section("显示") {
            Toggle("计时时保持屏幕常亮", isOn: $keepScreenOn)
        }
    }

    /// 关于
    private var aboutSection: some View {
        Section("关于") {
            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            HStack {
                Text("应用名称")
                Spacer()
                Text("TimeCycle").foregroundStyle(.secondary)
            }
        }
    }
}