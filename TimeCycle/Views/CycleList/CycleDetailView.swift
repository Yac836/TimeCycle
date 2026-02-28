import SwiftUI
import SwiftData

/// 循环详情视图 - 展示循环配置并提供启动入口
struct CycleDetailView: View {

    let cycle: TimeCycle
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    @State private var showingTimer = false

    var body: some View {
        List {
            Section("基本信息") {
                HStack {
                    Text("总时长")
                    Spacer()
                    Text(formatDuration(cycle.totalDuration))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("段间切换")
                    Spacer()
                    Text(cycle.autoNextSegment ? "自动" : "手动")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("循环重启")
                    Spacer()
                    Text(cycle.autoNextCycle ? "自动" : "手动")
                        .foregroundStyle(.secondary)
                }
            }

            Section("时间段") {
                ForEach(cycle.sortedSegments) { segment in
                    HStack {
                        Image(systemName: segment.icon)
                            .foregroundStyle(Color(hex: segment.colorHex))
                            .frame(width: 24)
                        Text(segment.name)
                        Spacer()
                        Text(segment.formattedDuration)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    showingTimer = true
                } label: {
                    Label("开始计时", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .disabled(cycle.segments.isEmpty)
            }
        }
        .navigationTitle(cycle.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            CycleEditView(modelContext: modelContext, cycle: cycle)
        }
        .fullScreenCover(isPresented: $showingTimer) {
            ActiveTimerView(cycle: cycle)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)小时\(minutes)分钟" }
        return "\(minutes)分钟"
    }
}
