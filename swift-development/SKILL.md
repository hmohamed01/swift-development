---
name: swift-development
description: >
  Comprehensive Swift development for building, testing, and deploying iOS/macOS applications.
  Use when Claude needs to: (1) Build Swift packages or Xcode projects from command line,
  (2) Run tests with XCTest or Swift Testing framework, (3) Manage iOS simulators with simctl,
  (4) Handle code signing, provisioning profiles, and app distribution, (5) Format or lint
  Swift code with SwiftFormat/SwiftLint, (6) Work with Swift Package Manager (SPM),
  (7) Implement Swift 6 concurrency patterns (async/await, actors, Sendable),
  (8) Create SwiftUI views with MVVM architecture, (9) Set up Core Data or SwiftData persistence,
  or any other Swift/iOS/macOS development tasks.
---

# Swift Development

## Prerequisites

- macOS with Xcode 15+ installed (Xcode 16+ for Swift 6)
- Xcode Command Line Tools: `xcode-select --install`
- Verify: `xcodebuild -version` and `swift --version`

## Quick Start

### New Swift Package

```bash
# Use the included script for full setup
./scripts/new_package.sh MyLibrary --type library --ios --macos

# Or manually
swift package init --type library --name MyLibrary
```

### Build and Test

```bash
# SPM packages
swift build
swift test

# Xcode projects
xcodebuild -workspace App.xcworkspace -scheme App \
    -destination 'platform=iOS Simulator,name=iPhone 15' build

# Use included script for common options
./scripts/run_tests.sh --parallel --coverage
```

### Format and Lint

```bash
# Use included script
./scripts/format_and_lint.sh Sources/

# Check mode (CI)
./scripts/format_and_lint.sh --check
```

### Simulator Management

```bash
# Use included script
./scripts/simulator.sh list
./scripts/simulator.sh boot "iPhone 15"
./scripts/simulator.sh screenshot
./scripts/simulator.sh dark
```

---

## Core Workflows

### Building iOS Apps

```bash
# Debug build for simulator
xcodebuild -workspace App.xcworkspace -scheme App \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    build

# Release archive
xcodebuild archive \
    -workspace App.xcworkspace -scheme App \
    -archivePath ./build/App.xcarchive \
    -configuration Release

# Export IPA (use templates from assets/ExportOptions/)
xcodebuild -exportArchive \
    -archivePath ./build/App.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist assets/ExportOptions/app-store.plist
```

### Testing

```bash
# All tests
xcodebuild test -workspace App.xcworkspace -scheme App \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Specific test
xcodebuild test -only-testing:AppTests/MyTestClass/testMethod

# With coverage
xcodebuild test -enableCodeCoverage YES \
    -resultBundlePath ./TestResults.xcresult
```

### App Installation

```bash
# Install on booted simulator
xcrun simctl install booted ./Build/Products/Debug-iphonesimulator/App.app

# Launch
xcrun simctl launch booted com.company.app
```

---

## Official Documentation

### Reference Links (for humans)

These are Apple's official documentation links for manual browsing:

| Resource | URL |
|----------|-----|
| Swift Documentation | https://developer.apple.com/documentation/swift |
| SwiftUI | https://developer.apple.com/documentation/swiftui |
| Swift Concurrency | https://developer.apple.com/documentation/swift/concurrency |
| Swift Testing | https://developer.apple.com/documentation/testing |

> **Note**: Apple's documentation sites are JavaScript SPAs and cannot be fetched programmatically with WebFetch. Use GitHub-based sources below instead.

### WebFetch-Compatible Sources (Raw GitHub URLs)

Always use `raw.githubusercontent.com` URLs — regular `github.com` URLs return garbled HTML/JSON.

Base URL prefix: `https://raw.githubusercontent.com/apple`

**Swift Testing** (`/swift-testing/main/`):

| Resource | Path |
|----------|------|
| README | `README.md` |
| Defining Tests | `Sources/Testing/Testing.docc/DefiningTests.md` |
| Organizing Tests | `Sources/Testing/Testing.docc/OrganizingTests.md` |
| Expectations | `Sources/Testing/Testing.docc/Expectations.md` |
| Parameterized Testing | `Sources/Testing/Testing.docc/ParameterizedTesting.md` |
| Traits Overview | `Sources/Testing/Testing.docc/Traits.md` |
| Trait Reference | `Sources/Testing/Testing.docc/Traits/Trait.md` |
| Adding Tags | `Sources/Testing/Testing.docc/AddingTags.md` |
| Adding Comments | `Sources/Testing/Testing.docc/AddingComments.md` |
| Associating Bugs | `Sources/Testing/Testing.docc/AssociatingBugs.md` |
| Bug Identifiers | `Sources/Testing/Testing.docc/BugIdentifiers.md` |
| Attachments | `Sources/Testing/Testing.docc/Attachments.md` |
| Enabling/Disabling Tests | `Sources/Testing/Testing.docc/EnablingAndDisabling.md` |
| Limiting Execution Time | `Sources/Testing/Testing.docc/LimitingExecutionTime.md` |
| Parallelization | `Sources/Testing/Testing.docc/Parallelization.md` |
| Exit Testing | `Sources/Testing/Testing.docc/exit-testing.md` |
| Known Issues | `Sources/Testing/Testing.docc/known-issues.md` |
| Testing Async Code | `Sources/Testing/Testing.docc/testing-asynchronous-code.md` |
| Testing for Errors | `Sources/Testing/Testing.docc/testing-for-errors-in-swift-code.md` |
| Migrating from XCTest | `Sources/Testing/Testing.docc/MigratingFromXCTest.md` |
| Vision & Design | `Documentation/Vision.md` |
| CLI Debugging | `Documentation/CommandlineDebugging.md` |
| Environment Variables | `Documentation/EnvironmentVariables.md` |

**Other Swift Packages**:

| Resource | Full Raw URL |
|----------|-------------|
| Swift Async Algorithms | `https://raw.githubusercontent.com/apple/swift-async-algorithms/main/README.md` |
| Swift Collections | `https://raw.githubusercontent.com/apple/swift-collections/main/README.md` |

**For Swift Evolution proposals**, construct the raw URL from the proposal number:
`https://raw.githubusercontent.com/apple/swift-evolution/main/proposals/NNNN-proposal-name.md`

Example: `https://raw.githubusercontent.com/apple/swift-evolution/main/proposals/0409-access-level-on-imports.md`

**For directory discovery** (finding proposal numbers, doc file names): use `WebSearch` instead of `WebFetch` — directory listings on GitHub are not parseable.

### When to Fetch Documentation

Use `WebFetch` with raw GitHub URLs in these situations:

1. **Swift Testing**: When you need details on `@Test`, `#expect`, `#require`, traits, or parameterized tests
2. **Swift Evolution**: When checking accepted proposals for new language features
3. **Framework Details**: When implementing features from Apple's open-source Swift packages
4. **Uncertainty**: When you're unsure about current API patterns or best practices

**URL conversion rule**: Replace `github.com/{owner}/{repo}/blob/{branch}/` with `raw.githubusercontent.com/{owner}/{repo}/{branch}/`

**Fallback**: If `WebFetch` fails on a raw URL, use `WebSearch` with the query `site:github.com/apple {topic}` to discover the correct file path, then construct the raw URL.

**Example prompt for WebFetch**: "Extract the main features, macros, and usage examples from this documentation"

---

## Reference Files

Detailed documentation for specific topics:

| Topic | File |
|-------|------|
| SwiftUI patterns | [references/swiftui-patterns.md](references/swiftui-patterns.md) |
| Testing patterns | [references/testing-patterns.md](references/testing-patterns.md) |
| Swift 6 concurrency | [references/concurrency.md](references/concurrency.md) |
| Architecture patterns | [references/architecture.md](references/architecture.md) |
| Best practices | [references/best-practices.md](references/best-practices.md) |
| Swift Package Manager | [references/spm.md](references/spm.md) |
| xcodebuild commands | [references/xcodebuild.md](references/xcodebuild.md) |
| Simulator control | [references/simctl.md](references/simctl.md) |
| Code signing | [references/code-signing.md](references/code-signing.md) |
| CI/CD setup | [references/cicd.md](references/cicd.md) |
| Troubleshooting | [references/troubleshooting.md](references/troubleshooting.md) |

---

## Included Scripts

| Script | Purpose |
|--------|---------|
| `scripts/new_package.sh` | Create new Swift package with config files |
| `scripts/run_tests.sh` | Run tests with common options |
| `scripts/format_and_lint.sh` | Format and lint Swift code |
| `scripts/simulator.sh` | Quick simulator management |

---

## Asset Templates

| Asset | Purpose |
|-------|---------|
| `assets/Package.swift.template` | Swift package template |
| `assets/.swiftformat` | SwiftFormat configuration |
| `assets/.swiftlint.yml` | SwiftLint configuration |
| `assets/ExportOptions/` | Archive export plist templates |

---

## Quick Reference

### Essential Commands

| Task | Command |
|------|---------|
| Build package | `swift build` |
| Build release | `swift build -c release` |
| Run tests | `swift test` |
| Update deps | `swift package update` |
| List simulators | `xcrun simctl list devices` |
| Boot simulator | `xcrun simctl boot "iPhone 15"` |
| Install app | `xcrun simctl install booted ./App.app` |
| Format code | `swiftformat .` |
| Lint code | `swiftlint` |

### Common Destinations

```bash
# iOS Simulator
-destination 'platform=iOS Simulator,name=iPhone 15'

# macOS
-destination 'platform=macOS'

# Generic iOS (for archives)
-destination 'generic/platform=iOS'
```

---
