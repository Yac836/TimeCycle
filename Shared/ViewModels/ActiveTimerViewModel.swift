import Foundation

/// 计时器视图模型 - 连接 TimerService 和 UI
/// 提供 UI 需要的所有计时状态和操作方法
@Observable
final class ActiveTimerViewModel {

    private let timerService: TimerService
    private let connectivityService: WatchConnectivityService

    init(
        timerService: TimerService,
        connectivityService: WatchConnectivityService = .shared
    ) {
        self.timerService = timerService
        self.connectivityService = connectivityService
    }

    // MARK: - 状态（UI 绑定）

    /// 是否正在运行
    var isRunning: Bool { timerService.timerState == .running }
    /// 是否已暂停
    var isPaused: Bool { timerService.timerState == .paused }
    /// 是否空闲
    var isIdle: Bool { timerService.timerState == .idle }
    /// 是否等待手动切换
    var isWaitingForTransition: Bool {
        timerService.timerState == .waitingForManualTransition
    }
    /// 循环是否已完成
    var isCycleComplete: Bool { timerService.timerState == .completed }

    /// 剩余时间（秒）
    var remainingTime: TimeInterval { timerService.remainingTime }

    /// 当前段信息
    var currentSegment: TimeSegment? {
        guard let cycle = timerService.currentCycle else { return nil }
        let sorted = cycle.sortedSegments
        guard timerService.currentSegmentIndex < sorted.count else { return nil }
        return sorted[timerService.currentSegmentIndex]
    }

    /// 进度（0.0 ~ 1.0），用于环形进度条
    var progress: Double {
        guard let seg = currentSegment, seg.duration > 0 else { return 0 }
        return 1.0 - (remainingTime / seg.duration)
    }

    /// 当前段索引
    var segmentIndex: Int { timerService.currentSegmentIndex }
    /// 总段数
    var totalSegments: Int { timerService.currentCycle?.segments.count ?? 0 }
    /// 循环已重复次数
    var cycleIteration: Int { timerService.cycleIteration }

    /// 格式化的剩余时间文本，如 "12:34"
    var formattedRemainingTime: String {
        let total = Int(remainingTime)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - 操作

    /// 启动循环
    func start(cycle: TimeCycle) {
        timerService.start(cycle: cycle)
        connectivityService.sendTimerCommand(
            TimerCommand(action: .start, cycleId: cycle.id)
        )
    }

    /// 暂停
    func pause() {
        timerService.pause()
        connectivityService.sendTimerCommand(
            TimerCommand(action: .pause, cycleId: nil)
        )
    }

    /// 恢复
    func resume() {
        timerService.resume()
        connectivityService.sendTimerCommand(
            TimerCommand(action: .resume, cycleId: nil)
        )
    }

    /// 停止
    func stop() {
        timerService.stop()
        connectivityService.sendTimerCommand(
            TimerCommand(action: .stop, cycleId: nil)
        )
    }

    /// 跳过当前段
    func skipSegment() {
        timerService.skipToNextSegment()
        connectivityService.sendTimerCommand(
            TimerCommand(action: .skipSegment, cycleId: nil)
        )
    }

    /// 手动确认切换到下一段
    func confirmTransition() {
        timerService.confirmTransition()
        connectivityService.sendTimerCommand(
            TimerCommand(action: .confirmTransition, cycleId: nil)
        )
    }
}