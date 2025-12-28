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

## SwiftUI Quick Patterns

### Observable ViewModel (iOS 17+)

```swift
import SwiftUI

@Observable
class ItemsViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await api.fetchItems()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct ItemsView: View {
    @State private var viewModel = ItemsViewModel()

    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
        .overlay { if viewModel.isLoading { ProgressView() } }
        .task { await viewModel.load() }
    }
}
```

### ObservableObject (iOS 13+)

```swift
class ViewModel: ObservableObject {
    @Published var data: [Item] = []
}

struct MyView: View {
    @StateObject private var viewModel = ViewModel()  // Own it
    // or
    @ObservedObject var viewModel: ViewModel          // Passed in
}
```

### Navigation (iOS 16+)

```swift
// NavigationStack with programmatic navigation
struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Item 1", value: 1)
                NavigationLink("Item 2", value: 2)
            }
            .navigationDestination(for: Int.self) { id in
                DetailView(id: id)
            }
        }
    }
}

// Navigation with typed paths
enum Route: Hashable {
    case detail(Int)
    case settings
}

struct AppView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .detail(let id):
                        DetailView(id: id)
                    case .settings:
                        SettingsView()
                    }
                }
        }
    }
}

// Programmatic navigation
Button("Go to Detail") {
    path.append(Route.detail(42))
}
```

### Navigation (iOS 13-15)

```swift
// NavigationView with NavigationLink
struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DetailView()) {
                    Text("Item 1")
                }
            }
            .navigationTitle("Items")
        }
    }
}
```

---

## Swift 6 Concurrency Essentials

### Sendable Types

```swift
// Value types are implicitly Sendable
struct User: Sendable { let id: UUID; let name: String }

// Classes must be final + immutable or @unchecked
final class Config: Sendable { let apiKey: String }
```

### Actors

```swift
actor DataStore {
    private var items: [Item] = []
    func add(_ item: Item) { items.append(item) }
    func getAll() -> [Item] { items }
}

let store = DataStore()
await store.add(item)
```

### MainActor

```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []

    func load() async {
        items = await api.fetch()  // UI update is safe
    }
}
```

### Concurrent Fetching

```swift
func loadDashboard() async throws -> Dashboard {
    async let user = fetchUser()
    async let posts = fetchPosts()
    async let stats = fetchStats()

    return try await Dashboard(user: user, posts: posts, stats: stats)
}
```

---

## Testing Patterns

### XCTest

```swift
import XCTest
@testable import MyModule

final class MyTests: XCTestCase {
    private var sut: MyService!

    override func setUp() {
        super.setUp()
        sut = MyService()
    }

    func testExample() throws {
        let result = sut.process("input")
        XCTAssertEqual(result, "expected")
    }

    func testAsync() async throws {
        let result = try await sut.fetchData()
        XCTAssertNotNil(result)
    }
}
```

### Swift Testing (Xcode 16+)

```swift
import Testing
@testable import MyModule

@Suite("Feature Tests")
struct FeatureTests {
    let service = MyService()  // Shared across tests in suite

    @Test("Basic calculation")
    func basicCalc() {
        #expect(Calculator().add(2, 3) == 5)
    }

    @Test("Parameterized", arguments: [1, 2, 3])
    func squares(value: Int) {
        #expect(value * value > 0)
    }

    @Test("Async operation")
    func asyncTest() async throws {
        let result = try await service.fetchData()
        #expect(result != nil)
    }

    @Test("Throwing function")
    func throwingTest() throws {
        #expect(throws: MyError.invalid) {
            try service.validate("invalid")
        }
    }

    @Test("Require precondition")
    func requireTest() throws {
        let config = try #require(loadConfig())  // Fails test if nil
        #expect(config.isValid)
    }
}

// Custom test with multiple expectations
@Test("Value in range")
func valueInRange() {
    let value = 42
    #expect(value > 40)
    #expect(value < 50)
}

// Test organization with tags
@Suite("User Service", .tags(.integration))
struct UserServiceTests {
    let service = UserService()

    @Test("Create user")
    func createUser() async throws {
        let user = try await service.createUser(name: "Test")
        #expect(user.id != nil)
    }
}

extension Tag {
    @Tag static var integration: Self
}
```

---

## Project Structure

### Swift Package
```
MyPackage/
├── Package.swift
├── Sources/MyPackage/
│   ├── Models/
│   ├── Services/
│   └── Utilities/
└── Tests/MyPackageTests/
```

### iOS App
```
MyApp/
├── MyApp.xcodeproj/
├── MyApp/
│   ├── App/
│   │   └── MyAppApp.swift
│   ├── Features/
│   │   ├── Home/
│   │   └── Settings/
│   ├── Core/
│   │   ├── Models/
│   │   └── Services/
│   └── Resources/
├── MyAppTests/
└── MyAppUITests/
```

---

## Official Documentation

For authoritative Swift language and framework reference, use Apple's official documentation:

| Resource | URL |
|----------|-----|
| Swift Documentation | https://developer.apple.com/documentation/swift |
| SwiftUI | https://developer.apple.com/documentation/swiftui |
| Swift Standard Library | https://developer.apple.com/documentation/swift/swift-standard-library |
| Swift Concurrency | https://developer.apple.com/documentation/swift/concurrency |
| Swift Testing | https://developer.apple.com/documentation/testing |

### When to Fetch Documentation

Use `WebFetch` to retrieve content from Apple's official documentation in these situations:

1. **API Details**: When you need exact method signatures, parameters, or return types for Swift or framework APIs
2. **Framework Features**: When implementing SwiftUI views, concurrency patterns, or other framework-specific features where accuracy matters
3. **Uncertainty**: When you're unsure about current Swift syntax, availability annotations, or deprecated APIs
4. **User Questions**: When the user asks about specific Swift APIs, protocols, or framework behavior

**How to fetch**: Use `WebFetch` with the appropriate base URL + the specific type or topic:
- For a type: `https://developer.apple.com/documentation/swift/array`
- For SwiftUI views: `https://developer.apple.com/documentation/swiftui/list`
- For protocols: `https://developer.apple.com/documentation/swift/sendable`

**Example prompt for WebFetch**: "Extract the initializers, properties, and key methods for this type"

---

## Reference Files

Detailed documentation for specific topics:

| Topic | File |
|-------|------|
| Swift Package Manager | [references/spm.md](references/spm.md) |
| xcodebuild commands | [references/xcodebuild.md](references/xcodebuild.md) |
| Simulator control | [references/simctl.md](references/simctl.md) |
| Code signing | [references/code-signing.md](references/code-signing.md) |
| Swift 6 concurrency | [references/concurrency.md](references/concurrency.md) |
| Architecture patterns | [references/architecture.md](references/architecture.md) |
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

## Best Practices

**DO:**
- Use SwiftUI + Observable/ObservableObject for UI
- Use async/await for all async operations
- Store secrets in Keychain, not UserDefaults
- Use `@MainActor` for UI-related code
- Test on real devices before release
- Enable strict concurrency checking

**DON'T:**
- Force unwrap without safety checks
- Block main thread with sync operations
- Store API keys in source code
- Ignore Swift 6 concurrency warnings
- Skip error handling
