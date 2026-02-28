import Foundation
import SwiftData

/// 历史统计视图模型 - 提供历史数据的查询和展示
@Observable
final class HistoryViewModel {

    private let historyService: HistoryService

    /// 选中的日期（用于筛选）
    var selectedDate: Date = .now
    /// 当前日期范围内的会话列表
    var sessions: [CycleSession] = []
    /// 按段名统计的时长（秒）
    var durationBySegment: [String: TimeInterval] = [:]

    init(historyService: HistoryService) {
        self.historyService = historyService
    }

    // MARK: - 查询

    /// 加载选中日期当天的数据
    func loadToday() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedDate)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        sessions = historyService.sessionsForDateRange(from: start, to: end)
        durationBySegment = historyService.totalDurationBySegmentName(
            from: start, to: end
        )
    }

    /// 切换到前一天
    func previousDay() {
        selectedDate = Calendar.current.date(
            byAdding: .day, value: -1, to: selectedDate
        )!
        loadToday()
    }

    /// 切换到后一天
    func nextDay() {
        selectedDate = Calendar.current.date(
            byAdding: .day, value: 1, to: selectedDate
        )!
        loadToday()
    }

    // MARK: - 格式化

    /// 格式化日期标题，如 "2月27日 周四"
    var dateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEE"
        return formatter.string(from: selectedDate)
    }

    /// 是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// 格式化时长，如 "1小时30分钟"
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }
}