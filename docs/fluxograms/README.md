# Daymark App Fluxograms Documentation

This directory contains comprehensive fluxograms that document the main workflows and system interactions in the Daymark habit tracking application.

## Available Fluxograms

### 1. Create New Habit Workflow
- **File**: `create_habit_workflow.md` / `create_habit_workflow.puml`
- **Description**: Documents the complete flow for creating new habits, from user interaction through all architecture layers to database persistence.
- **Key Components**: HomePage, HabitBloc, UseCases, Repository, Service Layer, SQLite

### 2. Complete Habit Workflow
- **File**: `complete_habit_workflow.md` / `complete_habit_workflow.puml`
- **Description**: Shows how habits are marked as completed/incomplete, including haptic feedback, database operations, and UI updates.
- **Key Components**: HabitCard, HabitEntry management, Result pattern, State updates

### 3. View Habits and History Workflow
- **File**: `view_habits_workflow.md` / `view_habits_workflow.puml`
- **Description**: Illustrates how users view their habits, check completion history, and navigate through the app's data visualization.
- **Key Components**: CalendarView, HabitCard expansion, Responsive layout, Data loading

### 4. Calendar Navigation Workflow
- **File**: `calendar_navigation_workflow.md` / `calendar_navigation_workflow.puml`
- **Description**: Details the calendar navigation system, month switching, and completion data visualization.
- **Key Components**: Month calculations, Grid generation, Completion indicators, Navigation buttons

### 5. Service Abstraction Layer Workflow
- **File**: `service_abstraction_workflow.md` / `service_abstraction_workflow.puml`
- **Description**: Explains the service abstraction pattern that provides clean separation between business logic and data persistence.
- **Key Components**: Repository pattern, Service interface, IODriver, Result pattern, Future extensibility

## Format Information

Each workflow is available in two formats:

### Markdown Format (.md)
- Contains detailed textual descriptions
- Includes Mermaid.js diagrams for visualization
- Provides architecture layer breakdowns
- Documents error handling and performance considerations

### PlantUML Format (.puml)
- Pure PlantUML syntax for diagram generation
- Can be rendered with PlantUML tools
- Shows class relationships and data flow
- Useful for automated documentation generation

## Architecture Overview

The Daymark app follows Clean Architecture principles with clear separation of concerns:

### Presentation Layer
- **Widgets**: HomePage, HabitCard, CalendarView
- **State Management**: HabitBloc (BLoC pattern)
- **Responsive Design**: Adaptive layouts for mobile/tablet

### Domain Layer
- **Entities**: Habit, HabitEntry (pure business objects)
- **UseCases**: GetHabits, MarkHabitToday, GetTodayEntries
- **Repository Interfaces**: Contract definitions

### Data Layer
- **Repository Implementations**: HabitRepositoryImpl
- **Service Abstraction**: HabitService interface
- **Concrete Implementations**: IODriver (SQLite)
- **Data Models**: Database-specific representations

## Key Design Patterns

### Clean Architecture
- Dependency inversion principle
- Separation of business logic from implementation details
- Testable and maintainable code structure

### Repository Pattern
- Abstract data access layer
- Easy swapping of data sources
- Consistent API for data operations

### BLoC Pattern
- Predictable state management
- Clear separation of UI and business logic
- Reactive programming approach

### Result Pattern
- Type-safe error handling
- Functional programming approach
- Clear success/failure states

## Usage Instructions

### Viewing Markdown Files
- Open any `.md` file in a markdown viewer that supports Mermaid.js
- GitHub, GitLab, and many IDEs will render the diagrams automatically

### Generating PlantUML Diagrams
1. Install PlantUML (http://plantuml.com/)
2. Use the command: `plantuml filename.puml`
3. Diagrams will be generated as PNG/SVG files

### Online PlantUML Tools
- Use online tools like https://www.plantuml.com/plantuml/uml/
- Copy and paste the `.puml` content to generate diagrams

## Related Documentation

- [Implementation Summary](../IMPLEMENTATION_SUMMARY.md)
- [Architecture Review](../../FlutterArchitectureReviewer_review_02.md)
- [UI Review](../../FlutterUIReviewer_review_02.md)

## Contributing

When updating these fluxograms:
1. Update both markdown and PlantUML versions
2. Ensure consistency between formats
3. Test PlantUML syntax with online tools
4. Update this README if adding new workflows

## Notes

These fluxograms focus on explaining user flows and system interactions without modifying any Dart code. They serve as comprehensive documentation for understanding the Daymark app's architecture and workflows.