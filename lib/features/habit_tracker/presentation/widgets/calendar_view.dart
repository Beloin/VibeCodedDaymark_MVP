import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daymark/app/shared/theme/app_colors.dart';

/// Calendar widget for viewing habit completion history with enhanced design
class CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final Map<DateTime, int> completionData; // Date -> number of completed habits
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final Function(DateTime)? onDaySelected;
  final DateTime? selectedDate;

  const CalendarView({
    super.key,
    required this.currentMonth,
    required this.completionData,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onDaySelected,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM yyyy').format(currentMonth);
    final daysInMonth = _getDaysInMonth(currentMonth);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Month header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Semantics(
                   label: 'Previous month',
                   button: true,
                   child: IconButton(
                     onPressed: onPreviousMonth,
                     icon: Icon(
                       Icons.chevron_left,
                       color: theme.colorScheme.primary,
                       size: 28,
                     ),
                     style: IconButton.styleFrom(
                       backgroundColor: theme.colorScheme.surfaceContainerHighest,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                     ),
                   ),
                 ),
                Text(
                  monthName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                 Semantics(
                   label: 'Next month',
                   button: true,
                   child: IconButton(
                     onPressed: onNextMonth,
                     icon: Icon(
                       Icons.chevron_right,
                       color: theme.colorScheme.primary,
                       size: 28,
                     ),
                     style: IconButton.styleFrom(
                       backgroundColor: theme.colorScheme.surfaceContainerHighest,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                     ),
                   ),
                 ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Weekday headers
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final dayOffset = index - (startingWeekday - 1);
                final day = dayOffset >= 0 && dayOffset < daysInMonth
                    ? dayOffset + 1
                    : null;
                
                if (day == null) {
                  return Container(); // Empty cell
                }
                
                final date = DateTime(currentMonth.year, currentMonth.month, day);
                final completedCount = completionData[date] ?? 0;
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = selectedDate != null && _isSameDay(date, selectedDate!);
                
                return _buildCalendarDay(
                  day: day,
                  isToday: isToday,
                  isSelected: isSelected,
                  completedCount: completedCount,
                  theme: theme,
                );
              },
            ),
            
            // Legend
            const SizedBox(height: 16),
            _buildLegend(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay({
    required int day,
    required bool isToday,
    required bool isSelected,
    required int completedCount,
    required ThemeData theme,
  }) {
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    final dateFormatted = DateFormat('MMMM d, yyyy').format(date);
    
    return Semantics(
      label: isToday 
        ? 'Today, $dateFormatted, $completedCount habits completed'
        : '$dateFormatted, $completedCount habits completed',
      button: onDaySelected != null,
      child: GestureDetector(
        onTap: onDaySelected != null ? () => onDaySelected!(date) : null,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected 
              ? theme.colorScheme.secondaryContainer
              : isToday 
                ? theme.colorScheme.primaryContainer 
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: theme.colorScheme.secondary, width: 2)
                : isToday
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
                // Day number
                Text(
                  day.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : isToday 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              
              // Completion indicator
              if (completedCount > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getCompletionColor(completedCount, theme),
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        completedCount > 9 ? '9+' : completedCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.surface,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Today', theme.colorScheme.primaryContainer, theme),
        const SizedBox(width: 16),
        _buildLegendItem('Selected', theme.colorScheme.secondaryContainer, theme),
        const SizedBox(width: 16),
        _buildLegendItem('Completed', AppColors.success, theme),
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
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

   Color _getCompletionColor(int count, ThemeData theme) {
    if (count >= 5) return AppColors.success;
    if (count >= 3) return theme.colorScheme.tertiary;
    return theme.colorScheme.secondary;
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}