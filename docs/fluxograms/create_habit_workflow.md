# Create New Habit Workflow

## Overview
This fluxogram illustrates the process of creating a new habit in the Daymark app, following the Clean Architecture pattern.

## Workflow Steps

```mermaid
flowchart TD
    A[User Opens App] --> B[HomePage Widget Loads]
    B --> C[initState triggers LoadHabits]
    C --> D[HabitBloc processes LoadHabits event]
    D --> E[GetHabits UseCase executes]
    E --> F[HabitRepositoryImpl calls HabitService]
    F --> G[IODriver queries SQLite database]
    G --> H[Returns List<Habit>]
    H --> I[HabitBloc emits HabitLoaded state]
    I --> J[HomePage displays habits]
    
    K[User Clicks Create Habit] --> L[Show Create Habit Dialog]
    L --> M[User Enters Habit Details]
    M --> N[Validate Habit Data]
    N --> O[Create Habit Entity]
    O --> P[HabitBloc processes CreateHabit event]
    P --> Q[CreateHabit UseCase executes]
    Q --> R[HabitRepositoryImpl calls HabitService]
    R --> S[IODriver inserts into SQLite]
    S --> T[Returns Created Habit]
    T --> U[HabitBloc emits HabitCreated state]
    U --> V[Reload Habits List]
    V --> J
```

## Architecture Layers Involved

### Presentation Layer
- **HomePage Widget**: Main UI component
- **HabitBloc**: State management for habit operations
- **Create Habit Dialog**: UI for habit creation

### Domain Layer
- **Habit Entity**: Core business object
- **CreateHabit UseCase**: Business logic for habit creation
- **HabitRepository Interface**: Contract for data operations

### Data Layer
- **HabitRepositoryImpl**: Repository implementation
- **HabitService**: Service abstraction layer
- **IODriver**: SQLite database operations

## Data Flow

1. **User Input**: User provides habit name and description
2. **Validation**: Client-side validation of required fields
3. **Entity Creation**: Habit entity created with unique ID and timestamps
4. **Repository Call**: UseCase calls repository with new habit
5. **Database Insert**: IODriver inserts habit into SQLite database
6. **State Update**: BLoC emits new state with updated habits list
7. **UI Refresh**: HomePage rebuilds with new habit

## Error Handling

- **Validation Errors**: Displayed in the create dialog
- **Database Errors**: Handled by Result<T, ErrorCode> pattern
- **Network Errors**: Currently local-only, but prepared for future

## Key Components

- **Habit Entity**: Contains id, name, description, createdAt, updatedAt
- **Result Pattern**: Ensures type-safe error handling
- **SQLite Database**: Local storage with proper schema
- **BLoC Pattern**: Clean state management separation