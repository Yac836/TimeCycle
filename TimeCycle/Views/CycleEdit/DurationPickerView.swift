import SwiftUI

/// 时长选择器 - 用于设置段的持续时间
struct DurationPickerView: View {

    @Binding var duration: TimeInterval
    let title: String

    /// 分钟数（用于 Picker 绑定）
    private var minutes: Binding<Int> {
        Binding(
            get: { Int(duration / 60) },
            set: { duration = TimeInterval($0 * 60) }
        )
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: minutes) {
                ForEach(1...180, id: \.self) { m in
                    Text("\(m) 分钟").tag(m)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
