import SwiftUI

/// watchOS 循环列表 - 展示从 iPhone 同步过来的循环配置
struct WatchCycleListView: View {

    /// 从 iPhone 同步的循环列表（通过 WatchConnectivity 接收）
    @Binding var cycles: [SyncPayload.Cycle]
    /// 选中的循环（用于导航到计时器）
    @State private var selectedCycle: SyncPayload.Cycle?

    var body: some View {
        NavigationStack {
            if cycles.isEmpty {
                emptyState
            } else {
                cycleList
            }
        }
    }

    /// 空状态提示
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("请在 iPhone 上\n创建循环")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("TimeCycle")
    }

    /// 循环列表
    private var cycleList: some View {
        List(cycles, id: \.id) { cycle in
            NavigationLink {
                WatchActiveTimerView(cycle: cycle)
            } label: {
                HStack {
                    Image(systemName: cycle.icon)
                        .foregroundStyle(Color(hex: cycle.colorHex))
                    VStack(alignment: .leading) {
                        Text(cycle.name).font(.headline)
                        Text("\(cycle.segments.count) 段")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("循环")
    }
}