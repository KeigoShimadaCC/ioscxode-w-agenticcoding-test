# Agent Workflow

This project is designed for a terminal agent plus Xcode loop. The agent edits files and runs command-line validation; Xcode remains the best authority for simulator, signing, and physical-device runtime behavior.

## 1. Start from the terminal
```sh
git status
xcodegen generate
xcodebuild -list -project SpaceInvadersLite.xcodeproj
```

Run the agent from the repository root so it can inspect the project, edit files, and keep changes reviewable.

## 2. Ask for a plan first
Useful prompt:

> Inspect this Xcode project and propose a small implementation plan. Do not edit files yet.

For a learning app, a clear plan prevents unrelated architecture and keeps each change easy to understand.

## 3. Implement one small slice at a time
Recommended order:
1. Compiling app shell.
2. Player node and horizontal drag.
3. Bullet shooting.
4. Alien grid and movement.
5. Bullet-alien collisions and score.
6. Lives, game over, and restart.
7. Simulator and physical-device deployment notes.

Useful prompts:

> Add bullet shooting with minimal changes.

> Add alien movement only. Keep the rest of the code unchanged.

> Explain what `update(_:)` does in this SpriteKit scene.

## 4. Use Xcode as build and runtime authority
Run the app from Xcode when checking actual touch behavior, simulator behavior, signing, or physical-device install. The terminal can run `xcodebuild`, but Xcode gives the clearest UI for scheme, destination, signing team, logs, and breakpoints.

## 5. Feed exact errors back to the agent
When Xcode fails, paste:
- the exact error text,
- file path,
- line number,
- selected scheme,
- selected destination.

Useful prompt:

> Fix this Xcode build error. Do not refactor unrelated code.

## 6. Keep changes reviewable
Use:

```sh
git status
git diff
```

Prefer small commits or checkpoints when experimenting. Avoid mixing gameplay, project settings, and documentation in one large change unless you are doing the first project creation pass.

## 7. Optional parallel workflow
For larger apps, separate branches or worktrees can help:
- one branch for gameplay,
- one branch for UI/HUD,
- one branch for docs.

For SpaceInvadersLite, sequential work is simpler and easier to learn from.
