import SwiftUI
import SwiftData
import UserNotifications

/// TimeCycle iOS App 入口
@main
struct TimeCycleApp: App {

    /// 通知代理（必须强引用保持存活，否则前台通知不显示）
    @State private var notificationDelegate = NotificationDelegate()

    /// SwiftData 模型容器（管理所有持久化数据）
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                TimeCycle.self,
                TimeSegment.self,
                CycleSession.self,
                SegmentRecord.self,
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 设置通知代理，让前台也能显示通知
                    UNUserNotificationCenter.current().delegate = notificationDelegate
                    // 注册通知分类并请求权限
                    let notificationService = NotificationService()
                    notificationService.registerCategories()
                    Task {
                        _ = await notificationService.requestPermission()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
