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
  final VoidCallback? onDelete;
  final bool isLoading;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayEntry,
    this.isExpanded = false,
    this.onToggleCompletion,
    this.onToggleExpand,
    this.onDelete,
    this.isLoading = false,
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
    
    Widget cardContent = Semantics(
      label: 'Habit: ${widget.habit.name}',
      value: isCompleted ? 'Completed' : 'Not completed',
      hint: widget.isExpanded ? 'Double tap to collapse details' : 'Double tap to expand details',
      // Announce loading state to screen readers
      liveRegion: widget.isLoading,
      child: GestureDetector(
        onLongPress: () {
          // Show context menu on long press
          _showContextMenu(context);
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

    // Wrap in Dismissible for swipe-to-delete if onDelete callback is provided
    if (widget.onDelete != null) {
      return Dismissible(
        key: Key('habit_${widget.habit.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          // Show confirmation dialog
          final confirmed = await _showDeleteConfirmationDialog(context);
          return confirmed;
        },
        onDismissed: (direction) {
          if (widget.onDelete != null) {
            widget.onDelete!();
          }
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCheckbox(bool isCompleted, ThemeData theme) {
    return Semantics(
      label: widget.isLoading 
        ? 'Updating ${widget.habit.name}... Please wait' 
        : isCompleted 
          ? 'Mark ${widget.habit.name} as incomplete' 
          : 'Mark ${widget.habit.name} as completed',
      value: widget.isLoading ? 'Loading...' : (isCompleted ? 'Completed' : 'Not completed'),
      button: true,
      enabled: !widget.isLoading,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onToggleCompletion,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
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
            if (widget.isLoading)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${widget.habit.name}"? This action cannot be undone and will also delete all associated habit entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox card = context.findRenderObject() as RenderBox;
    final position = card.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + card.size.width,
        position.dy + card.size.height,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'toggle_completion',
          child: Row(
            children: [
              Icon(
                widget.todayEntry?.isCompleted ?? false 
                  ? Icons.radio_button_unchecked 
                  : Icons.check_circle,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                widget.todayEntry?.isCompleted ?? false 
                  ? 'Mark as Incomplete' 
                  : 'Mark as Complete',
              ),
            ],
          ),
        ),
        if (widget.onDelete != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: AppColors.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete Habit',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).then((value) {
      if (value == 'toggle_completion' && widget.onToggleCompletion != null) {
        widget.onToggleCompletion!();
      } else if (value == 'delete' && widget.onDelete != null) {
        _showDeleteConfirmationDialog(context).then((confirmed) {
          if (confirmed) {
            widget.onDelete!();
          }
        });
      }
    });
  }
}
