import SpriteKit
import UIKit

final class GameScene: SKScene {
    private let gameState: GameState

    private var player = SKShapeNode()
    private var bullets: [SKShapeNode] = []
    private var aliens: [SKShapeNode] = []

    private var alienDirection: CGFloat = 1
    private var alienSpeed = GameConstants.alienStartSpeed
    private var lastUpdateTime: TimeInterval = 0
    private var lastFireTime: TimeInterval = 0

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: UIScreen.main.bounds.size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // didMove(to:) is called when SpriteKit presents this scene in a view.
    // It is the right place to create nodes because the scene now has a size.
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGame(resetScore: true)
    }

    // update(_:) is SpriteKit's frame loop. It runs many times per second, so
    // this is where simple games usually move nodes and check collisions.
    override func update(_ currentTime: TimeInterval) {
        guard gameState.phase == .playing else {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        moveBullets(deltaTime: deltaTime)
        moveAliens(deltaTime: deltaTime)
        checkBulletAlienCollisions()
        checkAlienDangerZone()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        clampPlayerToScreen()
    }

    // touchesMoved(_:with:) handles dragging. The player only follows the
    // finger horizontally so the ship stays near the bottom of the iPhone.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase == .playing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position.x = clampedPlayerX(location.x)
    }

    // touchesEnded(_:with:) handles taps. A short cooldown keeps the bullet
    // count readable and avoids flooding the scene with nodes.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase == .playing else { return }
        fireBulletIfReady()
    }

    func restartGame() {
        setupGame(resetScore: true)
    }

    private func setupGame(resetScore: Bool) {
        removeAllChildren()
        bullets.removeAll()
        aliens.removeAll()
        alienDirection = 1
        alienSpeed = resetScore ? GameConstants.alienStartSpeed : alienSpeed
        lastUpdateTime = 0
        lastFireTime = 0

        if resetScore {
            gameState.reset()
        }

        createPlayer()
        createAliens()
    }

    private func resetWaveAfterLifeLoss() {
        bullets.forEach { $0.removeFromParent() }
        aliens.forEach { $0.removeFromParent() }
        bullets.removeAll()
        aliens.removeAll()
        alienDirection = 1
        createAliens()
    }

    private func createPlayer() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: GameConstants.playerSize.height / 2))
        path.addLine(to: CGPoint(x: -GameConstants.playerSize.width / 2, y: -GameConstants.playerSize.height / 2))
        path.addLine(to: CGPoint(x: GameConstants.playerSize.width / 2, y: -GameConstants.playerSize.height / 2))
        path.closeSubpath()

        player = SKShapeNode(path: path)
        player.name = NodeName.player
        player.fillColor = GameConstants.playerColor
        player.strokeColor = GameConstants.playerColor
        player.lineWidth = 1
        player.position = CGPoint(x: size.width / 2, y: GameConstants.playerBottomPadding)
        addChild(player)
    }

    private func createAliens() {
        let totalWidth = CGFloat(GameConstants.alienColumns - 1) * GameConstants.alienSpacing.width
        let startX = (size.width - totalWidth) / 2
        let startY = max(size.height - GameConstants.alienTopPadding, size.height * 0.62)

        for row in 0..<GameConstants.alienRows {
            for column in 0..<GameConstants.alienColumns {
                let alien = SKShapeNode(rectOf: GameConstants.alienSize, cornerRadius: 5)
                alien.name = NodeName.alien
                alien.fillColor = GameConstants.alienColors[row % GameConstants.alienColors.count]
                alien.strokeColor = alien.fillColor
                alien.lineWidth = 1
                alien.position = CGPoint(
                    x: startX + CGFloat(column) * GameConstants.alienSpacing.width,
                    y: startY - CGFloat(row) * GameConstants.alienSpacing.height
                )
                aliens.append(alien)
                addChild(alien)
            }
        }
    }

    private func fireBulletIfReady() {
        let now = lastUpdateTime
        guard now - lastFireTime >= GameConstants.fireCooldown || lastFireTime == 0 else { return }
        lastFireTime = now

        let bullet = SKShapeNode(rectOf: GameConstants.bulletSize, cornerRadius: 2)
        bullet.name = NodeName.bullet
        bullet.fillColor = GameConstants.bulletColor
        bullet.strokeColor = GameConstants.bulletColor
        bullet.position = CGPoint(
            x: player.position.x,
            y: player.position.y + GameConstants.playerSize.height
        )
        bullets.append(bullet)
        addChild(bullet)
    }

    private func moveBullets(deltaTime: TimeInterval) {
        let distance = GameConstants.bulletSpeed * CGFloat(deltaTime)
        for bullet in bullets {
            bullet.position.y += distance
        }

        bullets.removeAll { bullet in
            if bullet.position.y > size.height + GameConstants.bulletSize.height {
                bullet.removeFromParent()
                return true
            }
            return false
        }
    }

    private func moveAliens(deltaTime: TimeInterval) {
        guard !aliens.isEmpty else { return }

        let distance = alienSpeed * CGFloat(deltaTime) * alienDirection
        for alien in aliens {
            alien.position.x += distance
        }

        let frames = aliens.map(\.frame)
        let minX = frames.map(\.minX).min() ?? 0
        let maxX = frames.map(\.maxX).max() ?? size.width
        let hitEdge = minX <= 12 || maxX >= size.width - 12

        if hitEdge {
            alienDirection *= -1
            for alien in aliens {
                alien.position.x += alienSpeed * 0.08 * alienDirection
                alien.position.y -= GameConstants.alienStepDown
            }
        }
    }

    private func checkBulletAlienCollisions() {
        var hitBullets = Set<SKShapeNode>()
        var hitAliens = Set<SKShapeNode>()

        for bullet in bullets {
            for alien in aliens where !hitAliens.contains(alien) {
                if bullet.frame.intersects(alien.frame) {
                    hitBullets.insert(bullet)
                    hitAliens.insert(alien)
                    break
                }
            }
        }

        guard !hitAliens.isEmpty else { return }

        for bullet in hitBullets {
            bullet.removeFromParent()
        }
        for alien in hitAliens {
            alien.removeFromParent()
        }

        bullets.removeAll { hitBullets.contains($0) }
        aliens.removeAll { hitAliens.contains($0) }
        gameState.score += hitAliens.count * GameConstants.scorePerAlien

        if aliens.isEmpty {
            alienSpeed += GameConstants.alienSpeedIncrease
            createAliens()
        }
    }

    private func checkAlienDangerZone() {
        let dangerY = GameConstants.bottomDangerZone
        guard aliens.contains(where: { $0.frame.minY <= dangerY }) else { return }

        gameState.lives -= 1
        if gameState.lives <= 0 {
            gameState.phase = .gameOver
            bullets.forEach { $0.removeFromParent() }
            bullets.removeAll()
        } else {
            resetWaveAfterLifeLoss()
        }
    }

    private func clampPlayerToScreen() {
        guard player.parent != nil else { return }
        player.position.x = clampedPlayerX(player.position.x)
        player.position.y = GameConstants.playerBottomPadding
    }

    private func clampedPlayerX(_ x: CGFloat) -> CGFloat {
        let halfWidth = GameConstants.playerSize.width / 2
        return min(max(x, halfWidth + 8), size.width - halfWidth - 8)
    }
}
