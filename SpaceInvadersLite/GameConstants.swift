import SpriteKit

enum GameConstants {
    static let initialLives = 3
    static let initialColonyIntegrity = 100
    static let initialRewindCharges = 3
    static let scorePerAlien = 10
    static let scorePerWave = 75
    static let scorePerFragment = 5
    static let scorePerBoss = 150
    static let overdrivePerKill = 12
    static let overdriveRadialShots = 16
    static let colonyBloomRepair = 14

    static let playerSize = CGSize(width: 46, height: 24)
    static let playerBottomPadding: CGFloat = 58

    static let bulletSize = CGSize(width: 5, height: 16)
    static let bulletSpeed: CGFloat = 520
    static let fireCooldown: TimeInterval = 0.28
    static let burstCooldown: TimeInterval = 0.12

    static let alienBulletSize = CGSize(width: 6, height: 14)
    static let alienBulletSpeed: CGFloat = 230
    static let alienFireCooldown: TimeInterval = 1.15

    static let alienRows = 4
    static let alienColumns = 7
    static let alienSize = CGSize(width: 30, height: 22)
    static let bossSize = CGSize(width: 86, height: 34)
    static let alienSpacing = CGSize(width: 46, height: 36)
    static let alienTopPadding: CGFloat = 112
    static let alienStartSpeed: CGFloat = 42
    static let alienSpeedIncrease: CGFloat = 9
    static let alienStepDown: CGFloat = 24
    static let bottomDangerZone: CGFloat = 118
    static let colonyPodCount = 3
    static let colonyPodSize = CGSize(width: 38, height: 14)
    static let colonyDamagePerHit = 12
    static let alienContactColonyDamage = 18

    static let fragmentRadius: CGFloat = 6
    static let fragmentSpeed: CGFloat = 80
    static let fragmentPickupRadius: CGFloat = 24

    static let gravityWellRadius: CGFloat = 58
    static let gravityWellStrength: CGFloat = 165

    static let timeSnapshotInterval: TimeInterval = 0.16
    static let maxTimeSnapshots = 28
    static let rewindSnapshotDepth = 14
    static let timeEchoSpeed: CGFloat = 185
    static let riftSize = CGSize(width: 18, height: 84)
    static let riftSpeed: CGFloat = 92
    static let droneRadius: CGFloat = 8
    static let droneOrbitRadius: CGFloat = 40
    static let droneFireCooldown: TimeInterval = 0.78

    static let playerColor = SKColor.systemGreen
    static let bulletColor = SKColor.white
    static let alienBulletColor = SKColor.systemPink
    static let fragmentColor = SKColor.systemCyan
    static let gravityWellColor = SKColor.systemIndigo
    static let colonyColor = SKColor.systemTeal
    static let timeEchoColor = SKColor.systemBlue
    static let riftColor = SKColor.systemRed
    static let droneColor = SKColor.systemMint
    static let bossColor = SKColor.systemPurple
    static let alienColors: [SKColor] = [
        .systemRed,
        .systemPurple,
        .systemOrange,
        .systemYellow
    ]
}
