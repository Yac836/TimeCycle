import SwiftUI

/// 环形进度条视图 - 展示当前段的倒计时进度
struct TimerRingView<Content: View>: View {

    /// 进度值 0.0 ~ 1.0
    let progress: Double
    /// 环的颜色
    let color: Color
    /// 环中心的内容（通常是倒计时文字）
    @ViewBuilder let content: () -> Content

    /// 环的线宽
    private let lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            // 底层灰色轨道
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            // 进度弧线
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            // 中心内容
            content()
        }
    }
}
