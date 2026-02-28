import Foundation
import SwiftData

/// 时间段模型 - 循环中的一个阶段（如"坐"、"站"、"走动"）
/// 每个时间段有自己的名称、时长、颜色和图标
@Model
final class TimeSegment {
    var id: UUID
    /// 时间段名称，如 "坐"、"站立"、"走动"
    var name: String
    /// 时长（秒），例如 2700 = 45分钟
    var duration: TimeInterval
    /// 颜色（十六进制），用于 UI 展示
    var colorHex: String
    /// SF Symbol 图标名称
    var icon: String
    /// 排序顺序，决定在循环中的执行顺序
    var sortOrder: Int
    /// 所属的循环（反向关系，SwiftData 自动维护）
    var cycle: TimeCycle?

    init(
        name: String,
        duration: TimeInterval,
        colorHex: String = "#34C759",
        icon: String = "chair.fill",
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.colorHex = colorHex
        self.icon = icon
        self.sortOrder = sortOrder
    }

    /// 格式化的时长文本，如 "45:00"
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
