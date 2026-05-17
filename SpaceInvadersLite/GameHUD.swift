import SwiftUI

struct GameHUD: View {
    @ObservedObject var gameState: GameState
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Score \(gameState.score)")
                    .font(.headline.monospacedDigit())

                Spacer()

                Text("Lives \(gameState.lives)")
                    .font(.headline.monospacedDigit())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Spacer()

            if gameState.phase == .gameOver {
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
