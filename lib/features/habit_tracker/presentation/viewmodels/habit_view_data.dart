import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/app_config.dart';
import '../bloc/habit_bloc.dart';

/// Unified data model that contains all data needed by both calendar and tile views
class HabitViewData {
  final List<Habit> habits;
  final List<HabitEntry> selectedDateEntries;
  final Map<String, List<HabitEntry>> historicalEntries;
  final DateTime selectedDate;
  final AppConfig? config;

  const HabitViewData({
    required this.habits,
    required this.selectedDateEntries,
    required this.historicalEntries,
    required this.selectedDate,
    this.config,
  });

  /// Creates a HabitViewData from HabitLoaded state
  factory HabitViewData.fromHabitState(HabitLoaded state, AppConfig? config) {
    return HabitViewData(
      habits: state.habits,
      selectedDateEntries: state.selectedDateEntries,
      historicalEntries: state.historicalEntries,
      selectedDate: state.selectedDate,
      config: config,
    );
  }

  /// Gets the completion data for calendar view
  Map<DateTime, int> get completionData {
    final completionData = <DateTime, int>{};
    
    // Aggregate completion data from selected date entries
    for (final entry in selectedDateEntries) {
      if (entry.isCompleted) {
        final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
        completionData[date] = (completionData[date] ?? 0) + 1;
      }
    }
    
    return completionData;
  }

  /// Gets the habit-specific data for tile view
  List<HabitTileData> get habitTileData {
    return habits.map((habit) {
      final todayEntry = selectedDateEntries.firstWhere(
        (entry) => entry.habitId == habit.id,
        orElse: () => HabitEntry(
          id: '${habit.id}_${selectedDate.toIso8601String()}',
          habitId: habit.id,
          date: selectedDate,
          isCompleted: false,
        ),
      );
      
      final habitHistoricalEntries = historicalEntries[habit.id] ?? [];
      
      return HabitTileData(
        habit: habit,
        todayEntry: todayEntry,
        historyEntries: habitHistoricalEntries,
        config: config,
      );
    }).toList();
  }

  /// Checks if there are any habits
  bool get hasHabits => habits.isNotEmpty;

  /// Gets the number of completed habits for the selected date
  int get completedCount {
    return selectedDateEntries.where((entry) => entry.isCompleted).length;
  }

  /// Gets the completion rate for the selected date
  double get completionRate {
    return habits.isEmpty ? 0.0 : completedCount / habits.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HabitViewData &&
        const ListEquality().equals(habits, other.habits) &&
        const ListEquality().equals(selectedDateEntries, other.selectedDateEntries) &&
        const MapEquality(values: ListEquality()).equals(historicalEntries, other.historicalEntries) &&
        selectedDate == other.selectedDate &&
        config == other.config;
  }

  @override
  int get hashCode {
    return Object.hash(
      const ListEquality().hash(habits),
      const ListEquality().hash(selectedDateEntries),
      const MapEquality(values: ListEquality()).hash(historicalEntries),
      selectedDate,
      config,
    );
  }
}

/// Data model specifically for habit tile view
class HabitTileData {
  final Habit habit;
  final HabitEntry todayEntry;
  final List<HabitEntry> historyEntries;
  final AppConfig? config;

  const HabitTileData({
    required this.habit,
    required this.todayEntry,
    required this.historyEntries,
    this.config,
  });

  /// Gets the number of days to show based on config
  int get daysToShow {
    return (config?.weeksToDisplay ?? 2) * 7;
  }

  /// Gets the base color for the habit
  Color get baseColor {
    // Check if there's a persistent color in config
    if (config?.habitColors.containsKey(habit.id) == true) {
      final colorHex = config!.habitColors[habit.id]!;
      return _hexToColor(colorHex);
    }
    
    // Generate a consistent color based on habit ID
    final hash = habit.id.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  /// Gets the completion count for the habit
  int get completedCount {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: daysToShow - 1));
    
    // Get unique dates where the habit was completed
    final completedDates = <String>{};
    
    for (final entry in historyEntries) {
      if (entry.isCompleted && 
          !entry.date.isAfter(today) &&
          !entry.date.isBefore(startDate)) {
        // Use a string representation of the date to ensure uniqueness per day
        final dateKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
        completedDates.add(dateKey);
      }
    }
    
    // Also include today's completion if it exists
    if (todayEntry.isCompleted) {
      final todayKey = '${today.year}-${today.month}-${today.day}';
      completedDates.add(todayKey);
    }
    
    return completedDates.length;
  }

  /// Gets the completion rate for the habit
  double get completionRate {
    return daysToShow > 0 ? completedCount / daysToShow : 0;
  }

  /// Gets the entry for a specific date
  HabitEntry? getEntryForDate(DateTime date) {
    // Check if it's today and we have a todayEntry
    if (_isSameDay(date, DateTime.now())) {
      return todayEntry;
    }
    
    // Otherwise look in history entries
    return historyEntries.firstWhere(
      (entry) => _isSameDay(entry.date, date),
      orElse: () => HabitEntry(
        id: '',
        habitId: habit.id,
        date: date,
        isCompleted: false,
      ),
    );
  }

  // Helper methods
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HabitTileData &&
        habit == other.habit &&
        todayEntry == other.todayEntry &&
        const ListEquality().equals(historyEntries, other.historyEntries) &&
        config == other.config;
  }

  @override
  int get hashCode {
    return Object.hash(
      habit,
      todayEntry,
      const ListEquality().hash(historyEntries),
      config,
    );
  }
}