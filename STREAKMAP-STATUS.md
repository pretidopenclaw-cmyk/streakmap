# Streakmap — Current Status

## What is done
- SwiftUI MVP foundation created
- Real Xcode project file added
- Basic app structure in place
- Onboarding screen
- Home screen
- Global heatmap based on daily completion percentage
- Habit-specific binary heatmap
- Habits screen
- Insights screen
- Settings screen
- Add habit flow
- Premium mock paywall
- Habit detail screen
- Day detail and note editing flow
- Local persistence via UserDefaults JSON layer
- SwiftData-ready model layer added
- SwiftData container bootstrap wired at app level
- StoreKit-ready premium service scaffold added
- Info.plist and asset catalogs scaffolded

## Current blocker on this machine
CLI build cannot run because `xcodebuild` is currently pointed at Command Line Tools instead of full Xcode:

```bash
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

## Fix on host machine
Run:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Then build with:

```bash
xcodebuild -project Streakmap.xcodeproj -scheme Streakmap -sdk iphonesimulator -configuration Debug build
```

## Recommended next dev steps
1. Build and fix any compile issues in Xcode
2. Cut AppState reads/writes over from JSON arrays to SwiftData-backed queries
3. Connect StoreKit 2 real product purchase flow and entitlement restore
4. Wire scheduled notifications per habit
5. Polish animations, transitions, and haptics
6. Add app icon and brand assets
7. Add widgets
8. Add localization FR/EN pass
9. Final compile and runtime QA in Xcode
