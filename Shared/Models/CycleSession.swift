import Foundation
import SwiftData

/// 循环会话 - 记录一次完整的循环执行过程
/// 每次用户启动一个循环，就会创建一个会话
@Model
final class CycleSession {
    var id: UUID
    /// 循环名称（快照，防止原循环被修改后丢失）
    var cycleName: String
    /// 关联的循环 ID（循环被删除后为 nil）
    var cycleId: UUID?
    /// 会话开始时间
    var startedAt: Date
    /// 会话结束时间
    var endedAt: Date?
    /// 是否完整完成了所有时间段
    var completedFully: Bool
    /// 本次会话中所有段的执行记录
    @Relationship(deleteRule: .cascade, inverse: \SegmentRecord.session)
    var segmentRecords: [SegmentRecord]

    init(cycleName: String, cycleId: UUID?) {
        self.id = UUID()
        self.cycleName = cycleName
        self.cycleId = cycleId
        self.startedAt = .now
        self.completedFully = false
        self.segmentRecords = []
    }
}
