import Foundation
import Observation

/// 计时器状态枚举
enum TimerState: String, Codable, Equatable {
    /// 空闲，未启动
    case idle
    /// 正在运行
    case running
    /// 已暂停
    case paused
    /// 等待手动切换到下一段
    case waitingForManualTransition
    /// 循环已完成，等待手动重启
    case completed
}

/// 计时器服务 - 整个 App 的核心引擎
/// 负责倒计时、段切换、循环重启、后台恢复等所有计时逻辑
@Observable
final class TimerService {

    // MARK: - 对外暴露的状态（UI 绑定用）

    /// 当前计时器状态
    var timerState: TimerState = .idle
    /// 当前正在执行的循环
    var currentCycle: TimeCycle?
    /// 当前执行到第几个时间段（从 0 开始）
    var currentSegmentIndex: Int = 0
    /// 当前段剩余时间（秒）
    var remainingTime: TimeInterval = 0
    /// 当前段已经过的时间（秒）
    var elapsedInSegment: TimeInterval = 0
    /// 循环已经重复了几次
    var cycleIteration: Int = 0

    // MARK: - 内部状态

    /// 系统定时器
    private var timer: Timer?
    /// App 进入后台的时间点（用于恢复计算）
    private var backgroundDate: Date?
    /// 当前段开始的时间点（用墙钟时间计算，不累加 delta）
    private var segmentStartDate: Date?
    /// 暂停时已经过的时间（恢复时需要扣除）
    private var pausedElapsed: TimeInterval = 0

    // MARK: - 依赖服务

    private let notificationService: NotificationService
    private let historyService: HistoryService
    private let hapticService: HapticService

    init(
        notificationService: NotificationService,
        historyService: HistoryService,
        hapticService: HapticService
    ) {
        self.notificationService = notificationService
        self.historyService = historyService
        self.hapticService = hapticService
    }

    // MARK: - 公开 API

    /// 启动一个循环
    func start(cycle: TimeCycle) {
        stop() // 先停掉之前可能在运行的循环
        currentCycle = cycle
        currentSegmentIndex = 0
        cycleIteration = 0
        let firstSegment = cycle.sortedSegments[0]
        remainingTime = firstSegment.duration
        elapsedInSegment = 0
        timerState = .running

        // 记录历史
        historyService.startSession(cycle: cycle)
        historyService.recordSegmentStart(segment: firstSegment)

        startTimer()
    }

    /// 暂停计时
    func pause() {
        guard timerState == .running else { return }
        timer?.invalidate()
        timer = nil
        // 记录暂停时已经过的时间
        if let start = segmentStartDate {
            pausedElapsed = Date().timeIntervalSince(start)
        }
        timerState = .paused
    }

    /// 恢复计时
    func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        // 重新设置起始时间，扣除已经过的时间
        segmentStartDate = Date().addingTimeInterval(-pausedElapsed)
        startTimer()
    }

    /// 停止并重置
    func stop() {
        timer?.invalidate()
        timer = nil
        notificationService.cancelPendingSegmentNotifications()
        if currentCycle != nil {
            historyService.endSession(completedFully: false)
        }
        timerState = .idle
        currentCycle = nil
        currentSegmentIndex = 0
        remainingTime = 0
        elapsedInSegment = 0
        cycleIteration = 0
        pausedElapsed = 0
        segmentStartDate = nil
    }

    /// 跳过当前段，直接进入下一段
    func skipToNextSegment() {
        guard timerState == .running || timerState == .paused else { return }
        timer?.invalidate()
        // 记录当前段完成
        historyService.recordSegmentCompletion(actualDuration: elapsedInSegment)
        moveToNextSegment()
    }

    /// 手动确认切换（用于手动模式下，用户点击"继续"）
    func confirmTransition() {
        guard timerState == .waitingForManualTransition else { return }
        moveToNextSegment()
    }

    // MARK: - 内部计时逻辑

    /// 启动系统定时器，每 0.1 秒刷新一次（保证 UI 倒计时流畅）
    private func startTimer() {
        segmentStartDate = segmentStartDate ?? Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // 确保滑动列表时定时器也能触发
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    /// 每次 tick 更新剩余时间，到 0 时触发段完成
    private func tick() {
        guard timerState == .running,
              let cycle = currentCycle,
              let start = segmentStartDate else { return }

        let segments = cycle.sortedSegments
        guard currentSegmentIndex < segments.count else { return }

        let segment = segments[currentSegmentIndex]
        let elapsed = Date().timeIntervalSince(start)
        elapsedInSegment = min(elapsed, segment.duration)
        remainingTime = max(0, segment.duration - elapsed)

        // 当前段时间到了
        if remainingTime <= 0 {
            onSegmentComplete()
        }
    }

    /// 当前时间段完成时的处理
    private func onSegmentComplete() {
        timer?.invalidate()
        timer = nil

        guard let cycle = currentCycle else { return }
        let segments = cycle.sortedSegments

        // 记录历史
        historyService.recordSegmentCompletion(actualDuration: segments[currentSegmentIndex].duration)

        // 震动提醒用户
        hapticService.segmentComplete()

        let isLastSegment = currentSegmentIndex >= segments.count - 1

        if isLastSegment {
            // 所有段都完成了，处理循环结束
            onCycleComplete()
        } else if cycle.autoNextSegment {
            // 自动模式：直接进入下一段
            advanceToSegment(currentSegmentIndex + 1)
        } else {
            // 手动模式：等待用户确认
            timerState = .waitingForManualTransition
            let nextSegment = segments[currentSegmentIndex + 1]
            notificationService.sendSegmentEndNotification(nextSegment: nextSegment)
        }
    }

    /// 循环的所有段都完成了
    private func onCycleComplete() {
        cycleIteration += 1
        historyService.endSession(completedFully: true)

        guard let cycle = currentCycle else { return }

        if cycle.autoNextCycle {
            // 自动重启：从第一段重新开始
            historyService.startSession(cycle: cycle)
            advanceToSegment(0)
        } else {
            // 手动模式：标记完成，等用户决定
            timerState = .completed
            notificationService.sendCycleCompleteNotification(cycleName: cycle.name)
        }
    }

    /// 切换到下一段（供 skip 和手动确认调用）
    private func moveToNextSegment() {
        guard let cycle = currentCycle else { return }
        let segments = cycle.sortedSegments
        let nextIndex = currentSegmentIndex + 1

        if nextIndex >= segments.count {
            // 已经是最后一段了，触发循环完成
            onCycleComplete()
        } else {
            advanceToSegment(nextIndex)
        }
    }

    /// 跳转到指定段并开始计时
    private func advanceToSegment(_ index: Int) {
        guard let cycle = currentCycle else { return }
        let segments = cycle.sortedSegments
        guard index < segments.count else { return }

        currentSegmentIndex = index
        let segment = segments[index]
        remainingTime = segment.duration
        elapsedInSegment = 0
        pausedElapsed = 0
        segmentStartDate = nil // startTimer 会重新设置
        timerState = .running

        // 记录新段开始
        historyService.recordSegmentStart(segment: segment)
        startTimer()
    }

    // MARK: - 后台处理
    // iOS 在 App 进入后台后会暂停 Timer，所以需要：
    // 1. 进入后台时：预先调度本地通知（确保用户能收到提醒）
    // 2. 回到前台时：根据离开时长快进状态

    /// App 进入后台时调用
    func appDidEnterBackground() {
        guard timerState == .running else { return }
        backgroundDate = Date()
        scheduleBackgroundNotifications()
    }

    /// App 回到前台时调用
    func appWillEnterForeground() {
        guard let bgDate = backgroundDate, timerState == .running else { return }
        let elapsed = Date().timeIntervalSince(bgDate)
        timer?.invalidate()
        timer = nil
        // 取消还没触发的预调度通知
        notificationService.cancelPendingSegmentNotifications()
        // 快进计时器状态
        reconcileAfterBackground(elapsedTime: elapsed)
        backgroundDate = nil
    }

    /// 预先调度所有未来段边界的本地通知
    /// 这样即使 App 被系统挂起，用户也能收到提醒
    private func scheduleBackgroundNotifications() {
        guard let cycle = currentCycle else { return }
        let segments = cycle.sortedSegments
        var timeOffset = remainingTime // 当前段剩余时间

        for i in currentSegmentIndex..<segments.count {
            let isLast = i >= segments.count - 1
            let title = "\(segments[i].name) 完成"
            let body = isLast
                ? "循环完成！干得漂亮 🎉"
                : "下一段：\(segments[i + 1].name)（\(Int(segments[i + 1].duration / 60))分钟）"

            notificationService.scheduleNotification(
                title: title,
                body: body,
                delay: timeOffset
            )

            // 累加下一段的时长
            if !isLast {
                timeOffset += segments[i + 1].duration
            }
        }
    }

    /// 从后台恢复后，根据离开时长快进计时器状态
    /// 可能跨越多个段甚至整个循环
    private func reconcileAfterBackground(elapsedTime: TimeInterval) {
        guard let cycle = currentCycle else { return }
        let segments = cycle.sortedSegments
        var remaining = elapsedTime

        // 先消耗当前段的剩余时间
        if remaining >= remainingTime {
            remaining -= remainingTime
            historyService.recordSegmentCompletion(
                actualDuration: segments[currentSegmentIndex].duration
            )

            // 继续消耗后续段的时间
            var idx = currentSegmentIndex + 1
            while idx < segments.count && remaining >= segments[idx].duration {
                historyService.recordSegmentStart(segment: segments[idx])
                remaining -= segments[idx].duration
                historyService.recordSegmentCompletion(
                    actualDuration: segments[idx].duration
                )
                idx += 1
            }

            if idx >= segments.count {
                // 整个循环都完成了
                onCycleComplete()
            } else {
                // 停在某个段的中间
                currentSegmentIndex = idx
                historyService.recordSegmentStart(segment: segments[idx])
                self.remainingTime = segments[idx].duration - remaining
                elapsedInSegment = remaining
                segmentStartDate = Date().addingTimeInterval(-remaining)
                timerState = .running
                startTimer()
            }
        } else {
            // 还在当前段内，简单扣减
            self.remainingTime -= remaining
            elapsedInSegment += remaining
            segmentStartDate = Date().addingTimeInterval(-elapsedInSegment)
            startTimer()
        }
    }
}