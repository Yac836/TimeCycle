import SwiftUI

/// TimeCycle watchOS App 入口
@main
struct TimeCycleWatchApp: App {

    /// 从 iPhone 同步过来的循环配置
    @State private var syncedCycles: [SyncPayload.Cycle] = []

    var body: some Scene {
        WindowGroup {
            WatchCycleListView(cycles: $syncedCycles)
                .onAppear {
                    WatchConnectivityService.shared.activate()
                    observeSyncedCycles()
                }
        }
    }

    /// 监听从 iPhone 同步过来的循环数据
    private func observeSyncedCycles() {
        NotificationCenter.default.addObserver(
            forName: .cyclesReceived,
            object: nil,
            queue: .main
        ) { notification in
            if let cycles = notification.userInfo?["cycles"] as? [SyncPayload.Cycle] {
                syncedCycles = cycles
            }
        }
    }
}
