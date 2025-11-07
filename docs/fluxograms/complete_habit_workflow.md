# Complete Habit Workflow

## Overview
This fluxogram illustrates the process of marking a habit as completed for the current day, including the data flow through all architecture layers.

## Workflow Steps

```mermaid
flowchart TD
    A[User Taps Habit Card] --> B[HabitCard.onToggleCompletion]
    B --> C[Haptic Feedback Triggered]
    C --> D[HomePage._markHabitCompleted]
    D --> E[HabitBloc processes MarkHabitCompleted event]
    E --> F[MarkHabitToday UseCase executes]
    F --> G[HabitRepositoryImpl calls HabitService]
    G --> H[IODriver.markHabitForToday]
    H --> I[Check if entry exists for today]
    I --> J{Entry Exists?}
    J -->|Yes| K[Update existing entry]
    J -->|No| L[Create new entry]
    K --> M[Update SQLite record]
    L --> N[Insert SQLite record]
    M --> O[Return Success Result]
    N --> O
    O --> P[HabitBloc triggers LoadTodayEntries]
    P --> Q[GetTodayEntries UseCase executes]
    Q --> R[HabitRepositoryImpl calls HabitService]
    R --> S[IODriver queries today's entries]
    S --> T[Returns List<HabitEntry>]
    T --> U[HabitBloc emits HabitLoaded with updated entries]
    U --> V[HomePage rebuilds with updated completion state]
    V --> W[HabitCard shows new completion status]
```

## Architecture Layers Involved

### Presentation Layer
- **HabitCard Widget**: Individual habit display component
- **HomePage**: Main container managing habit interactions
- **HabitBloc**: State management for completion operations

### Domain Layer
- **HabitEntry Entity**: Represents daily completion status
- **MarkHabitToday UseCase**: Business logic for marking completion
- **GetTodayEntries UseCase**: Business logic for fetching today's status

### Data Layer
- **HabitRepositoryImpl**: Repository implementation
- **HabitService**: Service abstraction layer
- **IODriver**: SQLite database operations

## User Interaction Patterns

### Touch Interactions
- **Single Tap**: Toggle completion status
- **Long Press**: Quick toggle completion (accessibility feature)
- **Double Tap**: Expand/collapse habit details

### Visual Feedback
- **Haptic Feedback**: Light impact for completion, selection click for un-completion
- **Animation**: Smooth checkbox transition with AnimatedSwitcher
- **Color Changes**: Success colors for completed state

## Data Operations

### Marking Completion
1. **Check Existing Entry**: Query for today's habit entry
2. **Create/Update**: Create new entry or update existing one
3. **Set Completion Status**: Update isCompleted and completedAt fields
4. **Refresh Data**: Reload today's entries to reflect changes

### Entry Management
- **Default Entries**: Auto-created for habits without today's entry
- **Unique Constraint**: One entry per habit per day
- **Timestamp Tracking**: completedAt records exact completion time

## Error Handling

- **Database Errors**: Handled by Result pattern with specific error codes
- **Concurrency**: SQLite handles concurrent operations safely
- **Missing Data**: Default entries created when no entry exists

## Performance Considerations

- **Efficient Queries**: Single query for today's entries
- **Minimal Rebuilds**: BLoC ensures only affected widgets rebuild
- **Local Storage**: No network latency for completion operations