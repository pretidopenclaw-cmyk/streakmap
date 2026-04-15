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
- Add habit flow
- Premium mock paywall
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
2. Add detailed habit screen and day detail sheet
3. Move persistence to SwiftData
4. Replace premium mock with StoreKit 2
5. Add notifications
6. Polish animations, transitions, and haptics
7. Add app icon and brand assets
