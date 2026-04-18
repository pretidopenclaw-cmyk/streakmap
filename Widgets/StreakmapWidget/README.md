# Streakmap Widget Integration

This folder contains the first WidgetKit implementation for the primary Streakmap widget: the global rolling 365-day heatmap.

## Important
The Swift code is ready, but the widget target still needs to be added in Xcode on the MacBook because maintaining a full WidgetKit target and extension wiring by hand inside `project.pbxproj` is fragile without running Xcode's project editor.

## Recommended setup in Xcode
1. File > New > Target
2. Choose Widget Extension
3. Name it `StreakmapWidget`
4. Replace generated Swift file contents with `Widgets/StreakmapWidget/StreakmapWidget.swift`
5. Add `Widgets/StreakmapWidget/WidgetExtensionColor+Hex.swift` to the widget target
6. Add the shared source files from `Streakmap/WidgetSupport/` to both the app target and widget target:
   - `WidgetConfig.swift`
   - `WidgetEntryModels.swift`
   - `WidgetStorage.swift`
7. In **Signing & Capabilities**, enable **App Groups** on both targets with:
   - `group.ch.w5g.streakmap`
8. Use `Streakmap/WidgetSupport/WidgetAppGroupSetup.md` as the checklist

## Current widget scope
- Primary widget only
- Global rolling 365-day heatmap
- `systemMedium` and `systemLarge`
- Uses persisted snapshot built by the main app
- Uses App Group shared storage for app ↔ widget communication

## Next widget steps
- Validate the extension target wiring on device/simulator
- Add habit-specific widget family
- Add configuration intent to choose one habit
