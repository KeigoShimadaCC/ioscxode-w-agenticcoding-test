import SpriteKit
import SwiftUI

struct ContentView: View {
    @StateObject private var gameState: GameState
    private let scene: GameScene

    init() {
        let state = GameState()
        _gameState = StateObject(wrappedValue: state)
        scene = GameScene(gameState: state)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // SpriteView lets a SwiftUI screen host a SpriteKit game scene.
                // SwiftUI draws the HUD while SpriteKit runs the frame loop.
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .onAppear {
                        scene.scaleMode = .resizeFill
                        scene.size = proxy.size
                    }
                    .onChange(of: proxy.size) { _, newSize in
                        scene.size = newSize
                    }

                GameHUD(gameState: gameState) {
                    scene.restartGame()
                }
            }
            .background(Color.black)
        }
    }
}
