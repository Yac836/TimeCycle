import SwiftUI

/// 主视图 - 底部 Tab 导航
/// 包含三个页面：循环列表、历史统计、设置
struct ContentView: View {
    var body: some View {
        TabView {
            CycleListView()
                .tabItem {
                    Label("循环", systemImage: "timer")
                }

            HistoryView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}
