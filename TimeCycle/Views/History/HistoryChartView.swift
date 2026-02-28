import SwiftUI
import Charts

/// 历史统计图表 - 按段名展示时长分布
struct HistoryChartView: View {

    /// 数据：段名 → 总时长（秒）
    let data: [String: TimeInterval]

    var body: some View {
        if data.isEmpty {
            Text("暂无数据")
                .foregroundStyle(.secondary)
        } else {
            Chart {
                ForEach(sortedEntries, id: \.key) { entry in
                    BarMark(
                        x: .value("段", entry.key),
                        y: .value("分钟", entry.value / 60)
                    )
                    .foregroundStyle(by: .value("段", entry.key))
                }
            }
            .chartYAxisLabel("分钟")
            .frame(height: 180)
        }
    }

    /// 按时长降序排列
    private var sortedEntries: [(key: String, value: TimeInterval)] {
        data.sorted { $0.value > $1.value }
    }
}
