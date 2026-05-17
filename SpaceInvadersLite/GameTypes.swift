import Foundation

enum GamePhase {
    case playing
    case gameOver
}

final class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var lives: Int = GameConstants.initialLives
    @Published var phase: GamePhase = .playing

    func reset() {
        score = 0
        lives = GameConstants.initialLives
        phase = .playing
    }
}

enum NodeName {
    static let player = "player"
    static let bullet = "bullet"
    static let alien = "alien"
}

// SpriteKit physics categories are bit masks. This first version uses manual
// frame intersection for collisions, but keeping the categories visible makes
// it easy to upgrade to SKPhysicsContactDelegate later.
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let bullet: UInt32 = 1 << 1
    static let alien: UInt32 = 1 << 2
}
