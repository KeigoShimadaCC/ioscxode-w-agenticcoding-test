# E2E Test Report

## 2026-05-24

Validated the expanded standalone game on a booted iPhone 13 mini simulator with the iOS Simulator MCP.

Commands and tools used:
- `xcodebuild -project SpaceInvadersLite.xcodeproj -scheme SpaceInvadersLite -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/DerivedData build`
- `mcp__ios_simulator__.install_app`
- `mcp__ios_simulator__.launch_app` with `SPACE_INVADERS_E2E=1`
- `mcp__ios_simulator__.ui_tap`
- `mcp__ios_simulator__.ui_view`
- `mcp__ios_simulator__.screenshot`

Observed coverage:
- App installed and launched on simulator.
- E2E fixture showed wave 3 chaos state with boss signal, rift storm, gravity wells, mutations, orbit drones, colony state, overdrive, combo, and active bullets.
- Tap-to-fire triggered overdrive nova and advanced combat state.
- Rewind button reduced charges and spawned time echoes.
- Pause button froze gameplay and displayed the paused overlay; resume returned to play.
- Screenshot evidence was saved at `/private/tmp/spaceinvaderslite-e2e-final.png`.

Notes:
- Build succeeded. Xcode continued to print CoreSimulator service warnings during command-line builds, but the app installed, launched, and interacted correctly through the simulator MCP.
- `SPACE_INVADERS_E2E=1` is a local-only simulator fixture. Normal gameplay does not require network, server, API, account, or hosted services.
