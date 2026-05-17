import SpriteKit

enum GameConstants {
    static let initialLives = 3
    static let scorePerAlien = 10

    static let playerSize = CGSize(width: 46, height: 24)
    static let playerBottomPadding: CGFloat = 58

    static let bulletSize = CGSize(width: 5, height: 16)
    static let bulletSpeed: CGFloat = 520
    static let fireCooldown: TimeInterval = 0.28

    static let alienRows = 4
    static let alienColumns = 7
    static let alienSize = CGSize(width: 30, height: 22)
    static let alienSpacing = CGSize(width: 46, height: 36)
    static let alienTopPadding: CGFloat = 112
    static let alienStartSpeed: CGFloat = 42
    static let alienSpeedIncrease: CGFloat = 9
    static let alienStepDown: CGFloat = 24
    static let bottomDangerZone: CGFloat = 118

    static let playerColor = SKColor.systemGreen
    static let bulletColor = SKColor.white
    static let alienColors: [SKColor] = [
        .systemRed,
        .systemPurple,
        .systemOrange,
        .systemYellow
    ]
}
