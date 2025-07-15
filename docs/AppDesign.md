# Overview

RxSnippet is a macOS SwiftUI application that enables users to create and execute code templates from remote repositories. The app provides a comprehensive template management system with JavaScript execution capabilities.

## Core Features

- **Remote Repository Management**: Add and manage multiple remote template repositories
- **Template Execution**: Execute JavaScript-based templates with Swift-JavaScript bridge
- **Form-Based Input**: Dynamic form generation using JSON Schema
- **Step-by-Step Execution**: Visual execution flow similar to GitHub Actions
- **Persistent Storage**: Swift Data for local repository and template metadata

## Data Architecture

### Template Structure
Templates are structured as JSON objects with the following schema:

```json
[
  {
    "name": "Simple Strategy",
    "description": "A simple strategy for Argo Trading", 
    "category": "Simple",
    "path": "/simple",
    "type": "file", // "file" or "folder"
    "steps": [
      {
        "name": "Initialize",
        "description": "Setup the environment",
        "script": "initialize.js",
        "form": {} // JSON Schema for step input
      }
    ],
    "globalForm": {} // JSON Schema for template-wide input
  }
]
```

### Repository Integration
- **Template Rendering**: Uses `rxclips-core` (../rxclips-core) for template processing
- **Form Generation**: Uses `swift-jsonschema-form` (../swift-jsonschema-form) for dynamic forms
- **API Specification**: Template schema available at `https://spec.snippet.rxlab.app/api/spec/repository?content-type=json`

# Technical Architecture

## JavaScript Execution Engine

The app uses a custom JSEngine built on JavaScriptCore that provides:
- **Type-safe Swift-JavaScript communication**
- **Async function support with Promise-based results**
- **Automatic bridge generation using Swift macros**
- **Runtime error handling and logging**

### Engine Components
- `Engine.swift`: Main engine implementing JSExport protocol
- `JSEngine<Api>`: Generic JavaScript execution context
- `@JSBridge` / `@JSBridgeProtocol`: Macros for automatic bridge code generation

## Data Persistence

Uses Swift Data for storing:
- Remote repository configurations
- Template metadata and cache
- User preferences and settings
- Execution history and logs

## External Dependencies

- **rxclips-core** (`../rxclips-core`): Template processing and execution engine
- **swift-jsonschema-form** (`../swift-jsonschema-form`): Dynamic form generation from JSON Schema

Don't copy the code to this folder since they are installed through swift package and I only mention these repos just to let u know how to use them.

# User Experience Design

## Navigation Structure

### Primary Layout
- **NavigationSplitView**: Three-pane layout for optimal space utilization
  - **Sidebar**: Repository list with add/remove functionality
  - **Content**: Template browser with hierarchical navigation
  - **Detail**: Step execution view with real-time logs

### Repository Management

#### Adding Repositories
- **Access Points**: Menu bar menu + right-click context menu on sidebar
- **Sheet Interface**: Modal form with the following fields:
  - Repository URL (required)
  - Resolver type picker (currently HTTP only)
  - Optional display name and description
- **Validation**: URL format validation and connectivity testing
- **Persistence**: Automatic Swift Data entity creation upon successful addition

#### Repository Display
- **Sidebar List**: Shows all configured repositories with status indicators
- **Context Actions**: Right-click menu for edit/delete operations
- **Status Indicators**: Connection status, sync state, error conditions

## Template Browser

### Template List View
- **Implementation**: SwiftUI `Table` for optimal performance and sorting
- **Columns**: Name, Type, Category, Last Modified
- **Navigation Behavior**:
  - **Folders**: Double-click navigates to subfolder with breadcrumb trail
  - **Files**: Single-click selection, double-click opens execution view
- **Toolbar Elements**:
  - Back button for folder navigation
  - Refresh button for repository sync
  - Search/filter controls

### Hierarchical Navigation
- **Breadcrumb Trail**: Visual path indicator in toolbar
- **Back Navigation**: Dedicated back button with keyboard shortcut support
- **Deep Linking**: Support for direct navigation to specific template paths

## Template Execution View

### Layout Structure
- **HSplitView**: Horizontal split for step list and execution details
- **Step List (Left Pane)**:
  - Sequential step display with status indicators
  - Expandable sections for step details
  - Progress indicators for overall completion
- **Execution View (Right Pane)**:
  - Real-time log output with syntax highlighting
  - GitHub Actions-style execution flow
  - Collapsible log sections per step

### Execution Controls
- **Toolbar Elements**:
  - Run button (transforms to stop button during execution)
  - Step-by-step execution toggle
  - Clear logs action
  - Back to template browser button
- **Form Handling**:
  - Global form sheet for template-wide configuration
  - Step-specific form sheets triggered by JavaScript execution
  - Form validation with real-time feedback

### Status Management
- **Step States**:
  - `not_started`: Default state with play icon
  - `in_progress`: Animated spinner with progress indication
  - `completed`: Green checkmark with duration
  - `error`: Red X with error details
  - `skipped`: Gray dash for conditional steps
- **Visual Indicators**: Color-coded status with accessibility support

## Interaction Patterns

### Form Integration
- **Sheet Presentation**: Modal forms for user input collection
- **JSON Schema Rendering**: Dynamic form generation using swift-jsonschema-form
- **Validation**: Real-time validation with clear error messaging
- **Persistence**: Form data preserved during execution for retry scenarios

### Error Handling
- **Graceful Degradation**: Fallback UI for network/parsing errors
- **User Feedback**: Toast notifications for operation status
- **Recovery Options**: Retry mechanisms for failed operations
- **Debug Information**: Detailed error logs in developer mode
