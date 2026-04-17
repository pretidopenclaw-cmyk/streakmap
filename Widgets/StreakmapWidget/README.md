# Streakmap Widget Integration

This folder contains the first WidgetKit implementation for the primary Streakmap widget: the global rolling 365-day heatmap.

## Important
The Swift code is ready, but the widget target still needs to be added in Xcode on the MacBook because maintaining a full WidgetKit target and extension wiring by hand inside `project.pbxproj` is fragile without running Xcode's project editor.

## Recommended setup in Xcode
1. File > New > Target
2. Choose Widget Extension
3. Name it `StreakmapWidget`
4. Replace generated Swift file contents with `Widgets/StreakmapWidget/StreakmapWidget.swift`
5. Add the shared source files from `Streakmap/WidgetSupport/`
6. Ensure both app target and widget target can access the shared files
7. If needed, move widget snapshot storage to an App Group later for device-ready sharing

## Current widget scope
- Primary widget only
- Global rolling 365-day heatmap
- `systemMedium` and `systemLarge`
- Uses persisted snapshot built by the main app

## Next widget steps
- Add App Group shared storage for production-ready widget updates
- Add habit-specific widget family
- Add configuration intent to choose one habit
