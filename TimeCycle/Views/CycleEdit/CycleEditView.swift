import SwiftUI
import SwiftData

/// 循环编辑视图 - 新建或编辑一个时间循环
struct CycleEditView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CycleEditViewModel

    /// 新建模式
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: CycleEditViewModel(
            modelContext: modelContext
        ))
    }

    /// 编辑模式
    init(modelContext: ModelContext, cycle: TimeCycle) {
        _viewModel = State(initialValue: CycleEditViewModel(
            modelContext: modelContext, cycle: cycle
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                segmentsSection
                behaviorSection
                summarySection
            }
            .navigationTitle(viewModel.isEditing ? "编辑循环" : "新建循环")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// MARK: - Sections

extension CycleEditView {

    /// 基本信息区域
    private var basicInfoSection: some View {
        Section("基本信息") {
            TextField("循环名称", text: $viewModel.name)
            // 图标选择（简化版，用文本输入 SF Symbol 名）
            HStack {
                Text("图标")
                Spacer()
                Image(systemName: viewModel.icon)
                    .foregroundStyle(Color(hex: viewModel.colorHex))
                TextField("SF Symbol", text: $viewModel.icon)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
        }
    }

    /// 时间段编辑区域
    private var segmentsSection: some View {
        Section("时间段") {
            ForEach($viewModel.segments) { $segment in
                SegmentEditView(segment: $segment)
            }
            .onDelete(perform: viewModel.removeSegment)
            .onMove(perform: viewModel.moveSegment)

            Button {
                viewModel.addSegment()
            } label: {
                Label("添加时间段", systemImage: "plus.circle")
            }
        }
    }

    /// 行为配置区域
    private var behaviorSection: some View {
        Section("行为设置") {
            Toggle("段间自动切换", isOn: $viewModel.autoNextSegment)
            Toggle("循环自动重启", isOn: $viewModel.autoNextCycle)
        }
    }

    /// 摘要信息
    private var summarySection: some View {
        Section {
            HStack {
                Text("总时长")
                Spacer()
                Text(viewModel.totalDurationText)
                    .foregroundStyle(.secondary)
            }
        }
    }
}