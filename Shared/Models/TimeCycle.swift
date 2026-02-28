import Foundation
import SwiftData

/// 时间循环模型 - 核心配置对象
/// 一个循环包含多个时间段，按顺序执行，支持自动/手动切换
@Model
final class TimeCycle {
    var id: UUID
    /// 循环名称，如 "办公模式"、"学习模式"
    var name: String
    /// SF Symbol 图标名称
    var icon: String
    /// 主题颜色（十六进制）
    var colorHex: String
    /// 包含的时间段列表（级联删除）
    @Relationship(deleteRule: .cascade, inverse: \TimeSegment.cycle)
    var segments: [TimeSegment]
    /// 段间是否自动切换（true=自动，false=手动确认）
    var autoNextSegment: Bool
    /// 循环结束后是否自动重新开始
    var autoNextCycle: Bool
    /// 是否已归档（软删除）
    var isArchived: Bool
    /// 创建时间
    var createdAt: Date
    /// 最后修改时间
    var updatedAt: Date
    /// 列表排序顺序
    var sortOrder: Int

    /// 计算属性：所有时间段的总时长（秒）
    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }

    /// 按顺序排列的时间段
    var sortedSegments: [TimeSegment] {
        segments.sorted { $0.sortOrder < $1.sortOrder }
    }

    init(
        name: String,
        icon: String = "timer",
        colorHex: String = "#4A90D9",
        segments: [TimeSegment] = [],
        autoNextSegment: Bool = true,
        autoNextCycle: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.segments = segments
        self.autoNextSegment = autoNextSegment
        self.autoNextCycle = autoNextCycle
        self.isArchived = false
        self.createdAt = .now
        self.updatedAt = .now
        self.sortOrder = sortOrder
    }
}
