import Foundation

/// 全局常量
enum AppConstants {

    /// 默认段颜色列表（供用户选择）
    static let segmentColors: [String] = [
        "#4A90D9", // 蓝
        "#E67E22", // 橙
        "#2ECC71", // 绿
        "#E74C3C", // 红
        "#9B59B6", // 紫
        "#1ABC9C", // 青
        "#F39C12", // 黄
        "#34495E", // 深灰
    ]

    /// 默认段图标列表
    static let segmentIcons: [String] = [
        "chair.fill",           // 坐
        "figure.stand",         // 站
        "figure.walk",          // 走动
        "figure.run",           // 跑步
        "cup.and.saucer.fill",  // 休息
        "eye.slash.fill",       // 闭眼
        "hands.sparkles.fill",  // 拉伸
        "brain.head.profile",   // 专注
    ]

    /// 默认循环图标列表
    static let cycleIcons: [String] = [
        "timer",
        "clock.fill",
        "deskclock.fill",
        "alarm.fill",
        "hourglass",
        "figure.stand",
        "laptopcomputer",
        "heart.fill",
    ]
}
