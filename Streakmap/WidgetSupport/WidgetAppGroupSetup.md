# Widget App Group Setup

Use this App Group for shared widget data:

- `group.com.davidpreti.streakmap`

## In Xcode

### Main app target
- Signing & Capabilities
- Add **App Groups**
- Enable `group.com.davidpreti.streakmap`

### Widget extension target
- Signing & Capabilities
- Add **App Groups**
- Enable `group.com.davidpreti.streakmap`

## Why
The widget extension cannot reliably read `UserDefaults.standard` from the app sandbox. Shared snapshots must go through the same App Group container.
