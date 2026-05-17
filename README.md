# SpaceInvadersLite

## Goal
SpaceInvadersLite is a tiny native iPhone learning app for Xcode project structure, the SwiftUI app lifecycle, SpriteKit 2D game basics, and an agentic coding workflow for iOS. It is intentionally small and has no backend, analytics, ads, App Store setup, TestFlight setup, image assets, or external packages.

## What the app does
- Shows a dark portrait game screen with a green player ship near the bottom.
- Lets you drag horizontally to move the ship.
- Lets you tap to shoot upward bullets.
- Spawns a grid of geometric aliens near the top.
- Moves aliens side to side and steps them downward at screen edges.
- Destroys aliens when bullets hit them.
- Tracks score, lives, game over, and restart.

## Project structure
- `project.yml`: XcodeGen project description. Regenerate the Xcode project with `xcodegen generate`.
- `SpaceInvadersLite.xcodeproj`: generated Xcode project opened by Xcode.
- `SpaceInvadersLite/SpaceInvadersLiteApp.swift`: SwiftUI `@main` entry point.
- `SpaceInvadersLite/ContentView.swift`: embeds SpriteKit with `SpriteView` and overlays the HUD.
- `SpaceInvadersLite/GameScene.swift`: SpriteKit scene with player, bullets, aliens, collision, lives, and restart logic.
- `SpaceInvadersLite/GameHUD.swift`: SwiftUI score, lives, game-over, and restart UI.
- `SpaceInvadersLite/GameConstants.swift`: game sizes, speeds, colors, scoring, and tuning values.
- `SpaceInvadersLite/GameTypes.swift`: shared game state, phase enum, and node/category names.
- `AGENT_WORKFLOW.md`: recommended terminal-agent plus Xcode workflow.
- `QA_CHECKLIST.md`: simulator and physical-device manual QA checklist.

## How to open in Xcode
1. From this directory, generate the project if needed:
   ```sh
   xcodegen generate
   ```
2. Open `SpaceInvadersLite.xcodeproj` in Xcode.
3. Use the Project Navigator on the left to inspect Swift files under the `SpaceInvadersLite` group.
4. Select `SpaceInvadersLite` in the toolbar scheme selector.

## How to run on iPhone 13 mini simulator
1. Open `SpaceInvadersLite.xcodeproj` in Xcode.
2. In the toolbar device selector, choose `iPhone 13 mini`.
3. Press Run.
4. If `iPhone 13 mini` is missing, open `Window > Devices and Simulators`, select `Simulators`, press `+`, and create an iPhone 13 mini simulator for an installed iOS runtime.
5. If the simulator behaves strangely, choose `Device > Erase All Content and Settings` from the Simulator app, then run again.

Terminal build command:

```sh
xcodebuild -project SpaceInvadersLite.xcodeproj -scheme SpaceInvadersLite -destination 'platform=iOS Simulator,name=iPhone 13 mini' build
```

## How to run on physical iPhone 13 mini
1. Connect the iPhone by USB, or use wireless debugging if it is already configured.
2. In Xcode, select the physical iPhone from the toolbar device selector.
3. Select the project, then the `SpaceInvadersLite` target, then `Signing & Capabilities`.
4. Enable `Automatically manage signing`.
5. Choose your Apple Developer Team.
6. If Xcode reports a bundle identifier conflict, change `com.keigoshimada.SpaceInvadersLite` to a unique identifier.
7. Press Run.
8. If iPhone blocks the app, enable Developer Mode and trust the developer certificate in Settings when prompted.

## How to use this project with Claude Code / Codex
- "Inspect this Xcode project and explain the structure."
- "Add bullet shooting with minimal changes."
- "Fix this Xcode build error. Do not refactor unrelated code."
- "Explain what this SpriteKit lifecycle method does."
- "Make the game run better on iPhone 13 mini screen size."

Use Xcode as the source of truth for build and runtime behavior. Paste exact file paths, line numbers, and build errors back to the agent when something fails.

## Common Xcode errors
- Signing team missing: select the app target, open `Signing & Capabilities`, enable automatic signing, and choose your team.
- Simulator unavailable: install or create the simulator in `Window > Devices and Simulators`.
- Build folder weirdness: use `Product > Clean Build Folder`, then build again.
- Developer Mode not enabled on iPhone: enable Developer Mode in iPhone Settings and restart the device if requested.
- Trust developer certificate: on iPhone, open Settings and trust the developer app certificate when prompted.
- Bundle identifier conflict: change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`, regenerate with `xcodegen generate`, then build again.

## Next learning extensions
- Add sound effects.
- Add alien bullets.
- Add levels.
- Add a pause button.
- Add a simple menu.
- Save high score with `UserDefaults`.
- Add haptics.
