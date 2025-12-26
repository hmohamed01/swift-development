# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is a **Claude Code skill** (`swift-development`) that provides comprehensive Swift/iOS/macOS development expertise. It gets loaded into Claude's context when the user invokes the skill for Swift-related tasks.

## Structure

```
swift-development/
├── SKILL.md              # Main skill definition (quick patterns, workflows)
├── references/           # Deep-dive documentation
│   ├── architecture.md   # MVVM, Observable, Core Data, SwiftData patterns
│   ├── spm.md           # Swift Package Manager
│   ├── xcodebuild.md    # Build commands
│   ├── simctl.md        # Simulator control
│   ├── code-signing.md  # Provisioning and signing
│   ├── concurrency.md   # Swift 6 async/await, actors, Sendable
│   ├── cicd.md          # CI/CD setup
│   └── troubleshooting.md
├── scripts/              # Helper shell scripts
│   ├── new_package.sh   # Create new Swift package with config
│   ├── run_tests.sh     # Run tests with common options
│   ├── format_and_lint.sh
│   └── simulator.sh     # Quick simulator management
└── assets/               # Templates and config files
    ├── Package.swift.template
    ├── .swiftformat
    ├── .swiftlint.yml
    └── ExportOptions/    # Export plist templates for archives
```

## Editing Guidelines

- **SKILL.md** contains the most commonly needed patterns - keep it concise and scannable
- **references/** are for detailed documentation on specific topics - include full examples
- **scripts/** should remain portable shell scripts that work without dependencies
- Maintain the table format for quick reference sections in SKILL.md
- Code examples should target iOS 15+/macOS 13+ minimum (Swift 5.10), with iOS 17+ noted for Observable/SwiftData

## Testing Changes

Since this is documentation, test by invoking `/swift-development` in Claude Code and verifying the skill loads correctly with expected content.
