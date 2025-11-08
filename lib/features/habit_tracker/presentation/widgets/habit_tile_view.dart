import 'package:flutter/material.dart';

import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

/// GitHub-style habit tile view showing completion history as colored tiles
class HabitTileView extends StatelessWidget {
  final Habit habit;
  final HabitEntry? todayEntry;
  final List<HabitEntry> historyEntries;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onDelete;
  final bool isLoading;
  final int daysToShow;
  final AppConfig? config;

  const HabitTileView({
    super.key,
    required this.habit,
    this.todayEntry,
    this.historyEntries = const [],
    this.onToggleCompletion,
    this.onDelete,
    this.isLoading = false,
    this.daysToShow = 14,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = todayEntry?.isCompleted ?? false;
    final baseColor = _getHabitBaseColor(habit);
    
    Widget tileContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with habit info and completion button
            Row(
              children: [
                // Habit name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            habit.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Completion button
                _buildCompletionButton(isCompleted, baseColor, theme),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // GitHub-style tile grid
            _buildTileGrid(baseColor, theme),
            
            const SizedBox(height: 8),
            
            // Legend and stats
            _buildLegendAndStats(isCompleted, theme),
          ],
        ),
      ),
    );

    // Add swipe-to-delete functionality if onDelete callback is provided
    if (onDelete != null) {
      return Dismissible(
        key: Key('habit_tile_${habit.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (direction) async {
          // Show confirmation dialog
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Habit'),
              content: Text('Are you sure you want to delete "${habit.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          return shouldDelete ?? false;
        },
        onDismissed: (direction) {
          onDelete!();
        },
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildCompletionButton(bool isCompleted, Color baseColor, ThemeData theme) {
    return Semantics(
      label: isLoading 
        ? 'Updating ${habit.name}... Please wait' 
        : isCompleted 
          ? 'Mark ${habit.name} as incomplete' 
          : 'Mark ${habit.name} as completed',
      value: isLoading ? 'Loading...' : (isCompleted ? 'Completed' : 'Not completed'),
      button: true,
      enabled: !isLoading,
      child: GestureDetector(
        onTap: isLoading ? null : onToggleCompletion,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted 
                  ? baseColor
                  : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted 
                    ? baseColor
                    : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: _getContrastColor(baseColor),
                          key: const ValueKey('completed'),
                        )
                      : const SizedBox.shrink(key: ValueKey('incomplete')),
                ),
              ),
            ),
            if (isLoading)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getContrastColor(baseColor),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileGrid(Color baseColor, ThemeData theme) {
    final today = DateTime.now();
    final tiles = <Widget>[];
    
    // Generate tiles for the past days (from today backwards)
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final entry = _getEntryForDate(date);
      final isCompleted = entry?.isCompleted ?? false;
      
      tiles.add(
        _buildTile(
          date: date,
          isCompleted: isCompleted,
          baseColor: baseColor,
          theme: theme,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last $daysToShow days',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tiles,
        ),
      ],
    );
  }

  Widget _buildTile({
    required DateTime date,
    required bool isCompleted,
    required Color baseColor,
    required ThemeData theme,
  }) {
    final isToday = _isSameDay(date, DateTime.now());
    final tileColor = isCompleted ? baseColor : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isToday ? theme.colorScheme.primary : Colors.transparent;
    
    return Semantics(
      label: '${_formatDate(date)}: ${isCompleted ? 'Completed' : 'Not completed'}' +
             (isToday ? ' (Today)' : ''),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: borderColor,
            width: isToday ? 2 : 1,
          ),
        ),
        child: isToday
            ? Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getContrastColor(tileColor),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLegendAndStats(bool isCompleted, ThemeData theme) {
    final completedCount = _getCompletedCount();
    final completionRate = daysToShow > 0 ? completedCount / daysToShow : 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Legend
        Row(
          children: [
            _buildLegendItem('Less', theme.colorScheme.surfaceContainerHighest, theme),
            const SizedBox(width: 8),
            _buildLegendItem('More', _getHabitBaseColor(habit), theme),
          ],
        ),
        
        // Stats
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '$completedCount/$daysToShow (${(completionRate * 100).round()}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getHabitBaseColor(Habit habit) {
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

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  HabitEntry? _getEntryForDate(DateTime date) {
    // Check if it's today and we have a todayEntry
    if (_isSameDay(date, DateTime.now()) && todayEntry != null) {
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

  int _getCompletedCount() {
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
    if (todayEntry?.isCompleted == true) {
      final todayKey = '${today.year}-${today.month}-${today.day}';
      completedDates.add(todayKey);
    }
    
    return completedDates.length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}