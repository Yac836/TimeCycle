import Foundation
import SwiftUI
import SwiftData
import Observation

/// 循环编辑视图模型 - 处理新建和编辑循环的逻辑
/// 管理循环的名称、图标、颜色、段列表等编辑状态
@Observable
final class CycleEditViewModel {

    // MARK: - 编辑状态

    /// 循环名称
    var name: String = ""
    /// SF Symbol 图标名
    var icon: String = "timer"
    /// 主题颜色（十六进制）
    var colorHex: String = "#4A90D9"
    /// 段间自动切换
    var autoNextSegment: Bool = true
    /// 循环结束后自动重启
    var autoNextCycle: Bool = true
    /// 编辑中的时间段列表
    var segments: [EditableSegment] = []

    /// 是否为编辑模式（false = 新建）
    var isEditing: Bool { editingCycle != nil }

    // MARK: - 内部

    private var editingCycle: TimeCycle?
    private var modelContext: ModelContext

    /// 可编辑的段（临时结构，保存时才写入 SwiftData）
    struct EditableSegment: Identifiable {
        let id: UUID
        var name: String
        var duration: TimeInterval
        var colorHex: String
        var icon: String

        /// 格式化时长（分钟）
        var durationMinutes: Int {
            get { Int(duration / 60) }
            set { duration = TimeInterval(newValue * 60) }
        }
    }

    // MARK: - 初始化

    /// 新建模式
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 默认添加两个段：坐 + 站
        self.segments = [
            EditableSegment(
                id: UUID(), name: "坐", duration: 2700,
                colorHex: "#4A90D9", icon: "chair.fill"
            ),
            EditableSegment(
                id: UUID(), name: "站", duration: 900,
                colorHex: "#34C759", icon: "figure.stand"
            )
        ]
    }

    /// 编辑模式：从已有循环加载数据
    init(modelContext: ModelContext, cycle: TimeCycle) {
        self.modelContext = modelContext
        self.editingCycle = cycle
        self.name = cycle.name
        self.icon = cycle.icon
        self.colorHex = cycle.colorHex
        self.autoNextSegment = cycle.autoNextSegment
        self.autoNextCycle = cycle.autoNextCycle
        self.segments = cycle.sortedSegments.map {
            EditableSegment(
                id: $0.id, name: $0.name, duration: $0.duration,
                colorHex: $0.colorHex, icon: $0.icon
            )
        }
    }

    // MARK: - 段操作

    /// 添加一个新的时间段
    func addSegment() {
        segments.append(
            EditableSegment(
                id: UUID(), name: "新段", duration: 600,
                colorHex: "#FF9500", icon: "figure.walk"
            )
        )
    }

    /// 删除指定位置的段
    func removeSegment(at offsets: IndexSet) {
        segments.remove(atOffsets: offsets)
    }

    /// 移动段的顺序
    func moveSegment(from source: IndexSet, to destination: Int) {
        segments.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - 验证

    /// 表单是否有效（名称非空且至少有一个段）
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !segments.isEmpty
        && segments.allSatisfy { $0.duration > 0 }
    }

    /// 总时长文本，如 "1小时0分钟"
    var totalDurationText: String {
        let total = segments.reduce(0) { $0 + $1.duration }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }

    // MARK: - 保存

    /// 保存循环（新建或更新）
    func save() {
        if let cycle = editingCycle {
            // 编辑模式：更新已有循环
            cycle.name = name
            cycle.icon = icon
            cycle.colorHex = colorHex
            cycle.autoNextSegment = autoNextSegment
            cycle.autoNextCycle = autoNextCycle
            cycle.updatedAt = .now

            // 删除旧段，重新创建
            for seg in cycle.segments {
                modelContext.delete(seg)
            }
            cycle.segments = createSegments()
        } else {
            // 新建模式
            let cycle = TimeCycle(
                name: name,
                icon: icon,
                colorHex: colorHex,
                segments: [],
                autoNextSegment: autoNextSegment,
                autoNextCycle: autoNextCycle
            )
            cycle.segments = createSegments()
            modelContext.insert(cycle)
        }

        try? modelContext.save()
    }

    /// 从编辑状态创建 SwiftData 段对象
    private func createSegments() -> [TimeSegment] {
        segments.enumerated().map { index, editable in
            TimeSegment(
                name: editable.name,
                duration: editable.duration,
                colorHex: editable.colorHex,
                icon: editable.icon,
                sortOrder: index
            )
        }
    }
}