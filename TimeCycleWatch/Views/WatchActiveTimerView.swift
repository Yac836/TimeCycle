import SwiftUI

/// watchOS 计时器视图 - 展示当前循环的倒计时状态
struct WatchActiveTimerView: View {

    let cycle: SyncPayload.Cycle
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var currentSegmentIndex = 0
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var segmentStartDate: Date?
    @State private var pausedElapsed: TimeInterval = 0

    var body: some View {
        VStack(spacing: 8) {
            segmentInfo
            timerRing
            controlButton
        }
        .onDisappear { stopTimer() }
    }

    /// 当前段信息
    private var segmentInfo: some View {
        Group {
            if currentSegmentIndex < cycle.segments.count {
                let seg = cycle.segments[currentSegmentIndex]
                VStack(spacing: 2) {
                    Image(systemName: seg.icon)
                        .font(.title3)
                        .foregroundStyle(Color(hex: seg.colorHex))
                    Text(seg.name)
                        .font(.caption).fontWeight(.medium)
                    Text("\(currentSegmentIndex + 1)/\(cycle.segments.count)")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - 计时控制

    /// 开始计时
    private func startTimer() {
        guard !cycle.segments.isEmpty else { return }
        currentSegmentIndex = 0
        remainingTime = cycle.segments[0].duration
        segmentStartDate = Date()
        isRunning = true
        isPaused = false
        scheduleTimer()
        // 同步命令到 iPhone
        WatchConnectivityService.shared.sendTimerCommand(
            TimerCommand(action: .start, cycleId: cycle.id)
        )
    }

    /// 暂停
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        if let start = segmentStartDate {
            pausedElapsed = Date().timeIntervalSince(start)
        }
        isRunning = false
        isPaused = true
        WatchConnectivityService.shared.sendTimerCommand(
            TimerCommand(action: .pause, cycleId: nil)
        )
    }

    /// 恢复
    private func resumeTimer() {
        segmentStartDate = Date().addingTimeInterval(-pausedElapsed)
        isRunning = true
        isPaused = false
        scheduleTimer()
        WatchConnectivityService.shared.sendTimerCommand(
            TimerCommand(action: .resume, cycleId: nil)
        )
    }

    /// 停止并重置
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
    }
    // MARK: - 计算属性

    /// 当前段颜色
    private var currentColor: Color {
        guard currentSegmentIndex < cycle.segments.count else {
            return Color(hex: "#4A90D9")
        }
        return Color(hex: cycle.segments[currentSegmentIndex].colorHex)
    }

    /// 进度 0.0 ~ 1.0
    private var progress: Double {
        guard currentSegmentIndex < cycle.segments.count else { return 0 }
        let duration = cycle.segments[currentSegmentIndex].duration
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }

    /// 格式化剩余时间
    private var formattedTime: String {
        let total = Int(remainingTime)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    /// 环形倒计时
    private var timerRing: some View {
        WatchTimerRingView(
            progress: progress,
            color: currentColor
        ) {
            Text(formattedTime)
                .font(.system(size: 28, weight: .light, design: .monospaced))
        }
        .frame(width: 120, height: 120)
    }

    /// 播放/暂停按钮
    private var controlButton: some View {
        Group {
            if isRunning {
                Button { pauseTimer() } label: {
                    Image(systemName: "pause.fill")
                }
                .tint(.orange)
            } else if isPaused {
                Button { resumeTimer() } label: {
                    Image(systemName: "play.fill")
                }
                .tint(.green)
            } else {
                Button { startTimer() } label: {
                    Image(systemName: "play.fill")
                }
                .tint(.green)
            }
        }
    }

    // MARK: - 内部计时

    /// 启动 0.1s 间隔的定时器
    private func scheduleTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.1, repeats: true
        ) { _ in tick() }
    }

    /// 每次 tick 更新剩余时间
    private func tick() {
        guard isRunning,
              let start = segmentStartDate,
              currentSegmentIndex < cycle.segments.count else { return }

        let seg = cycle.segments[currentSegmentIndex]
        let elapsed = Date().timeIntervalSince(start)
        remainingTime = max(0, seg.duration - elapsed)

        if remainingTime <= 0 {
            onSegmentComplete()
        }
    }

    /// 当前段完成，自动切换到下一段
    private func onSegmentComplete() {
        timer?.invalidate()
        timer = nil
        HapticService().segmentComplete()

        let nextIndex = currentSegmentIndex + 1
        if nextIndex < cycle.segments.count {
            currentSegmentIndex = nextIndex
            remainingTime = cycle.segments[nextIndex].duration
            segmentStartDate = Date()
            pausedElapsed = 0
            scheduleTimer()
        } else {
            // 循环完成
            isRunning = false
        }
    }
}
