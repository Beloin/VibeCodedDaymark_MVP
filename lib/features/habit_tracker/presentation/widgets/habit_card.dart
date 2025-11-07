import 'package:flutter/material.dart';
import 'package:daymark/app/shared/theme/app_colors.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';

/// Card widget for displaying a habit with smooth animations
class HabitCard extends StatefulWidget {
  final Habit habit;
  final HabitEntry? todayEntry;
  final bool isExpanded;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onToggleExpand;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayEntry,
    this.isExpanded = false,
    this.onToggleCompletion,
    this.onToggleExpand,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  // Simplified animation approach using AnimatedSize for better performance
  // This avoids the overhead of AnimationController and is more performant
  
  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when expansion state changes
    if (widget.isExpanded != oldWidget.isExpanded) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todayEntry?.isCompleted ?? false;
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Habit: ${widget.habit.name}',
      value: isCompleted ? 'Completed' : 'Not completed',
      hint: widget.isExpanded ? 'Double tap to collapse details' : 'Double tap to expand details',
      child: GestureDetector(
        onLongPress: () {
          // Long press to quickly toggle completion
          if (widget.onToggleCompletion != null) {
            widget.onToggleCompletion!();
          }
        },
        onDoubleTap: () {
          // Double tap to toggle expansion
          if (widget.onToggleExpand != null) {
            widget.onToggleExpand!();
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Checkbox with animation
                      _buildCheckbox(isCompleted, theme),
                      
                      const SizedBox(width: 16),
                      
                      // Habit name and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.habit.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.habit.description,
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
                      
                      // Expand/collapse icon with simplified animation
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: widget.isExpanded ? 0.5 : 0.0,
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.expand_more,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
              
                  // Expanded content with optimized animation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: widget.isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Completion status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                     color: isCompleted 
                                       ? AppColors.successContainer
                                       : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompleted ? Icons.check_circle : Icons.schedule,
                                        size: 16,
                                           color: isCompleted 
                                             ? AppColors.success
                                             : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isCompleted 
                                          ? 'Completed today at ${_formatTime(widget.todayEntry?.completedAt)}'
                                          : 'Not completed today',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                           color: isCompleted 
                                             ? AppColors.success
                                             : theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Additional details
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Created: ${_formatDate(widget.habit.createdAt)}',
                                  theme,
                                ),
                                
                                if (widget.habit.updatedAt != null)
                                  _buildDetailRow(
                                    Icons.edit,
                                    'Updated: ${_formatDate(widget.habit.updatedAt!)}',
                                    theme,
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isCompleted, ThemeData theme) {
    return Semantics(
      label: isCompleted ? 'Mark ${widget.habit.name} as incomplete' : 'Mark ${widget.habit.name} as completed',
      button: true,
      child: GestureDetector(
        onTap: widget.onToggleCompletion,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
             color: isCompleted 
               ? AppColors.success
               : theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
               color: isCompleted 
                 ? AppColors.success
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
                      size: 18,
                       color: AppColors.onSuccess,
                      key: const ValueKey('completed'),
                    )
                  : const SizedBox.shrink(key: ValueKey('incomplete')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}