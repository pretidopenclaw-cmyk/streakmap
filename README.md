# Streakmap

Temporary project name for a premium iOS habit tracker centered on beautiful heatmap visualizations.

## Current status
This repository currently contains a SwiftUI MVP foundation with:
- onboarding screen
- Home screen
- global heatmap based on daily completion percentage
- habit-focused binary heatmap
- habits tab
- insights tab
- add habit flow
- premium paywall screen
- local sample state for fast prototyping
- haptics / reminder service stubs

## Recommended next steps
1. Wrap the source into a real Xcode iOS App target
2. Move models to SwiftData
3. Replace premium mock with StoreKit 2
4. Persist onboarding and premium state
5. Wire local notifications
6. Add detailed habit screen and day detail modal
7. Add polished animations and haptics pass
8. Add widgets

## Notes
The product strategy and V1 user stories live in:
- `../HABIT-HEATMAP-V1-USER-STORIES.md`
