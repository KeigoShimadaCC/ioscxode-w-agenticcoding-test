
You are an expert iOS engineer and agentic-coding workflow coach.

Your task is to create a very small native iPhone app called `SpaceInvadersLite` so that I can learn:

1. How Xcode projects are structured.
2. How SwiftUI app lifecycle works.
3. How SpriteKit works for simple 2D games.
4. How to use an agentic coding workflow for iOS.
5. How to run the app on the iPhone 13 mini simulator.
6. How to run the app on my physical iPhone 13 mini.
7. How to debug build/signing/runtime issues through Xcode.

This is a learning project, not a production app.

The final app should be a tiny Space Invaders-style game:
- Player ship at the bottom.
- Drag horizontally to move.
- Tap to shoot.
- Aliens move left/right and step downward.
- Bullets destroy aliens.
- Score increases.
- Lives decrease if aliens reach the bottom.
- Game over screen.
- Restart button.

No App Store publishing is needed.
No TestFlight is needed.
No backend is needed.
No analytics.
No ads.
No external dependencies.
No complicated architecture.
No image assets unless absolutely necessary.
Use simple geometric shapes.

The final goal is: I can open the project in Xcode, select iPhone 13 mini simulator or my physical iPhone 13 mini, press Run, and play the app.

⸻

0. Operating Mode
Work in a careful agentic coding style.

Do NOT immediately start dumping code without first inspecting or creating a clean project plan.

Your workflow must be:

1. PLAN
2. CREATE / MODIFY FILES
3. BUILD / TEST
4. FIX ERRORS
5. DOCUMENT
6. FINAL SUMMARY

At each major step, explain briefly:
- what you are doing,
- why it matters for iOS/Xcode,
- what command or Xcode action I should run next.

Prefer concrete commands and file paths over vague explanations.

If using Claude Code / Codex:
- Inspect the current directory first.
- If no project exists, create one cleanly.
- Do not overwrite unrelated files.
- Use git-friendly changes.
- Keep commits optional; do not commit unless explicitly asked.

If there is ambiguity, choose the simplest native iOS path that works in Xcode.

⸻

1. Project Creation Strategy
Create a native iOS app project named:

SpaceInvadersLite

Preferred implementation:

- Swift
- SwiftUI app lifecycle
- SpriteKit for the game scene
- SpriteView to embed SpriteKit in SwiftUI
- Minimum iOS target: iOS 17.0 or later, unless the local Xcode default suggests otherwise
- Device target: iPhone
- No iPad-specific work required
- No macOS Catalyst
- No watchOS
- No widgets
- No external packages

If you can create a valid `.xcodeproj` programmatically, do so.

If creating `.xcodeproj` directly is unreliable in the terminal environment, use one of these approaches:

Option A:
- Create the source files and a clear README explaining how to create the Xcode project manually and add the files.

Option B:
- Use XcodeGen only if it is already installed or trivially installable.
- Do not add unnecessary tooling just for elegance.

Option C:
- If the environment has Xcode command-line tools and project creation utilities available, use them.

The preferred final structure is:

SpaceInvadersLite/
  README.md
  SpaceInvadersLite.xcodeproj/
  SpaceInvadersLite/
    SpaceInvadersLiteApp.swift
    ContentView.swift
    GameScene.swift
    GameHUD.swift
    GameConstants.swift
    GameTypes.swift
  SpaceInvadersLiteTests/        optional
  SpaceInvadersLiteUITests/      optional

If the test targets are too much overhead for a first learning project, skip them and instead include a manual QA checklist.

⸻

2. Technical Requirements
Implement the app with SwiftUI + SpriteKit.

Core files:

1. `SpaceInvadersLiteApp.swift`
   - SwiftUI app entry point.
   - Loads `ContentView`.

2. `ContentView.swift`
   - Creates and displays the SpriteKit scene using `SpriteView`.
   - Shows simple overlay UI:
     - score
     - lives
     - game status
     - restart button
   - Uses SwiftUI state or observable object to reflect game state.

3. `GameScene.swift`
   - Subclass `SKScene`.
   - Owns the actual game loop and SpriteKit nodes.
   - Implements:
     - player creation
     - alien grid creation
     - bullet creation
     - movement
     - collision handling
     - score updates
     - lives/game-over logic
     - restart/reset logic

4. `GameHUD.swift`
   - Optional.
   - Extract reusable HUD view if helpful.

5. `GameConstants.swift`
   - Store game constants:
     - player size
     - bullet speed
     - alien rows/columns
     - alien spacing
     - alien movement speed
     - initial lives
     - colors
     - collision categories

6. `GameTypes.swift`
   - Optional.
   - Store simple enums/types:
     - GamePhase
     - PhysicsCategory

⸻

3. Game Design Requirements
Keep the game intentionally simple.

Screen:
- Portrait orientation.
- Designed for iPhone 13 mini size.
- Should also work reasonably on other iPhone simulators.
- Background black or very dark.
- Player at bottom center.
- Aliens in grid near top.
- Bullets travel upward.

Player:
- Simple green rectangle or triangle.
- Positioned near bottom.
- Moves horizontally only.
- User drags finger horizontally to move.
- Clamp movement to screen bounds.

Shooting:
- User taps to shoot.
- Bullet spawns from player.
- Bullet moves upward.
- Limit firing rate so tapping does not create infinite bullets.
- Remove bullets when offscreen.

Aliens:
- Simple red/purple/yellow rectangles or circles.
- Start in a grid.
- Move horizontally as a group.
- When group hits left/right edge, reverse direction and move downward.
- If an alien reaches near the player/bottom zone:
  - lose one life,
  - reset alien grid,
  - if lives reach zero, game over.

Collisions:
- Bullet hitting alien:
  - remove bullet
  - remove alien
  - score += 10
- If all aliens are destroyed:
  - spawn a new wave
  - optionally increase speed slightly

Game state:
- Initial lives: 3
- Initial score: 0
- Game over when lives == 0
- Restart resets score, lives, aliens, bullets, player position

Controls:
- Drag horizontally to move.
- Tap to shoot.
- Restart button in SwiftUI overlay.

⸻

4. SpriteKit Implementation Details
Use SpriteKit idiomatically but keep it beginner-readable.

In `GameScene.swift`, include comments explaining these lifecycle methods:

- `didMove(to:)`
  - Called when the scene is presented.
  - Good place to set up physics world and initial nodes.

- `update(_ currentTime:)`
  - Called every frame.
  - Good place to move aliens, bullets, and check game conditions.

- `touchesMoved(_:with:)`
  - Used for dragging the player.

- `touchesEnded(_:with:)`
  - Used for shooting.

- `didBegin(_ contact:)`
  - Used for physics collision handling if using `SKPhysicsContactDelegate`.

Physics:
- Use `SKPhysicsBody` and contact categories if reasonably simple.
- Define bit masks for:
  - player
  - bullet
  - alien
  - bottom/death zone if needed

If physics contact handling becomes too much for a first version, use manual rectangle intersection checks in `update`.
But prefer SpriteKit physics if implementation remains readable.

Important:
- Avoid overengineering.
- Avoid ECS.
- Avoid complex scene architecture.
- Avoid texture atlases.
- Avoid custom asset pipelines.

⸻

5. SwiftUI Integration Requirements
Use SwiftUI only for app shell and HUD.

`ContentView` should:

- Create a `GameScene`.
- Present it with `SpriteView(scene:)`.
- Overlay score/lives/game-over UI.
- Provide a restart button that calls into the scene or resets state.

State synchronization:

Use one of these simple patterns:

Option A: ObservableObject game model
- `GameState: ObservableObject`
- Scene receives a reference to `GameState`
- Scene updates `@Published` score/lives/phase
- SwiftUI observes and renders HUD

Option B: Callback closures
- Scene exposes callbacks:
  - onScoreChanged
  - onLivesChanged
  - onGameOver
- ContentView updates `@State`

Prefer Option A because it is easier to explain and inspect.

Example conceptual shape:

class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var phase: GamePhase = .playing

    func reset() { ... }
}

Do not use Combine beyond basic `ObservableObject` / `@Published`.

⸻

6. Code Quality Requirements
The code should be:

- Small
- Readable
- Beginner-friendly
- Native Swift
- Xcode-friendly
- Commented where it teaches Xcode/SpriteKit concepts

Avoid:
- clever abstractions
- generic engines
- unnecessary protocols
- dependency injection frameworks
- async networking
- persistence
- CoreData/SwiftData
- external packages
- image assets
- sound effects unless trivial
- complex menus
- monetization
- App Store metadata

⸻

7. Xcode Capability Learning Goals
The README must teach me the following Xcode capabilities:

1. Opening the project
   - Open `.xcodeproj` in Xcode.
   - Explain what the project navigator is.
   - Explain where Swift files live.

2. Running in simulator
   - Select iPhone 13 mini simulator.
   - Press Run.
   - What to do if iPhone 13 mini simulator is not installed.
   - How to open Devices and Simulators.

3. Running on physical iPhone 13 mini
   - Connect iPhone by USB or use wireless debugging if already configured.
   - Select the physical device from Xcode toolbar.
   - Set Team under Signing & Capabilities.
   - Enable Automatically manage signing.
   - Trust developer certificate on iPhone if needed.
   - Press Run.

4. Debugging
   - Where the console is.
   - How to set a breakpoint.
   - How to read build errors.
   - How to clean build folder.
   - How to reset simulator if needed.

5. Agentic coding loop
   - Ask agent to implement feature.
   - Run build.
   - Paste build errors back to agent.
   - Let agent fix.
   - Repeat.
   - Review diff.

⸻

8. Agentic Workflow Requirements
This project is specifically for learning agentic iOS coding.

Create a file:

AGENT_WORKFLOW.md

It should explain a recommended workflow for this exact project:

1. Start from terminal:
   - `git init`
   - create or inspect project
   - run agent in repo root

2. Ask agent for a plan first:
   - no code edits until plan is clear

3. Let agent implement a small slice:
   - first compiling app
   - then player movement
   - then shooting
   - then aliens
   - then collision
   - then HUD/restart
   - then device deployment

4. Use Xcode as the build/runtime authority:
   - run simulator from Xcode
   - inspect errors
   - test on iPhone

5. Feed errors back to the agent:
   - paste exact build errors
   - paste file path and line number
   - ask for minimal fix

6. Keep changes reviewable:
   - use git status
   - use git diff
   - avoid giant unrelated changes

7. Optional parallel workflow:
   - one branch/worktree for gameplay
   - one branch/worktree for UI/HUD
   - one branch/worktree for docs
   - but for this tiny app, sequential is better

Include example prompts I can use, such as:

- "Inspect this Xcode project and explain the structure."
- "Add bullet shooting with minimal changes."
- "Fix this Xcode build error. Do not refactor unrelated code."
- "Explain what this SpriteKit lifecycle method does."
- "Make the game run better on iPhone 13 mini screen size."

⸻

9. Build and Validation Requirements
After implementation, attempt to validate as much as possible from terminal.

Try commands such as:

- `xcodebuild -list`
- `xcodebuild -scheme SpaceInvadersLite -destination 'platform=iOS Simulator,name=iPhone 13 mini' build`

If the exact simulator is unavailable, list available destinations and explain how to select one.

Do not pretend the build passed if it did not.

If terminal build cannot be run because of environment limitations, say exactly why and provide Xcode manual build instructions.

The final answer must include:

- whether files were created,
- whether project opens in Xcode,
- whether terminal build was attempted,
- whether simulator build passed,
- remaining manual steps for me,
- known limitations.

⸻

10. Manual QA Checklist
Create `QA_CHECKLIST.md`.

Include checkboxes:

Simulator:
- [ ] Project opens in Xcode
- [ ] iPhone 13 mini simulator is selectable
- [ ] App launches
- [ ] Player appears
- [ ] Drag moves player horizontally
- [ ] Tap shoots bullet
- [ ] Aliens appear
- [ ] Aliens move left/right
- [ ] Aliens step down at edges
- [ ] Bullet destroys alien
- [ ] Score increases
- [ ] Lives decrease when aliens reach bottom
- [ ] Game over appears at 0 lives
- [ ] Restart works

Physical iPhone:
- [ ] iPhone 13 mini appears in Xcode device selector
- [ ] Signing team is selected
- [ ] App installs on device
- [ ] App launches on device
- [ ] Touch controls feel usable
- [ ] Game fits screen
- [ ] No severe frame drops

⸻

11. README Requirements
Create a clear `README.md` with these sections:

# SpaceInvadersLite

## Goal
Explain this is a tiny learning app for Xcode, SwiftUI, SpriteKit, and agentic iOS coding.

## What the app does
Bullet list of gameplay.

## Project structure
Explain each file.

## How to open in Xcode
Step-by-step.

## How to run on iPhone 13 mini simulator
Step-by-step.

## How to run on physical iPhone 13 mini
Step-by-step.

## How to use this project with Claude Code / Codex
Include example agent prompts.

## Common Xcode errors
Include fixes for:
- Signing team missing
- Simulator unavailable
- Build folder weirdness
- Developer mode not enabled on iPhone
- Trust developer certificate
- Bundle identifier conflict

## Next learning extensions
List small optional next tasks:
- add sound
- add alien bullets
- add levels
- add pause button
- add simple menu
- add high score with UserDefaults
- add haptics

⸻

12. Learning-Oriented Comments
Add comments in code where useful.

Do not comment every line.

Comment concepts that matter for learning:

- Why `@main` starts the app.
- Why `SpriteView` embeds SpriteKit in SwiftUI.
- Why `SKScene` has a frame loop.
- Why nodes are added to the scene.
- Why physics categories are bit masks.
- Why screen bounds matter on iPhone 13 mini.
- Why game state is shared with SwiftUI.

⸻

13. Acceptance Criteria
The project is complete when:

1. The app has a valid native iOS structure.
2. It opens in Xcode.
3. It builds or has clear documented manual steps if terminal build is not possible.
4. The game is playable at a basic level.
5. The player can move.
6. The player can shoot.
7. Aliens move.
8. Bullets can destroy aliens.
9. Score updates.
10. Lives/game-over/restart exist.
11. README explains Xcode usage.
12. AGENT_WORKFLOW.md explains terminal-agent + Xcode workflow.
13. QA_CHECKLIST.md exists.
14. No external dependencies are required.
15. No App Store/TestFlight/publishing steps are required.

⸻

14. Suggested Implementation Plan
Follow this implementation sequence.

Phase 1: Skeleton
- Create project structure.
- Add SwiftUI app entry.
- Add ContentView.
- Add empty GameScene.
- Confirm app launches with black SpriteKit scene.

Phase 2: Player
- Add player node.
- Position at bottom.
- Implement drag movement.
- Clamp to screen.

Phase 3: Shooting
- Add bullet nodes.
- Tap to shoot.
- Move bullets upward.
- Remove offscreen bullets.
- Add simple fire-rate limit.

Phase 4: Aliens
- Add alien grid.
- Move aliens horizontally.
- Reverse at screen edges.
- Step downward.

Phase 5: Collision and scoring
- Detect bullet-alien collisions.
- Remove hit aliens.
- Increment score.
- Spawn next wave when all aliens gone.

Phase 6: Lives and game over
- Detect aliens reaching bottom.
- Decrease lives.
- Reset wave.
- Game over at 0 lives.

Phase 7: SwiftUI HUD
- Show score.
- Show lives.
- Show game over.
- Add restart button.

Phase 8: Docs and QA
- Write README.
- Write AGENT_WORKFLOW.md.
- Write QA_CHECKLIST.md.
- Include exact Xcode run instructions.

Phase 9: Build validation
- Run xcodebuild if possible.
- If errors occur, fix them.
- If simulator unavailable, document manual Xcode validation.

⸻

15. Final Response Format
When done, respond with:

## Summary
Briefly explain what was built.

## Files created/modified
List files.

## How to run
Give exact steps:
1. Open Xcode.
2. Open project.
3. Select iPhone 13 mini simulator.
4. Press Run.

## How to run on physical iPhone 13 mini
Give exact steps.

## Validation status
State:
- terminal build attempted: yes/no
- result
- remaining manual checks

## Suggested next agent prompts
Give 5 prompts for the next learning iteration.

