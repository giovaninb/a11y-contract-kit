# A11yContractDemo

Interactive demo app for **A11yContractKit** with UIKit, SwiftUI, and live audit examples.

## Open in Xcode

```bash
cd Examples/A11yContractDemo
xcodegen generate   # if .xcodeproj is missing
open A11yContractDemo.xcodeproj
```

The repository includes a pre-generated `A11yContractDemo.xcodeproj`.

## Run

1. Select the **A11yContractDemo** scheme
2. Choose an iOS 15+ simulator
3. Run (⌘R)

## App tabs

| Tab | Description |
|-----|-------------|
| **Problems** | Buttons without labels, small touch targets, low contrast |
| **Fixed** | Same components with `applyA11y` |
| **SwiftUI** | `.a11yContract` modifier |
| **Audit** | Runs UIKit scanner and lists issues |

## Tests

```bash
xcodebuild test \
  -project A11yContractDemo.xcodeproj \
  -scheme A11yContractDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

Or in Xcode: ⌘U

## Local dependency

The demo references the A11yContractKit package at `../../` (repository root).
