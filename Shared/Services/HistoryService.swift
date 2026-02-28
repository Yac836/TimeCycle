import Foundation
import SwiftData
import Observation

/// 历史记录服务 - 负责记录和查询循环执行历史
/// 每次启动循环会创建一个 CycleSession，每个段的执行会创建 SegmentRecord
@Observable
final class HistoryService {

    private let modelContext: ModelContext

    /// 当前活跃的会话（正在执行的循环）
    private(set) var activeSession: CycleSession?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - 记录

    /// 开始一个新的循环会话
    func startSession(cycle: TimeCycle) {
        let session = CycleSession(
            cycleName: cycle.name,
            cycleId: cycle.id
        )
        modelContext.insert(session)
        activeSession = session
        save()
    }

    /// 记录一个段的开始
    func recordSegmentStart(segment: TimeSegment) {
        let record = SegmentRecord(
            segmentName: segment.name,
            segmentIcon: segment.icon,
            segmentColorHex: segment.colorHex,
            plannedDuration: segment.duration
        )
        activeSession?.segmentRecords.append(record)
        save()
    }

    /// 记录一个段的完成
    func recordSegmentCompletion(actualDuration: TimeInterval) {
        guard let lastRecord = activeSession?.segmentRecords.last else { return }
        lastRecord.actualDuration = actualDuration
        lastRecord.endedAt = .now
        save()
    }

    /// 结束当前会话
    func endSession(completedFully: Bool) {
        activeSession?.endedAt = .now
        activeSession?.completedFully = completedFully
        save()
        activeSession = nil
    }

    // MARK: - 查询

    /// 查询指定日期范围内的所有会话
    func sessionsForDateRange(from: Date, to: Date) -> [CycleSession] {
        let predicate = #Predicate<CycleSession> {
            $0.startedAt >= from && $0.startedAt <= to
        }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 统计指定日期范围内，每种段类型的总时长
    /// 返回格式：["坐": 7200, "站": 1800, ...]（秒）
    func totalDurationBySegmentName(
        from: Date,
        to: Date
    ) -> [String: TimeInterval] {
        let sessions = sessionsForDateRange(from: from, to: to)
        var result: [String: TimeInterval] = [:]
        for session in sessions {
            for record in session.segmentRecords {
                result[record.segmentName, default: 0] += record.actualDuration
            }
        }
        return result
    }

    // MARK: - 内部

    /// 保存数据到 SwiftData
    private func save() {
        try? modelContext.save()
    }
}
