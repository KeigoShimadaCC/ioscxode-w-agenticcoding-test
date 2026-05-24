import Foundation

enum GamePhase {
    case playing
    case paused
    case gameOver
}

enum Mutation: String, CaseIterable {
    case twinShot
    case wideShot
    case shieldFins
    case unstableBurst
    case heavyCore
    case orbitDrones
    case colonyBloom
    case voidLance

    var displayName: String {
        switch self {
        case .twinShot:
            return "Twin Shot"
        case .wideShot:
            return "Wide Shot"
        case .shieldFins:
            return "Shield Fins"
        case .unstableBurst:
            return "Unstable Burst"
        case .heavyCore:
            return "Heavy Core"
        case .orbitDrones:
            return "Orbit Drones"
        case .colonyBloom:
            return "Colony Bloom"
        case .voidLance:
            return "Void Lance"
        }
    }

    var maxStacks: Int {
        switch self {
        case .twinShot, .wideShot, .shieldFins:
            return 3
        case .unstableBurst, .heavyCore, .orbitDrones, .colonyBloom, .voidLance:
            return 2
        }
    }
}

enum EnemyRole: String {
    case grunt
    case shield
    case sniper
    case flanker
    case diver
    case boss
}

final class GameState: ObservableObject {
    private let highScoreKey = "SpaceInvadersLite.highScore"

    @Published var score: Int = 0
    @Published var highScore: Int
    @Published var lives: Int = GameConstants.initialLives
    @Published var phase: GamePhase = .playing
    @Published var wave: Int = 1
    @Published var colonyIntegrity: Int = GameConstants.initialColonyIntegrity
    @Published var rewindCharges: Int = GameConstants.initialRewindCharges
    @Published var activeMutations: [Mutation: Int] = [:]
    @Published var latestMutationName: String = "None"
    @Published var timeEchoCount: Int = 0
    @Published var combo: Int = 0
    @Published var overdriveCharge: Int = 0
    @Published var anomalyName: String = "Stable"
    @Published var debugAIAvailable: Bool = false
    @Published var debugAIEnabled: Bool = false
    @Published var debugAIStatus: String = "Bot Idle"

    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func reset() {
        score = 0
        lives = GameConstants.initialLives
        phase = .playing
        wave = 1
        colonyIntegrity = GameConstants.initialColonyIntegrity
        rewindCharges = GameConstants.initialRewindCharges
        activeMutations = [:]
        latestMutationName = "None"
        timeEchoCount = 0
        combo = 0
        overdriveCharge = 0
        anomalyName = "Stable"
        debugAIStatus = debugAIEnabled ? "Bot Ready" : "Bot Idle"
    }

    func updateHighScore() {
        guard score > highScore else { return }
        highScore = score
        UserDefaults.standard.set(highScore, forKey: highScoreKey)
    }

    func stackCount(for mutation: Mutation) -> Int {
        activeMutations[mutation, default: 0]
    }

    func addMutation(_ mutation: Mutation) {
        let current = activeMutations[mutation, default: 0]
        activeMutations[mutation] = min(current + 1, mutation.maxStacks)
        latestMutationName = mutation.displayName

        if mutation == .colonyBloom {
            colonyIntegrity = min(GameConstants.initialColonyIntegrity, colonyIntegrity + GameConstants.colonyBloomRepair)
        }
    }

    func addCombo(kills: Int) {
        combo += kills
        overdriveCharge = min(100, overdriveCharge + kills * GameConstants.overdrivePerKill)
    }

    var mutationSummary: String {
        let active = Mutation.allCases.compactMap { mutation -> String? in
            guard let count = activeMutations[mutation], count > 0 else { return nil }
            return "\(mutation.displayName) x\(count)"
        }
        return active.isEmpty ? "No mutations" : active.joined(separator: "  ")
    }
}

enum NodeName {
    static let player = "player"
    static let bullet = "bullet"
    static let alienBullet = "alienBullet"
    static let alien = "alien"
    static let fragment = "fragment"
    static let gravityWell = "gravityWell"
    static let colonyPod = "colonyPod"
    static let timeEcho = "timeEcho"
    static let rift = "rift"
    static let drone = "drone"
}

// SpriteKit physics categories are bit masks. This first version uses manual
// frame intersection for collisions, but keeping the categories visible makes
// it easy to upgrade to SKPhysicsContactDelegate later.
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let bullet: UInt32 = 1 << 1
    static let alien: UInt32 = 1 << 2
    static let alienBullet: UInt32 = 1 << 3
}
