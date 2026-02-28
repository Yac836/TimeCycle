import Foundation
import SwiftData

/// 段执行记录 - 记录每个时间段的实际执行情况
/// 使用快照保存段信息，即使原始循环被删除/修改，历史数据也不受影响
@Model
final class SegmentRecord {
    var id: UUID
    /// 时间段名称（快照）
    var segmentName: String
    /// 图标（快照）
    var segmentIcon: String
    /// 颜色（快照）
    var segmentColorHex: String
    /// 计划时长（配置的时长）
    var plannedDuration: TimeInterval
    /// 实际时长（用户真正花费的时间）
    var actualDuration: TimeInterval
    /// 开始时间
    var startedAt: Date
    /// 结束时间
    var endedAt: Date?
    /// 所属会话（反向关系）
    var session: CycleSession?

    init(
        segmentName: String,
        segmentIcon: String,
        segmentColorHex: String,
        plannedDuration: TimeInterval
    ) {
        self.id = UUID()
        self.segmentName = segmentName
        self.segmentIcon = segmentIcon
        self.segmentColorHex = segmentColorHex
        self.plannedDuration = plannedDuration
        self.actualDuration = 0
        self.startedAt = .now
    }
}
