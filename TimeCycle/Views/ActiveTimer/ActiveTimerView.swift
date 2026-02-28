import SwiftUI
import SwiftData

/// 计时器运行视图 - 全屏展示当前计时状态
struct ActiveTimerView: View {

    let cycle: TimeCycle
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: ActiveTimerViewModel?

    var body: some View {
        NavigationStack {
            if let vm = viewModel {
                timerContent(vm)
            } else {
                ProgressView("准备中...")
            }
        }
        .onAppear { setupViewModel() }
        .onChange(of: scenePhase) { _, newPhase in
            guard let vm = viewModel else { return }
            switch newPhase {
            case .background:
                vm.appDidEnterBackground()
            case .active:
                vm.appWillEnterForeground()
            default:
                break
            }
        }
    }

    /// 计时器主内容
    @ViewBuilder
    private func timerContent(_ vm: ActiveTimerViewModel) -> some View {
        VStack(spacing: 32) {
            if let segment = vm.currentSegment {
                VStack(spacing: 8) {
                    Image(systemName: segment.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(Color(hex: segment.colorHex))
                    Text(segment.name)
                        .font(.title2).fontWeight(.medium)
                    Text("第 \(vm.segmentIndex + 1)/\(vm.totalSegments) 段")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            TimerRingView(
                progress: vm.progress,
                color: Color(hex: vm.currentSegment?.colorHex ?? "#4A90D9")
            ) {
                Text(vm.formattedRemainingTime)
                    .font(.system(size: 56, weight: .light, design: .monospaced))
            }
            .frame(width: 240, height: 240)

            if vm.cycleIteration > 0 {
                Text("第 \(vm.cycleIteration + 1) 轮")
                    .font(.caption).foregroundStyle(.secondary)
            }

            controlButtons(vm)
        }
        .padding()
        .navigationTitle(cycle.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { vm.stop(); dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("跳过") { vm.skipSegment() }
                    .disabled(!vm.isRunning && !vm.isPaused)
            }
        }
    }

    /// 控制按钮
    @ViewBuilder
    private func controlButtons(_ vm: ActiveTimerViewModel) -> some View {
        if vm.isRunning {
            circleButton("pause.fill", color: .orange) { vm.pause() }
        } else if vm.isPaused {
            circleButton("play.fill", color: .green) { vm.resume() }
        } else if vm.isWaitingForTransition {
            Button { vm.confirmTransition() } label: {
                Label("继续下一段", systemImage: "forward.fill")
                    .font(.headline).padding()
                    .background(.blue).foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        } else if vm.isCycleComplete {
            Button { vm.start(cycle: cycle) } label: {
                Label("重新开始", systemImage: "arrow.counterclockwise")
                    .font(.headline).padding()
                    .background(.green).foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        } else {
            circleButton("play.fill", color: .green) { vm.start(cycle: cycle) }
        }
    }

    /// 圆形控制按钮（播放/暂停通用样式）
    private func circleButton(
        _ systemName: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(color)
                .clipShape(Circle())
        }
    }

    /// 初始化 ViewModel 并自动开始计时
    private func setupViewModel() {
        guard viewModel == nil else { return }
        let notification = NotificationService()
        let history = HistoryService(modelContext: modelContext)
        let haptic = HapticService()
        let timerSvc = TimerService(
            notificationService: notification,
            historyService: history,
            hapticService: haptic
        )
        let vm = ActiveTimerViewModel(timerService: timerSvc)
        self.viewModel = vm
        vm.start(cycle: cycle)
    }
}