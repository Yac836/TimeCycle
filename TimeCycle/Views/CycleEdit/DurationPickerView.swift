import SwiftUI

/// 时长选择器 - 用于设置段的持续时间
/// 支持秒级选择（10秒起），方便测试短循环
struct DurationPickerView: View {

    @Binding var duration: TimeInterval
    let title: String

    /// 预设时长选项（秒）
    private static let options: [(label: String, seconds: Int)] = {
        var list: [(String, Int)] = []
        // 10秒 ~ 50秒（每10秒）
        for s in stride(from: 10, through: 50, by: 10) {
            list.append(("\(s) 秒", s))
        }
        // 1分钟 ~ 10分钟（每1分钟）
        for m in 1...10 {
            list.append(("\(m) 分钟", m * 60))
        }
        // 15, 20, 25, 30, 45, 60, 90, 120, 180 分钟
        for m in [15, 20, 25, 30, 45, 60, 90, 120, 180] {
            list.append(("\(m) 分钟", m * 60))
        }
        return list
    }()

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $duration) {
                ForEach(Self.options, id: \.seconds) { option in
                    Text(option.label).tag(TimeInterval(option.seconds))
                }
            }
            .pickerStyle(.menu)
        }
    }
}
