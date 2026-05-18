import SwiftUI

struct GameHUD: View {
    @ObservedObject var gameState: GameState
    let onTogglePause: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Score \(gameState.score)")
                    Text("Best \(gameState.highScore)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.75))
                }
                    .font(.headline.monospacedDigit())

                Spacer()

                if gameState.phase != .gameOver {
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
