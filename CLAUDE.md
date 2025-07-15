# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS SwiftUI application called "rxsnippet" that allows users to create and manage code snippets/templates from remote repositories. The app uses:

- **SwiftUI** for the user interface
- **Swift Data** for persistence

## Build and Test Commands

### Building the Project

```bash
# Build the project (use Xcode or xcodebuild)
xcodebuild -project rxsnippet.xcodeproj -scheme rxsnippet build

# Run the app
open rxsnippet.xcodeproj
```

### Testing

```bash
# Run all tests using the test plan
xcodebuild -project rxsnippet.xcodeproj -testPlan rxsnippet test

# Run specific test targets
xcodebuild -project rxsnippet.xcodeproj -scheme rxsnippet -only-testing:rxsnippetTests test
xcodebuild -project rxsnippet.xcodeproj -scheme rxsnippet -only-testing:JSEngineTests test
xcodebuild -project rxsnippet.xcodeproj -scheme rxsnippet -only-testing:JSEngineMacroTests test
```

## Architecture Automatically handles async function wrapping with Promise support

### Key Files Structure

- `rxsnippet/` - Main app source code
  - `rxsnippetApp.swift` - App entry point
  - `ContentView.swift` - Main UI view
  - `Engine.swift` - Core engine with JS bridge
  - `packages/` - Local Swift packages

### JavaScript Bridge System

The app uses a sophisticated macro-based system to bridge Swift and JavaScript:

1. **APIProtocol**: Base protocol for all JS-exportable APIs
2. **JSEngine**: Generic engine that executes JS code with Swift API handlers
3. **Macros**: Automatically generate JS bridge code for async Swift functions

### Template System Architecture

Based on the design document, the app is intended to:

- Manage remote template repositories
- Support template categorization and metadata
- Use JSON schema for form generation
- Integrate with external libraries (`rxclips-core`, `swift-jsonschema-form`)

## Development Notes

- Uses ViewModel to create logic and separate it from the UI.

Use this syntax to create a model

```swift
@Observable class Library {
    var books: [Book] = [Book(), Book(), Book()]

    var availableBooksCount: Int {
        books.filter(\.isAvailable).count
    }
}
```

And this syntax to initialize it

```swift
struct LibraryView: View {
    @Environment(Library.self) private var library

    var body: some View {
        NavigationStack {
            List(library.books) { book in
                // ...
            }
            .environment(library)
            .navigationTitle("Books available: \(library.availableBooksCount)")
        }
    }
}
```

And use it like this:

```swift
struct LibraryView: View {
    @Environment(\.library) private var library


    var body: some View {
        // ...
    }
}
```

### External Dependencies

The app depends on external libraries that should be located at:

- `../rxclips-core` - Core clipping functionality
- `../swift-jsonschema-form` - JSON schema form rendering
