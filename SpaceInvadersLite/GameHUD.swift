import SwiftUI

struct GameHUD: View {
    @ObservedObject var gameState: GameState
    let onTogglePause: () -> Void
    let onRewind: () -> Void
    let onRestart: () -> Void
    let onToggleDebugAI: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Score \(gameState.score)")
                    Text("Best \(gameState.highScore)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Wave \(gameState.wave)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.75))
                }
                    .font(.headline.monospacedDigit())

                Spacer()

                if gameState.phase != .gameOver {
                    Button("Rewind \(gameState.rewindCharges)") {
                        onRewind()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.cyan)
                    .disabled(gameState.phase != .playing || gameState.rewindCharges <= 0)

                    Button(gameState.phase == .paused ? "Resume" : "Pause") {
                        onTogglePause()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.white)
                }

                Text("Lives \(gameState.lives)")
                    .font(.headline.monospacedDigit())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            VStack(spacing: 4) {
                HStack {
                    Text("Colony \(gameState.colonyIntegrity)%")
                    Spacer()
                    Text("Combo \(gameState.combo)")
                    Spacer()
                    Text("Echoes \(gameState.timeEchoCount)")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.82))

                HStack {
                    Text("Overdrive \(gameState.overdriveCharge)%")
                    Spacer()
                    Text(gameState.anomalyName)
                }
                .font(.caption2.monospaced())
                .foregroundStyle(.orange.opacity(0.9))

                Text(gameState.mutationSummary)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.9))
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if gameState.debugAIAvailable {
                    HStack(spacing: 8) {
                        Button(gameState.debugAIEnabled ? "Bot On" : "Bot Off") {
                            onToggleDebugAI()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        .tint(gameState.debugAIEnabled ? .mint : .gray)

                        Text(gameState.debugAIStatus)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.mint.opacity(gameState.debugAIEnabled ? 0.92 : 0.55))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            Spacer()

            if gameState.phase == .paused {
                Text("Paused")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding(24)
                    .background(.black.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.bottom, 80)
            } else if gameState.phase == .gameOver {
                VStack(spacing: 14) {
                    Text("Game Over")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Final Score \(gameState.score)")
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.8))

                    Button("Restart") {
                        onRestart()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(24)
                .background(.black.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.bottom, 80)
            }
        }
    }
}
