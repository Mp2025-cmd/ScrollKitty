# ScrollKitty

ScrollKitty is an iOS app built on Apple Screen Time APIs (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) that adds a “cat health” mechanic to help you slow down on selected apps.

## What it does

- Lets the user pick “problem apps” during onboarding (stored as a `FamilyActivitySelection`).
- Applies shields to the selected apps/categories.
- When a shield is shown, the **Shield UI** offers:
  - **Step back** → closes the app.
  - **Go in anyway** → sends a local notification that opens ScrollKitty to a **bottom-sheet bypass flow**.
- The bypass sheet guides the user through a short, single-screen flow (message → time selection → acknowledgment) and, if granted, removes shields for a cooldown window.
- Tracks events (e.g. shield bypasses) in the shared app group so the History/Timeline can render a day-by-day log.

## Architecture

- State management: **The Composable Architecture (TCA)**.
- Shared state across app + extensions: **App Group `UserDefaults`** (`group.com.scrollkitty.app`).
- Messaging: deterministic health bands + prewritten templates (no network/AI required).

## Targets / Extensions

- `ScrollKitty` (main app)
- `ScrollKittyMonitor` (DeviceActivity monitor extension)
- `ScrollKittyShield` (Shield configuration UI: `ShieldConfigurationDataSource`)
- `ScrollKittyAction` (Shield button handling: `ShieldActionDelegate`)
- `ScrollKittyReport` (DeviceActivity report extension)

## Key shared storage (App Group)

Stored in `UserDefaults(suiteName: "group.com.scrollkitty.app")`:

- `selectedApps` (`FamilyActivitySelection` encoded as `Data`)
- `catHealth` (`Int`, 0–100)
- `shieldState` (`String`, drives shield UI state)
- `selectedBypassMinutes` (`Int`)
- `timelineEvents` (`[TimelineEvent]` encoded as `Data`)

## DeviceActivity reporting (why a “hidden” view exists)

iOS Screen Time usage data is surfaced via `DeviceActivityReport` (a SwiftUI view). The app uses a hidden `DeviceActivityReport(.daily, filter: …)` to trigger the report pipeline while keeping the UI custom.

Note: Screen Time data can lag; expect delays before minutes/pickups appear.

## Running locally

1. Open `ScrollKitty.xcodeproj`.
2. Use an Apple developer team and enable required capabilities for the app + extensions:
   - Screen Time / Family Controls
   - App Groups (`group.com.scrollkitty.app`)
   - Notifications (for bypass flow handoff)
3. Build & run `ScrollKitty`, complete onboarding, and grant Screen Time authorization.

Some Screen Time APIs and data behave best on a real device.

## Dev tooling (optional)

- `tca-docc-mcp/`: a small MCP server that lets Cursor query TCA DocC directly. See `tca-docc-mcp/README.md`.

