# Unified MVVM Architecture for Daymark

## Overview

The Daymark habit tracking app now uses a unified MVVM (Model-View-ViewModel) architecture that provides a single source of truth for both calendar and tile views, eliminating state synchronization issues and improving maintainability.

## Architecture Components

### 1. HabitCalendarViewModel
- **Purpose**: Central ViewModel that provides data and operations for both calendar and tile views
- **Key Features**:
  - Unified data access through `viewData` property
  - State synchronization between views
  - View switching capabilities
  - Historical data loading for tile view

### 2. HabitViewData
- **Purpose**: Single source of truth model that contains all data needed by both views
- **Key Properties**:
  - `habits`: List of all habits
  - `selectedDateEntries`: Entries for the currently selected date
  - `historicalEntries`: Historical data for tile view
  - `completionData`: Calendar completion data
  - `config`: App configuration

### 3. HabitTileData
- **Purpose**: Tile-specific data transformations
- **Key Properties**:
  - `habit`: The habit object
  - `todayEntry`: Today's completion status
  - `historyEntries`: Historical entries for this habit
  - `daysToShow`: Number of days to display

## State Synchronization

### How It Works
1. **Single Source of Truth**: Both views use the same `HabitViewData` model
2. **Automatic Updates**: When a habit is marked complete/incomplete:
   - Calendar view updates immediately via `LoadDateEntries`
   - Tile view updates via `LoadHistoricalEntries` triggered by the ViewModel
3. **No Race Conditions**: Debouncing and proper state management prevent conflicts

### Key Synchronization Points
- **HabitBloc Listener**: Automatically reloads historical data when in tile view
- **ViewModel Methods**: Unified operations that update both views
- **State Management**: Proper loading states prevent UI conflicts

## Benefits

1. **Eliminated State Conflicts**: No more "all messed up" state after habit completion
2. **Improved Maintainability**: Clear separation between business logic and UI
3. **Better Performance**: Optimized data loading and debouncing
4. **Enhanced Testability**: ViewModel can be easily tested in isolation
5. **Future-Proof**: Easy to add new views or features

## Usage

### In Views
```dart
final viewModel = HabitCalendarViewModel(context);
final viewData = viewModel.viewData;

// Calendar view
_buildCalendarView(viewModel, viewData);

// Tile view  
_buildTileView(viewModel, viewData);
```

### Operations
```dart
// Mark habit complete
viewModel.markHabitCompleted(habitId, true);

// Switch views
viewModel.switchView(ViewType.tile);

// Load historical data
viewModel.loadHistoricalData();
```

## Migration Status

- ✅ **HomePageRefactored**: Uses unified MVVM architecture
- ✅ **Main App**: Updated to use refactored home page
- ✅ **State Management**: Proper synchronization implemented
- ✅ **Build & Test**: App builds successfully, tests pass

## Future Enhancements

1. **Migrate Original HomePage**: Consider replacing original implementation
2. **Add More ViewModels**: For specific features like analytics
3. **Enhanced Testing**: Add comprehensive ViewModel tests
4. **Performance Optimization**: Fine-tune data loading strategies
