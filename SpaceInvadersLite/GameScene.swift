import SpriteKit
import UIKit

final class GameScene: SKScene {
    private struct GravityWell {
        let node: SKShapeNode
        var velocityX: CGFloat
        let strength: CGFloat
        let radius: CGFloat
    }

    private struct ColonyPod {
        let node: SKShapeNode
        var health: Int
    }

    private struct BulletSnapshot {
        let position: CGPoint
        let dx: CGFloat
        let dy: CGFloat
    }

    private struct AlienSnapshot {
        let position: CGPoint
        let role: EnemyRole
        let health: Int
    }

    private struct ColonyPodSnapshot {
        let health: Int
        let alpha: CGFloat
    }

    private struct TimeSnapshot {
        let playerX: CGFloat
        let score: Int
        let lives: Int
        let colonyIntegrity: Int
        let bulletSnapshots: [BulletSnapshot]
        let alienBulletSnapshots: [BulletSnapshot]
        let alienSnapshots: [AlienSnapshot]
        let colonyPodSnapshots: [ColonyPodSnapshot]
    }

    private struct PlayerBehaviorStats {
        var leftFrames = 0
        var rightFrames = 0
        var shotsThisWave = 0
        var lastPlayerX: CGFloat = 0
        var sameDirectionFrames = 0
        var lastMoveDirection: CGFloat = 0

        mutating func reset() {
            leftFrames = 0
            rightFrames = 0
            shotsThisWave = 0
            sameDirectionFrames = 0
            lastMoveDirection = 0
        }
    }

    private let gameState: GameState

    private var player = SKShapeNode()
    private var bullets: [SKShapeNode] = []
    private var alienBullets: [SKShapeNode] = []
    private var aliens: [SKShapeNode] = []
    private var fragments: [SKShapeNode] = []
    private var gravityWells: [GravityWell] = []
    private var colonyPods: [ColonyPod] = []
    private var timeEchoes: [SKShapeNode] = []
    private var rifts: [SKShapeNode] = []
    private var drones: [SKShapeNode] = []
    private var timeSnapshots: [TimeSnapshot] = []
    private var behaviorStats = PlayerBehaviorStats()

    private let isE2EMode = ProcessInfo.processInfo.environment["SPACE_INVADERS_E2E"] == "1"
    private var alienDirection: CGFloat = 1
    private var alienSpeed = GameConstants.alienStartSpeed
    private var lastUpdateTime: TimeInterval = 0
    private var lastFireTime: TimeInterval = 0
    private var lastAlienFireTime: TimeInterval = 0
    private var lastSnapshotTime: TimeInterval = 0
    private var lastDroneFireTime: TimeInterval = 0
    private var lastRiftSpawnTime: TimeInterval = 0
    private var droneAngle: CGFloat = 0

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: UIScreen.main.bounds.size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGame(resetScore: true)
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameState.phase == .playing else {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        updatePlayerBehavior()
        captureSnapshotIfReady(currentTime: currentTime)
        moveGravityWells(deltaTime: deltaTime)
        moveBullets(deltaTime: deltaTime)
        moveAlienBullets(deltaTime: deltaTime)
        moveFragments(deltaTime: deltaTime)
        moveTimeEchoes(deltaTime: deltaTime)
        moveRifts(deltaTime: deltaTime)
        updateOrbitDrones(deltaTime: deltaTime, currentTime: currentTime)
        moveAliens(deltaTime: deltaTime)
        spawnRiftIfReady(currentTime: currentTime)
        fireAlienBulletIfReady(currentTime: currentTime)
        checkBulletAlienCollisions()
        checkFragmentPickups()
        checkAlienBulletImpacts()
        checkTimeEchoHits()
        checkRiftHits()
        checkAlienDangerZone()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        clampPlayerToScreen()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase == .playing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position.x = clampedPlayerX(location.x)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase == .playing else { return }
        fireBulletIfReady()
    }

    func restartGame() {
        setupGame(resetScore: true)
    }

    func togglePause() {
        if gameState.phase == .playing {
            gameState.phase = .paused
        } else if gameState.phase == .paused {
            gameState.phase = .playing
            lastUpdateTime = 0
        }
    }

    func rewindTime() {
        guard gameState.phase == .playing,
              gameState.rewindCharges > 0,
              let snapshot = rewindTargetSnapshot()
        else { return }

        gameState.rewindCharges -= 1
        restore(snapshot)
        spawnTimeEchoes()
        timeSnapshots.removeAll()
        lastUpdateTime = 0
    }

    private func setupGame(resetScore: Bool) {
        removeAllChildren()
        bullets.removeAll()
        alienBullets.removeAll()
        aliens.removeAll()
        fragments.removeAll()
        gravityWells.removeAll()
        colonyPods.removeAll()
        timeEchoes.removeAll()
        rifts.removeAll()
        drones.removeAll()
        timeSnapshots.removeAll()
        behaviorStats.reset()
        alienDirection = 1
        alienSpeed = GameConstants.alienStartSpeed
        lastUpdateTime = 0
        lastFireTime = 0
        lastAlienFireTime = 0
        lastSnapshotTime = 0
        lastDroneFireTime = 0
        lastRiftSpawnTime = 0
        droneAngle = 0

        if resetScore {
            gameState.reset()
        }

        createPlayer()
        createColonyPods()
        applyE2EFixtureIfNeeded()
        createGravityWells()
        updateDroneCount()
        createAliens()
    }

    private func startNextWave() {
        gameState.wave += 1
        gameState.score += GameConstants.scorePerWave
        gameState.updateHighScore()
        alienDirection = 1
        alienSpeed += GameConstants.alienSpeedIncrease
        lastAlienFireTime = lastUpdateTime
        bullets.forEach { $0.removeFromParent() }
        alienBullets.forEach { $0.removeFromParent() }
        rifts.forEach { $0.removeFromParent() }
        bullets.removeAll()
        alienBullets.removeAll()
        rifts.removeAll()
        createGravityWells()
        createAliens()
        behaviorStats.reset()
    }

    private func resetWaveAfterLifeLoss() {
        bullets.forEach { $0.removeFromParent() }
        alienBullets.forEach { $0.removeFromParent() }
        fragments.forEach { $0.removeFromParent() }
        aliens.forEach { $0.removeFromParent() }
        rifts.forEach { $0.removeFromParent() }
        bullets.removeAll()
        alienBullets.removeAll()
        fragments.removeAll()
        aliens.removeAll()
        rifts.removeAll()
        alienDirection = 1
        lastAlienFireTime = lastUpdateTime
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
        updatePlayerAppearance()
    }

    private func createColonyPods() {
        let totalWidth = CGFloat(GameConstants.colonyPodCount - 1) * 76
        let startX = (size.width - totalWidth) / 2
        colonyPods.removeAll()

        for index in 0..<GameConstants.colonyPodCount {
            let pod = SKShapeNode(rectOf: GameConstants.colonyPodSize, cornerRadius: 5)
            pod.name = NodeName.colonyPod
            pod.fillColor = GameConstants.colonyColor.withAlphaComponent(0.8)
            pod.strokeColor = GameConstants.colonyColor
            pod.lineWidth = 1.5
            pod.position = CGPoint(x: startX + CGFloat(index) * 76, y: GameConstants.bottomDangerZone - 30)
            colonyPods.append(ColonyPod(node: pod, health: GameConstants.initialColonyIntegrity / GameConstants.colonyPodCount))
            addChild(pod)
        }
    }

    private func createGravityWells() {
        gravityWells.forEach { $0.node.removeFromParent() }
        gravityWells.removeAll()

        let count = min(1 + gameState.wave / 2, 3)
        for index in 0..<count {
            let well = SKShapeNode(circleOfRadius: GameConstants.gravityWellRadius)
            well.name = NodeName.gravityWell
            well.fillColor = GameConstants.gravityWellColor.withAlphaComponent(0.12)
            well.strokeColor = GameConstants.gravityWellColor.withAlphaComponent(0.72)
            well.lineWidth = 2
            well.position = CGPoint(
                x: size.width * CGFloat(index + 1) / CGFloat(count + 1),
                y: size.height * (0.45 + CGFloat(index % 2) * 0.16)
            )
            addChild(well)

            let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
            gravityWells.append(
                GravityWell(
                    node: well,
                    velocityX: direction * (22 + CGFloat(gameState.wave) * 2),
                    strength: GameConstants.gravityWellStrength + CGFloat(gameState.wave * 12),
                    radius: GameConstants.gravityWellRadius
                )
            )
        }
    }

    private func createAliens() {
        let totalWidth = CGFloat(GameConstants.alienColumns - 1) * GameConstants.alienSpacing.width
        let startX = (size.width - totalWidth) / 2
        let startY = max(size.height - GameConstants.alienTopPadding, size.height * 0.62)
        let rows = isE2EMode ? 2 : GameConstants.alienRows
        let columns = isE2EMode ? 5 : GameConstants.alienColumns

        for row in 0..<rows {
            for column in 0..<columns {
                let role = enemyRole(row: row, column: column)
                let alien = makeAlien(role: role, health: health(for: role))
                alien.position = CGPoint(
                    x: startX + CGFloat(column) * GameConstants.alienSpacing.width,
                    y: startY - CGFloat(row) * GameConstants.alienSpacing.height
                )
                aliens.append(alien)
                addChild(alien)
            }
        }

        if gameState.wave.isMultiple(of: 3) || isE2EMode {
            let boss = makeAlien(role: .boss, health: health(for: .boss))
            boss.position = CGPoint(x: size.width / 2, y: min(size.height - 82, startY + 54))
            aliens.append(boss)
            addChild(boss)
            gameState.anomalyName = "Boss Signal"
        }
    }

    private func makeAlien(role: EnemyRole, health: Int) -> SKShapeNode {
        let size = role == .boss ? GameConstants.bossSize : GameConstants.alienSize
        let alien = SKShapeNode(rectOf: size, cornerRadius: role == .shield ? 9 : 5)
        alien.name = NodeName.alien
        alien.fillColor = color(for: role)
        alien.strokeColor = alien.fillColor
        alien.lineWidth = role == .shield ? 3 : 1
        alien.userData = [
            "role": role.rawValue,
            "health": health
        ]
        return alien
    }

    private func enemyRole(row: Int, column: Int) -> EnemyRole {
        if gameState.wave >= 2 && behaviorStats.shotsThisWave > 12 && row == 0 && column.isMultiple(of: 2) {
            return .shield
        }

        if gameState.wave >= 2 && row == 1 && column.isMultiple(of: 3) {
            return .sniper
        }

        if gameState.wave >= 3 && row == GameConstants.alienRows - 1 && (column == 0 || column == GameConstants.alienColumns - 1) {
            return .flanker
        }

        if gameState.wave >= 4 && row == GameConstants.alienRows - 1 && column.isMultiple(of: 3) {
            return .diver
        }

        if behaviorStats.leftFrames > behaviorStats.rightFrames + 90 && column <= 1 {
            return .flanker
        }

        if behaviorStats.rightFrames > behaviorStats.leftFrames + 90 && column >= GameConstants.alienColumns - 2 {
            return .flanker
        }

        return .grunt
    }

    private func fireBulletIfReady() {
        let now = lastUpdateTime
        let cooldown = gameState.stackCount(for: .unstableBurst) > 0 ? GameConstants.burstCooldown : GameConstants.fireCooldown
        guard now - lastFireTime >= cooldown || lastFireTime == 0 else { return }
        lastFireTime = now
        behaviorStats.shotsThisWave += 1

        let wideStacks = gameState.stackCount(for: .wideShot)
        let twinStacks = gameState.stackCount(for: .twinShot)
        let offsets: [CGFloat] = twinStacks > 0 ? [-10, 10] : [0]
        let angles: [CGFloat] = wideStacks > 0 ? [-0.28, 0, 0.28] : [0]

        if gameState.overdriveCharge >= 100 {
            gameState.overdriveCharge = 0
            gameState.anomalyName = "Overdrive Nova"
            fireOverdriveNova()
        }

        if gameState.stackCount(for: .voidLance) > 0 {
            spawnBullet(
                at: CGPoint(x: player.position.x, y: player.position.y + GameConstants.playerSize.height + 8),
                velocity: CGVector(dx: 0, dy: GameConstants.bulletSpeed * 1.25),
                color: .systemPurple,
                name: NodeName.bullet
            )
        }

        for offset in offsets {
            for angle in angles {
                let dx = GameConstants.bulletSpeed * sin(angle)
                let dy = GameConstants.bulletSpeed * cos(angle)
                spawnBullet(
                    at: CGPoint(x: player.position.x + offset, y: player.position.y + GameConstants.playerSize.height),
                    velocity: CGVector(dx: dx, dy: dy),
                    color: GameConstants.bulletColor,
                    name: NodeName.bullet
                )
            }
        }
    }

    private func fireAlienBulletIfReady(currentTime: TimeInterval) {
        let cooldown = max(0.42, GameConstants.alienFireCooldown - TimeInterval(gameState.wave) * 0.08)
        guard currentTime - lastAlienFireTime >= cooldown, let shooter = pickAlienShooter() else { return }

        lastAlienFireTime = currentTime
        let role = role(for: shooter)
        let lead = min(max((player.position.x - shooter.position.x) / 1.8, -140), 140)
        var velocity = CGVector(dx: 0, dy: -GameConstants.alienBulletSpeed - CGFloat(gameState.wave * 10))

        switch role {
        case .boss:
            velocity.dx = lead * 0.35
            velocity.dy *= 1.08
            spawnBossSpread(from: shooter)
        case .sniper:
            velocity.dx = lead
        case .flanker:
            velocity.dx = shooter.position.x < player.position.x ? 85 : -85
        case .diver:
            velocity.dy *= 1.22
            velocity.dx = lead * 0.55
        case .shield, .grunt:
            break
        }

        let bullet = spawnBullet(
            at: CGPoint(x: shooter.position.x, y: shooter.position.y - GameConstants.alienSize.height),
            velocity: velocity,
            color: GameConstants.alienBulletColor,
            name: NodeName.alienBullet
        )
        alienBullets.append(bullet)
    }

    @discardableResult
    private func spawnBullet(at position: CGPoint, velocity: CGVector, color: SKColor, name: String) -> SKShapeNode {
        let size = name == NodeName.bullet ? GameConstants.bulletSize : GameConstants.alienBulletSize
        let bullet = SKShapeNode(rectOf: size, cornerRadius: 2)
        bullet.name = name
        bullet.fillColor = color
        bullet.strokeColor = color
        bullet.position = position
        bullet.userData = [
            "dx": velocity.dx,
            "dy": velocity.dy
        ]

        if name == NodeName.bullet {
            bullets.append(bullet)
        }

        addChild(bullet)
        return bullet
    }

    private func moveBullets(deltaTime: TimeInterval) {
        move(projectiles: bullets, deltaTime: deltaTime)
        bullets.removeAll { bullet in
            let offscreen = bullet.position.y > size.height + 40 || bullet.position.x < -40 || bullet.position.x > size.width + 40
            if offscreen {
                bullet.removeFromParent()
            }
            return offscreen
        }
    }

    private func moveAlienBullets(deltaTime: TimeInterval) {
        move(projectiles: alienBullets, deltaTime: deltaTime)
        alienBullets.removeAll { bullet in
            let offscreen = bullet.position.y < -40 || bullet.position.x < -40 || bullet.position.x > size.width + 40
            if offscreen {
                bullet.removeFromParent()
            }
            return offscreen
        }
    }

    private func move(projectiles: [SKShapeNode], deltaTime: TimeInterval) {
        let dt = CGFloat(deltaTime)
        for projectile in projectiles {
            var velocity = velocity(for: projectile)
            velocity = gravityAdjustedVelocity(for: projectile.position, velocity: velocity, deltaTime: dt)
            projectile.position.x += velocity.dx * dt
            projectile.position.y += velocity.dy * dt
            setVelocity(velocity, on: projectile)
        }
    }

    private func moveFragments(deltaTime: TimeInterval) {
        let dt = CGFloat(deltaTime)
        for fragment in fragments {
            var velocity = velocity(for: fragment)
            let pullToPlayer = CGVector(
                dx: (player.position.x - fragment.position.x) * 0.7,
                dy: (player.position.y - fragment.position.y) * 0.42
            )
            velocity.dx += pullToPlayer.dx * dt
            velocity.dy += pullToPlayer.dy * dt
            velocity = gravityAdjustedVelocity(for: fragment.position, velocity: velocity, deltaTime: dt * 0.55)
            fragment.position.x += velocity.dx * dt
            fragment.position.y += velocity.dy * dt
            setVelocity(velocity, on: fragment)
        }

        fragments.removeAll { fragment in
            let expired = fragment.position.y < -40
            if expired {
                fragment.removeFromParent()
            }
            return expired
        }
    }

    private func moveTimeEchoes(deltaTime: TimeInterval) {
        let distance = GameConstants.timeEchoSpeed * CGFloat(deltaTime)
        for echo in timeEchoes {
            echo.position.y -= distance
        }

        timeEchoes.removeAll { echo in
            let expired = echo.position.y < -80
            if expired {
                echo.removeFromParent()
            }
            return expired
        }
        gameState.timeEchoCount = timeEchoes.count
    }

    private func moveRifts(deltaTime: TimeInterval) {
        let distance = GameConstants.riftSpeed * CGFloat(deltaTime)
        for rift in rifts {
            rift.position.y -= distance
        }

        rifts.removeAll { rift in
            let expired = rift.position.y < -80
            if expired {
                rift.removeFromParent()
            }
            return expired
        }

        if rifts.isEmpty && gameState.anomalyName == "Rift Storm" {
            gameState.anomalyName = "Stable"
        }
    }

    private func updateOrbitDrones(deltaTime: TimeInterval, currentTime: TimeInterval) {
        updateDroneCount()
        guard !drones.isEmpty else { return }

        droneAngle += CGFloat(deltaTime) * 2.8
        for (index, drone) in drones.enumerated() {
            let angle = droneAngle + CGFloat(index) * (.pi * 2 / CGFloat(max(drones.count, 1)))
            drone.position = CGPoint(
                x: player.position.x + cos(angle) * GameConstants.droneOrbitRadius,
                y: player.position.y + sin(angle) * GameConstants.droneOrbitRadius
            )
        }

        guard currentTime - lastDroneFireTime >= GameConstants.droneFireCooldown else { return }
        lastDroneFireTime = currentTime
        for drone in drones {
            spawnBullet(
                at: drone.position,
                velocity: CGVector(dx: 0, dy: GameConstants.bulletSpeed * 0.78),
                color: GameConstants.droneColor,
                name: NodeName.bullet
            )
        }
    }

    private func moveGravityWells(deltaTime: TimeInterval) {
        for index in gravityWells.indices {
            gravityWells[index].node.position.x += gravityWells[index].velocityX * CGFloat(deltaTime)
            let minX = gravityWells[index].radius
            let maxX = size.width - gravityWells[index].radius
            if gravityWells[index].node.position.x < minX || gravityWells[index].node.position.x > maxX {
                gravityWells[index].velocityX *= -1
                gravityWells[index].node.position.x = min(max(gravityWells[index].node.position.x, minX), maxX)
            }
        }
    }

    private func moveAliens(deltaTime: TimeInterval) {
        guard !aliens.isEmpty else { return }

        let distance = alienSpeed * CGFloat(deltaTime) * alienDirection
        for alien in aliens {
            var drift = distance
            if role(for: alien) == .flanker {
                drift += (alien.position.x < player.position.x ? 1 : -1) * CGFloat(deltaTime) * 22
            }
            alien.position.x += drift

            if role(for: alien) == .diver && abs(alien.position.x - player.position.x) < 42 {
                alien.position.y -= CGFloat(deltaTime) * (28 + CGFloat(gameState.wave * 6))
            }

            if role(for: alien) == .boss {
                alien.position.x += sin(CGFloat(lastUpdateTime) * 1.7) * CGFloat(deltaTime) * 34
            }
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
        var defeatedAliens: [SKShapeNode] = []

        for bullet in bullets {
            for alien in aliens where !defeatedAliens.contains(alien) {
                guard bullet.frame.intersects(alien.frame) else { continue }
                hitBullets.insert(bullet)
                let remainingHealth = health(for: alien) - 1
                if remainingHealth <= 0 {
                    defeatedAliens.append(alien)
                } else {
                    alien.userData?["health"] = remainingHealth
                    alien.run(.sequence([.fadeAlpha(to: 0.35, duration: 0.04), .fadeAlpha(to: 1, duration: 0.08)]))
                }
                break
            }
        }

        guard !hitBullets.isEmpty else { return }

        for bullet in hitBullets {
            bullet.removeFromParent()
        }

        for alien in defeatedAliens {
            spawnFragment(from: alien)
            alien.removeFromParent()
        }

        bullets.removeAll { hitBullets.contains($0) }
        aliens.removeAll { defeatedAliens.contains($0) }
        let bossKills = defeatedAliens.filter { role(for: $0) == .boss }.count
        gameState.score += defeatedAliens.count * GameConstants.scorePerAlien + bossKills * GameConstants.scorePerBoss
        gameState.addCombo(kills: max(1, defeatedAliens.count + bossKills * 3))
        gameState.updateHighScore()

        if aliens.isEmpty {
            startNextWave()
        }
    }

    private func checkFragmentPickups() {
        var pickedUp = Set<SKShapeNode>()

        for fragment in fragments {
            let distanceToPlayer = hypot(fragment.position.x - player.position.x, fragment.position.y - player.position.y)
            guard distanceToPlayer <= GameConstants.fragmentPickupRadius else { continue }
            pickedUp.insert(fragment)
            if let rawMutation = fragment.userData?["mutation"] as? String,
               let mutation = Mutation(rawValue: rawMutation) {
                gameState.addMutation(mutation)
                updatePlayerAppearance()
            }
            gameState.score += GameConstants.scorePerFragment
            gameState.updateHighScore()
        }

        for fragment in pickedUp {
            fragment.removeFromParent()
        }
        fragments.removeAll { pickedUp.contains($0) }
    }

    private func checkAlienBulletImpacts() {
        var removedBullets = Set<SKShapeNode>()

        for bullet in alienBullets {
            if bullet.frame.intersects(player.frame) {
                bullet.removeFromParent()
                alienBullets.removeAll { $0 == bullet }
                loseLife()
                return
            }

            if let podIndex = colonyPods.firstIndex(where: { bullet.frame.intersects($0.node.frame) }) {
                removedBullets.insert(bullet)
                damageColony(amount: GameConstants.colonyDamagePerHit, podIndex: podIndex)
            }
        }

        for bullet in removedBullets {
            bullet.removeFromParent()
        }
        alienBullets.removeAll { removedBullets.contains($0) }
    }

    private func checkTimeEchoHits() {
        guard let hitEcho = timeEchoes.first(where: { $0.frame.intersects(player.frame) }) else { return }
        hitEcho.removeFromParent()
        timeEchoes.removeAll { $0 == hitEcho }
        gameState.timeEchoCount = timeEchoes.count
        loseLife()
    }

    private func checkRiftHits() {
        guard let hitRift = rifts.first(where: { $0.frame.intersects(player.frame) }) else { return }
        hitRift.removeFromParent()
        rifts.removeAll { $0 == hitRift }
        gameState.combo = 0
        loseLife()
    }

    private func checkAlienDangerZone() {
        let invadingAliens = aliens.filter { $0.frame.minY <= GameConstants.bottomDangerZone }
        guard !invadingAliens.isEmpty else { return }

        for alien in invadingAliens {
            alien.removeFromParent()
            damageColony(amount: GameConstants.alienContactColonyDamage, podIndex: nil)
        }
        aliens.removeAll { invadingAliens.contains($0) }

        if aliens.isEmpty && gameState.phase == .playing {
            startNextWave()
        }
    }

    private func loseLife() {
        let shieldStacks = gameState.stackCount(for: .shieldFins)
        if shieldStacks > 0 && Int.random(in: 0..<4) < shieldStacks {
            gameState.latestMutationName = "Shield Fins blocked"
            return
        }

        gameState.lives -= 1
        gameState.combo = 0
        if isE2EMode {
            gameState.lives = max(1, gameState.lives)
            return
        }
        if gameState.lives <= 0 {
            endGame()
        } else {
            resetWaveAfterLifeLoss()
        }
    }

    private func damageColony(amount: Int, podIndex: Int?) {
        gameState.colonyIntegrity = max(0, gameState.colonyIntegrity - amount)
        if isE2EMode {
            gameState.colonyIntegrity = max(30, gameState.colonyIntegrity)
        }

        if let podIndex {
            colonyPods[podIndex].health = max(0, colonyPods[podIndex].health - amount)
            colonyPods[podIndex].node.alpha = max(0.25, CGFloat(colonyPods[podIndex].health) / CGFloat(GameConstants.initialColonyIntegrity / GameConstants.colonyPodCount))
        }

        if gameState.colonyIntegrity <= 0 {
            endGame()
        }
    }

    private func endGame() {
        gameState.phase = .gameOver
        bullets.forEach { $0.removeFromParent() }
        alienBullets.forEach { $0.removeFromParent() }
        timeEchoes.forEach { $0.removeFromParent() }
        rifts.forEach { $0.removeFromParent() }
        bullets.removeAll()
        alienBullets.removeAll()
        timeEchoes.removeAll()
        rifts.removeAll()
        gameState.timeEchoCount = 0
        gameState.updateHighScore()
    }

    private func spawnFragment(from alien: SKShapeNode) {
        guard role(for: alien) == .boss || Int.random(in: 0..<100) < 76 else { return }
        let mutation = Mutation.allCases.randomElement() ?? .twinShot
        let fragment = SKShapeNode(circleOfRadius: GameConstants.fragmentRadius)
        fragment.name = NodeName.fragment
        fragment.fillColor = GameConstants.fragmentColor
        fragment.strokeColor = .white
        fragment.lineWidth = 1
        fragment.position = alien.position
        fragment.userData = [
            "mutation": mutation.rawValue,
            "dx": CGFloat.random(in: -45...45),
            "dy": -GameConstants.fragmentSpeed
        ]
        fragments.append(fragment)
        addChild(fragment)
    }

    private func spawnRiftIfReady(currentTime: TimeInterval) {
        let cooldown = max(1.2, 4.8 - TimeInterval(gameState.wave) * 0.35)
        guard gameState.wave >= 2 || isE2EMode,
              currentTime - lastRiftSpawnTime >= cooldown
        else { return }

        lastRiftSpawnTime = currentTime
        gameState.anomalyName = "Rift Storm"
        let laneCount = isE2EMode ? 2 : min(1 + gameState.wave / 3, 3)
        for index in 0..<laneCount {
            let rift = SKShapeNode(rectOf: GameConstants.riftSize, cornerRadius: 9)
            rift.name = NodeName.rift
            rift.fillColor = GameConstants.riftColor.withAlphaComponent(0.35)
            rift.strokeColor = GameConstants.riftColor
            rift.lineWidth = 2
            let laneX = size.width * CGFloat(index + 1) / CGFloat(laneCount + 1)
            rift.position = CGPoint(x: laneX, y: size.height + CGFloat(index) * 48)
            rifts.append(rift)
            addChild(rift)
        }
    }

    private func spawnBossSpread(from boss: SKShapeNode) {
        for angle in [-0.34, 0, 0.34] as [CGFloat] {
            let velocity = CGVector(
                dx: GameConstants.alienBulletSpeed * sin(angle),
                dy: -GameConstants.alienBulletSpeed * cos(angle)
            )
            let bullet = spawnBullet(
                at: CGPoint(x: boss.position.x, y: boss.position.y - GameConstants.bossSize.height / 2),
                velocity: velocity,
                color: GameConstants.bossColor,
                name: NodeName.alienBullet
            )
            alienBullets.append(bullet)
        }
    }

    private func fireOverdriveNova() {
        for index in 0..<GameConstants.overdriveRadialShots {
            let angle = CGFloat(index) * (.pi * 2 / CGFloat(GameConstants.overdriveRadialShots))
            spawnBullet(
                at: player.position,
                velocity: CGVector(dx: GameConstants.bulletSpeed * cos(angle), dy: GameConstants.bulletSpeed * sin(angle)),
                color: .systemOrange,
                name: NodeName.bullet
            )
        }
        rifts.forEach { $0.removeFromParent() }
        rifts.removeAll()
    }

    private func updateDroneCount() {
        let targetCount = min(gameState.stackCount(for: .orbitDrones), 2)
        if drones.count == targetCount { return }

        drones.forEach { $0.removeFromParent() }
        drones.removeAll()
        for index in 0..<targetCount {
            let drone = SKShapeNode(circleOfRadius: GameConstants.droneRadius)
            drone.name = NodeName.drone
            drone.fillColor = GameConstants.droneColor
            drone.strokeColor = .white
            let angle = CGFloat(index) * .pi
            drone.position = CGPoint(
                x: player.position.x + cos(angle) * GameConstants.droneOrbitRadius,
                y: player.position.y + sin(angle) * GameConstants.droneOrbitRadius
            )
            drones.append(drone)
            addChild(drone)
        }
    }

    private func spawnTimeEchoes() {
        let lanes = [
            player.position.x,
            player.position.x - 56,
            player.position.x + 56
        ]

        for lane in lanes {
            let echo = SKShapeNode(rectOf: CGSize(width: 14, height: 72), cornerRadius: 7)
            echo.name = NodeName.timeEcho
            echo.fillColor = GameConstants.timeEchoColor.withAlphaComponent(0.32)
            echo.strokeColor = GameConstants.timeEchoColor
            echo.lineWidth = 1.5
            echo.position = CGPoint(x: min(max(lane, 16), size.width - 16), y: size.height + 40)
            timeEchoes.append(echo)
            addChild(echo)
        }
        gameState.timeEchoCount = timeEchoes.count
    }

    private func captureSnapshotIfReady(currentTime: TimeInterval) {
        guard currentTime - lastSnapshotTime >= GameConstants.timeSnapshotInterval else { return }
        lastSnapshotTime = currentTime

        let snapshot = TimeSnapshot(
            playerX: player.position.x,
            score: gameState.score,
            lives: gameState.lives,
            colonyIntegrity: gameState.colonyIntegrity,
            bulletSnapshots: bullets.map { BulletSnapshot(position: $0.position, dx: velocity(for: $0).dx, dy: velocity(for: $0).dy) },
            alienBulletSnapshots: alienBullets.map { BulletSnapshot(position: $0.position, dx: velocity(for: $0).dx, dy: velocity(for: $0).dy) },
            alienSnapshots: aliens.map { AlienSnapshot(position: $0.position, role: role(for: $0), health: health(for: $0)) },
            colonyPodSnapshots: colonyPods.map { ColonyPodSnapshot(health: $0.health, alpha: $0.node.alpha) }
        )

        timeSnapshots.insert(snapshot, at: 0)
        if timeSnapshots.count > GameConstants.maxTimeSnapshots {
            timeSnapshots.removeLast()
        }
    }

    private func rewindTargetSnapshot() -> TimeSnapshot? {
        guard !timeSnapshots.isEmpty else { return nil }
        let targetIndex = min(GameConstants.rewindSnapshotDepth, timeSnapshots.count - 1)
        return timeSnapshots[targetIndex]
    }

    private func restore(_ snapshot: TimeSnapshot) {
        player.position.x = clampedPlayerX(snapshot.playerX)
        gameState.score = snapshot.score
        gameState.lives = snapshot.lives
        gameState.colonyIntegrity = snapshot.colonyIntegrity

        bullets.forEach { $0.removeFromParent() }
        alienBullets.forEach { $0.removeFromParent() }
        aliens.forEach { $0.removeFromParent() }
        bullets.removeAll()
        alienBullets.removeAll()
        aliens.removeAll()

        for bulletSnapshot in snapshot.bulletSnapshots {
            spawnBullet(
                at: bulletSnapshot.position,
                velocity: CGVector(dx: bulletSnapshot.dx, dy: bulletSnapshot.dy),
                color: GameConstants.bulletColor,
                name: NodeName.bullet
            )
        }

        for bulletSnapshot in snapshot.alienBulletSnapshots {
            let bullet = spawnBullet(
                at: bulletSnapshot.position,
                velocity: CGVector(dx: bulletSnapshot.dx, dy: bulletSnapshot.dy),
                color: GameConstants.alienBulletColor,
                name: NodeName.alienBullet
            )
            alienBullets.append(bullet)
        }

        for alienSnapshot in snapshot.alienSnapshots {
            let alien = makeAlien(role: alienSnapshot.role, health: alienSnapshot.health)
            alien.position = alienSnapshot.position
            aliens.append(alien)
            addChild(alien)
        }

        for index in colonyPods.indices {
            guard snapshot.colonyPodSnapshots.indices.contains(index) else { continue }
            colonyPods[index].health = snapshot.colonyPodSnapshots[index].health
            colonyPods[index].node.alpha = snapshot.colonyPodSnapshots[index].alpha
        }
    }

    private func updatePlayerBehavior() {
        if player.position.x < size.width * 0.34 {
            behaviorStats.leftFrames += 1
        } else if player.position.x > size.width * 0.66 {
            behaviorStats.rightFrames += 1
        }

        let movement = player.position.x - behaviorStats.lastPlayerX
        let direction: CGFloat = movement == 0 ? 0 : (movement > 0 ? 1 : -1)
        if direction != 0 && direction == behaviorStats.lastMoveDirection {
            behaviorStats.sameDirectionFrames += 1
        } else if direction != 0 {
            behaviorStats.sameDirectionFrames = 0
            behaviorStats.lastMoveDirection = direction
        }
        behaviorStats.lastPlayerX = player.position.x
    }

    private func updatePlayerAppearance() {
        let heavyStacks = gameState.stackCount(for: .heavyCore)
        player.xScale = 1 + CGFloat(heavyStacks) * 0.12
        player.yScale = 1 + CGFloat(gameState.stackCount(for: .shieldFins)) * 0.08
        player.fillColor = heavyStacks > 0 ? .systemMint : GameConstants.playerColor
        player.strokeColor = gameState.stackCount(for: .shieldFins) > 0 ? .white : player.fillColor
    }

    private func applyE2EFixtureIfNeeded() {
        guard isE2EMode else { return }
        gameState.wave = 3
        gameState.addMutation(.twinShot)
        gameState.addMutation(.wideShot)
        gameState.addMutation(.orbitDrones)
        gameState.addMutation(.voidLance)
        gameState.overdriveCharge = 100
        gameState.anomalyName = "E2E Chaos"
        updatePlayerAppearance()
    }

    private func gravityAdjustedVelocity(for position: CGPoint, velocity: CGVector, deltaTime: CGFloat) -> CGVector {
        var adjusted = velocity
        for well in gravityWells {
            let dx = well.node.position.x - position.x
            let dy = well.node.position.y - position.y
            let distance = max(22, hypot(dx, dy))
            guard distance < well.radius * 2.2 else { continue }
            let pull = well.strength / distance
            adjusted.dx += dx / distance * pull * deltaTime * 60
            adjusted.dy += dy / distance * pull * deltaTime * 60
        }
        return adjusted
    }

    private func pickAlienShooter() -> SKShapeNode? {
        if behaviorStats.sameDirectionFrames > 28,
           let sniper = aliens.first(where: { role(for: $0) == .sniper }) {
            return sniper
        }

        if behaviorStats.leftFrames > behaviorStats.rightFrames + 90,
           let flanker = aliens.first(where: { role(for: $0) == .flanker && $0.position.x < size.width * 0.45 }) {
            return flanker
        }

        if behaviorStats.rightFrames > behaviorStats.leftFrames + 90,
           let flanker = aliens.first(where: { role(for: $0) == .flanker && $0.position.x > size.width * 0.55 }) {
            return flanker
        }

        return aliens.randomElement()
    }

    private func color(for role: EnemyRole) -> SKColor {
        switch role {
        case .grunt:
            return GameConstants.alienColors.randomElement() ?? .systemRed
        case .boss:
            return GameConstants.bossColor
        case .shield:
            return .systemGray
        case .sniper:
            return .systemPink
        case .flanker:
            return .systemOrange
        case .diver:
            return .systemYellow
        }
    }

    private func health(for role: EnemyRole) -> Int {
        switch role {
        case .boss:
            return isE2EMode ? 5 : 9 + gameState.wave
        case .shield:
            return 2 + min(gameState.wave / 4, 2)
        case .diver:
            return 2
        case .grunt, .sniper, .flanker:
            return 1
        }
    }

    private func role(for alien: SKShapeNode) -> EnemyRole {
        guard let rawRole = alien.userData?["role"] as? String else { return .grunt }
        return EnemyRole(rawValue: rawRole) ?? .grunt
    }

    private func health(for alien: SKShapeNode) -> Int {
        alien.userData?["health"] as? Int ?? 1
    }

    private func velocity(for node: SKShapeNode) -> CGVector {
        CGVector(
            dx: node.userData?["dx"] as? CGFloat ?? 0,
            dy: node.userData?["dy"] as? CGFloat ?? 0
        )
    }

    private func setVelocity(_ velocity: CGVector, on node: SKShapeNode) {
        node.userData?["dx"] = velocity.dx
        node.userData?["dy"] = velocity.dy
    }

    private func clampPlayerToScreen() {
        guard player.parent != nil else { return }
        player.position.x = clampedPlayerX(player.position.x)
        player.position.y = GameConstants.playerBottomPadding
    }

    private func clampedPlayerX(_ x: CGFloat) -> CGFloat {
        let heavyPenalty = CGFloat(gameState.stackCount(for: .heavyCore)) * 3
        let halfWidth = GameConstants.playerSize.width / 2 + heavyPenalty
        return min(max(x, halfWidth + 8), size.width - halfWidth - 8)
    }
}
