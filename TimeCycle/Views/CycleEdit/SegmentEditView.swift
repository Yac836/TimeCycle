import SwiftUI

/// 单个时间段的编辑视图（嵌入在 CycleEditView 的列表中）
struct SegmentEditView: View {

    @Binding var segment: CycleEditViewModel.EditableSegment

    var body: some View {
        VStack(spacing: 8) {
            // 第一行：图标 + 名称
            HStack {
                Image(systemName: segment.icon)
                    .foregroundStyle(Color(hex: segment.colorHex))
                    .frame(width: 24)

                TextField("段名称", text: $segment.name)
            }

            // 第二行：时长选择
            HStack {
                Text("时长")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // 分钟选择器
                Stepper(
                    "\(segment.durationMinutes) 分钟",
                    value: $segment.durationMinutes,
                    in: 1...180,
                    step: 5
                )
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
