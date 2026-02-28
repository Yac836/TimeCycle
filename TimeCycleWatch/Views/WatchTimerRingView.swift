import SwiftUI

/// watchOS 环形进度条（尺寸适配手表屏幕）
struct WatchTimerRingView<Content: View>: View {

    let progress: Double
    let color: Color
    @ViewBuilder let content: () -> Content

    private let lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            content()
        }
    }
}
