# SwiftData Migration Plan

## Goal
Replace the temporary UserDefaults JSON persistence layer with SwiftData once the project is compiling and running in Xcode.

## Current state
- `AppState` uses in-memory arrays backed by `PersistenceService`
- data survives app relaunches via JSON encoding
- this is good enough for rapid MVP iteration

## Target state
- `HabitRecord` and `HabitEntryRecord` become the source of truth
- `AppState` becomes a view-layer adapter over SwiftData queries and writes
- onboarding and premium flags can remain in `UserDefaults` initially or move into app settings model later

## Suggested migration steps
1. add SwiftData container in `StreakmapApp`
2. bootstrap import from existing JSON layer only if no SwiftData rows exist
3. replace array mutations with ModelContext writes
4. replace read helpers with SwiftData fetches
5. remove JSON persistence once verified

## Why staged migration
This reduces risk while the project is not yet build-tested locally.
