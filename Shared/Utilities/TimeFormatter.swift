import Foundation

/// 时间格式化工具
enum TimeFormatter {

    /// 格式化秒数为 "mm:ss"，如 754 → "12:34"
    static func mmss(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    /// 格式化秒数为中文时长，如 5400 → "1小时30分钟"
    static func chineseDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }
}
