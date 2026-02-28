import Foundation

/// Watch 同步数据传输对象
/// 因为 SwiftData 模型不能直接序列化传输，所以用 Codable 结构体做中转
enum SyncPayload {

    /// 循环配置的传输结构
    struct Cycle: Codable {
        let id: UUID
        let name: String
        let icon: String
        let colorHex: String
        let segments: [Segment]
        let autoNextSegment: Bool
        let autoNextCycle: Bool

        /// 从 SwiftData 模型转换
        init(from model: TimeCycle) {
            self.id = model.id
            self.name = model.name
            self.icon = model.icon
            self.colorHex = model.colorHex
            self.segments = model.sortedSegments.map { Segment(from: $0) }
            self.autoNextSegment = model.autoNextSegment
            self.autoNextCycle = model.autoNextCycle
        }
    }

    /// 时间段的传输结构
    struct Segment: Codable {
        let id: UUID
        let name: String
        let duration: TimeInterval
        let colorHex: String
        let icon: String
        let sortOrder: Int

        /// 从 SwiftData 模型转换
        init(from model: TimeSegment) {
            self.id = model.id
            self.name = model.name
            self.duration = model.duration
            self.colorHex = model.colorHex
            self.icon = model.icon
            self.sortOrder = model.sortOrder
        }
    }
}

/// 计时器控制命令 - iOS 和 Watch 之间双向发送
struct TimerCommand: Codable {
    enum Action: String, Codable {
        case start      // 启动循环
        case pause      // 暂停
        case resume     // 恢复
        case stop       // 停止
        case skipSegment    // 跳过当前段
        case confirmTransition  // 手动确认切换
    }

    let action: Action
    /// 启动时需要指定循环 ID
    let cycleId: UUID?
}

/// 计时器状态快照 - 用于同步当前计时状态到另一端
struct TimerStateSnapshot: Codable {
    let state: String           // "running", "paused", "idle" 等
    let cycleName: String?
    let currentSegmentName: String?
    let currentSegmentIcon: String?
    let remainingTime: TimeInterval
    let segmentDuration: TimeInterval
    let segmentIndex: Int
    let totalSegments: Int
}