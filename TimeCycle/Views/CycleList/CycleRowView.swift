import SwiftUI

/// 循环列表中的单行视图
struct CycleRowView: View {

    let cycle: TimeCycle

    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: cycle.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: cycle.colorHex))
                .frame(width: 40, height: 40)
                .background(
                    Color(hex: cycle.colorHex).opacity(0.15)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // 名称和摘要
            VStack(alignment: .leading, spacing: 4) {
                Text(cycle.name)
                    .font(.headline)

                HStack(spacing: 4) {
                    // 段数量
                    Text("\(cycle.segments.count)段")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.secondary)

                    // 总时长
                    Text(formatDuration(cycle.totalDuration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 自动/手动标识
            VStack(spacing: 2) {
                if cycle.autoNextSegment {
                    Label("自动", systemImage: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
                if cycle.autoNextCycle {
                    Label("循环", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// 格式化时长
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }
}