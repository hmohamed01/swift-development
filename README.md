# Swift Development Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|%20macOS-000000.svg?logo=apple)](https://developer.apple.com/swift/)
[![Swift](https://img.shields.io/badge/Swift-5.10+-F05138.svg?logo=swift&logoColor=white)](https://swift.org)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet.svg)](https://claude.ai/code)

A Claude Code skill for comprehensive Swift iOS/macOS development. Provides patterns, commands, and tooling for building, testing, and deploying Swift applications.

## Installation

Copy the skill to your Claude skills directory:

```bash
cp -r swift-development ~/.claude/skills/
```

Or manually create and copy:

```bash
mkdir -p ~/.claude/skills/swift-development
cp -r swift-development/* ~/.claude/skills/swift-development/
```

## Usage

Invoke the skill in Claude Code:

```
/swift-development
```

Or reference it naturally - Claude will activate the skill when working on Swift projects.

## What's Included

### Quick Patterns (SKILL.md)
- SwiftUI with Observable (iOS 17+) and ObservableObject (iOS 13+)
- Navigation patterns: NavigationStack (iOS 16+), NavigationView (iOS 13-15), coordinator pattern
- Swift 6 concurrency: async/await, actors, Sendable
- XCTest and Swift Testing frameworks (with expanded examples)
- Common xcodebuild and simctl commands

### Reference Documentation
| Topic | File |
|-------|------|
| Swift Package Manager | `references/spm.md` |
| xcodebuild commands | `references/xcodebuild.md` |
| Simulator control | `references/simctl.md` |
| Code signing | `references/code-signing.md` |
| Swift 6 concurrency | `references/concurrency.md` |
| Architecture patterns | `references/architecture.md` |
| CI/CD setup | `references/cicd.md` |
| Troubleshooting | `references/troubleshooting.md` |

### Helper Scripts
| Script | Purpose |
|--------|---------|
| `scripts/new_package.sh` | Create new Swift package with config files, version warnings, and naming guidance |
| `scripts/run_tests.sh` | Run tests with parallel execution and coverage (SPM or xcodebuild) |
| `scripts/format_and_lint.sh` | Format and lint Swift code (SwiftFormat, SwiftLint, swift-format) |
| `scripts/simulator.sh` | Quick simulator management (boot, install, launch, screenshots, etc.) |

**Features:**
- **Colored output**: All scripts use color-coded messages (green for steps, yellow for warnings, red for errors)
- **Smart validation**: `new_package.sh` provides comprehensive warnings for:
  - Swift/Xcode version compatibility (e.g., Swift 6.0 requires Xcode 16+)
  - Package naming conventions (PascalCase guidance)
  - Git repository nesting (suggests using submodules)
  - Missing tools (SwiftFormat/SwiftLint installation checks)
- **Robust error handling**: Prerequisite checks with helpful installation instructions
- **Styled success indicators**: Clear visual feedback when operations complete

### Asset Templates
- `assets/Package.swift.template` - Swift package template
- `assets/.swiftformat` - SwiftFormat configuration
- `assets/.swiftlint.yml` - SwiftLint configuration
- `assets/ExportOptions/` - Archive export plist templates (App Store, Ad Hoc, Development)

## Official Documentation

For authoritative reference, this skill points to Apple's official Swift documentation:

- **Swift Documentation**: https://developer.apple.com/documentation/swift
- **SwiftUI**: https://developer.apple.com/documentation/swiftui
- **Swift Concurrency**: https://developer.apple.com/documentation/swift/concurrency
- **Swift Testing**: https://developer.apple.com/documentation/testing

**Live Documentation Fetching**: The skill instructs Claude to use `WebFetch` to retrieve current documentation. Since Apple's documentation sites are JavaScript SPAs that cannot be fetched programmatically, the skill uses **GitHub-based sources** instead:

- **Swift Testing**: https://github.com/apple/swift-testing
- **Swift Evolution**: https://github.com/apple/swift-evolution/tree/main/proposals
- **Swift Compiler Docs**: https://github.com/apple/swift/tree/main/docs
- **Swift Async Algorithms**: https://github.com/apple/swift-async-algorithms

These sources provide accurate, up-to-date information on Swift language features, testing frameworks, and package APIs.

## Requirements

- macOS with Xcode 15+ (Xcode 16+ for Swift 6 features)
- Xcode Command Line Tools: `xcode-select --install`

## Quick Reference

```bash
# Build
swift build                    # Debug build
swift build -c release         # Release build

# Test
swift test                     # Run all tests
swift test --filter MyTest     # Run specific test

# Xcode project
xcodebuild -workspace App.xcworkspace -scheme App \
    -destination 'platform=iOS Simulator,name=iPhone 15' build

# Simulators
xcrun simctl list devices      # List devices
xcrun simctl boot "iPhone 15"  # Boot simulator
xcrun simctl install booted ./App.app  # Install app
```

## Acknowledgments

This skill was inspired by and builds upon [ios-swift-development](https://github.com/aj-geddes/useful-ai-prompts/tree/main/skills/ios-swift-development) by [@aj-geddes](https://github.com/aj-geddes). The original skill provided a foundation that was expanded with additional reference documentation, helper scripts, and asset templates.
