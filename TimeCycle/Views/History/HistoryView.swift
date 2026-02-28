import SwiftUI
import SwiftData

/// 历史统计视图 - 按日期查看循环执行记录
struct HistoryView: View {

    @State private var viewModel: HistoryViewModel?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            if let vm = viewModel {
                historyContent(vm)
            } else {
                ProgressView("加载中...")
            }
        }
        .onAppear { setupViewModel() }
    }

    @ViewBuilder
    private func historyContent(_ vm: HistoryViewModel) -> some View {
        VStack(spacing: 0) {
            // 日期导航栏
            dateNavigator(vm)

            if vm.sessions.isEmpty {
                ContentUnavailableView(
                    "暂无记录",
                    systemImage: "clock.badge.questionmark",
                    description: Text("这一天还没有执行过循环")
                )
            } else {
                List {
                    // 时长统计区
                    if !vm.durationBySegment.isEmpty {
                        Section("时长统计") {
                            HistoryChartView(data: vm.durationBySegment)
                        }
                    }

                    // 会话列表
                    Section("执行记录") {
                        ForEach(vm.sessions) { session in
                            sessionRow(session)
                        }
                    }
                }
            }
        }
        .navigationTitle("统计")
    }

    /// 日期前后切换导航
    private func dateNavigator(_ vm: HistoryViewModel) -> some View {
        HStack {
            Button { vm.previousDay() } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(vm.dateTitle)
                .font(.headline)
            if vm.isToday {
                Text("今天")
                    .font(.caption)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.blue.opacity(0.15))
                    .clipShape(Capsule())
            }
            Spacer()
            Button { vm.nextDay() } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(vm.isToday)
        }
        .padding()
    }

    /// 单条会话行
    private func sessionRow(_ session: CycleSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.cycleName)
                    .font(.headline)
                Spacer()
                if session.completedFully {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text(session.startedAt, style: .time)
                if let end = session.endedAt {
                    Text("→")
                    Text(end, style: .time)
                }
            }
            .font(.caption).foregroundStyle(.secondary)

            // 段记录摘要
            HStack(spacing: 4) {
                ForEach(session.segmentRecords) { record in
                    Image(systemName: record.segmentIcon)
                        .font(.caption2)
                        .foregroundStyle(Color(hex: record.segmentColorHex))
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func setupViewModel() {
        guard viewModel == nil else { return }
        let service = HistoryService(modelContext: modelContext)
        let vm = HistoryViewModel(historyService: service)
        vm.loadToday()
        self.viewModel = vm
    }
}
