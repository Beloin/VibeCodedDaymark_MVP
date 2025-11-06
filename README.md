# Daymark - Habit Tracking App

A beautiful Flutter calendar-based habit tracking application with clean architecture and service abstraction.

## Features

- 📅 **Calendar View**: Visual calendar showing dates with checkmarks for completed habits
- 🎯 **Minimized Cards**: Clean, compact habit cards on the main screen
- ✅ **Daily Checkmarks**: Easy one-tap completion for today's habits
- 🔍 **Expandable Cards**: Expand to view/edit past checkmarks and habit details
- 💾 **Local Storage**: SQLite-based local storage with proper error handling
- 🏗️ **Clean Architecture**: Well-structured code following Flutter best practices
- 🔌 **Service Abstraction**: Easy to switch between local storage and future API implementations

## Architecture

### Clean Architecture Layers

1. **Domain Layer** (`lib/features/habit_tracker/domain/`)
   - Entities: `Habit`, `HabitEntry`
   - Repositories: `HabitRepository`
   - Use Cases: `GetHabits`, `GetTodayEntries`, `MarkHabitToday`

2. **Data Layer** (`lib/features/habit_tracker/data/`)
   - Models: `HabitModel`, `HabitEntryModel`
   - Repository Implementation: `HabitRepositoryImpl`
   - Data Sources: SQLite via `IODriver`

3. **Presentation Layer** (`lib/features/habit_tracker/presentation/`)
   - BLoC: `HabitBloc` for state management
   - Pages: `HomePage`
   - Widgets: `HabitCard`, `CalendarView`

### Service Abstraction

- **Service Interface**: `HabitService` in `lib/services/habit_service.dart`
- **IO Driver**: `IODriver` implementing local SQLite storage
- **Future API Driver**: Easy to implement by creating a new class implementing `HabitService`

## Error Handling

- **Result Pattern**: All operations return `Result<S, E>` for consistent error handling
- **Error Codes**: Standardized error codes for different types of failures
- **Graceful Degradation**: App continues to work even when individual operations fail

## Getting Started

### Prerequisites

- Flutter SDK (version 3.6.0 or higher)
- Dart SDK (version 3.6.0 or higher)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Dependencies

- `flutter_bloc`: State management
- `sqflite`: Local SQLite database
- `path`: File path utilities
- `intl`: Date formatting
- `http`: For future API integration

## Usage

1. **View Habits**: The main screen shows all your habits with today's completion status
2. **Mark Completion**: Tap the checkbox icon to mark a habit as completed for today
3. **View Details**: Tap on a habit card to expand and see more details
4. **Calendar View**: Scroll up to see the calendar with completion history
5. **Navigate Months**: Use the arrow buttons in the calendar to navigate between months

## Sample Data

The app comes pre-loaded with sample habits:
- Morning Meditation
- Exercise
- Read Book
- Drink Water
- Journal

## Future Enhancements

- API integration for cloud sync
- Habit creation and editing
- Statistics and analytics
- Notifications and reminders
- Custom habit categories
- Export functionality

## Development

### Adding New Features

1. **Domain Layer**: Define entities, repositories, and use cases
2. **Data Layer**: Implement repository and data models
3. **Presentation Layer**: Create BLoC events/states and UI components

### Service Implementation

To add a new data source (e.g., REST API):

1. Create a new class implementing `HabitService`
2. Implement all required methods
3. Update dependency injection in `main.dart`

## License

This project is licensed under the MIT License.

