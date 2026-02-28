import SwiftUI
import SwiftData

/// TimeCycle iOS App 入口
@main
struct TimeCycleApp: App {

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
                    // 启动时请求通知权限并注册通知分类
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
