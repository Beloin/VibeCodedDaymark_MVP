import 'package:flutter/material.dart';
import 'package:daymark/app/shared/theme/app_colors.dart';
import 'custom_illustrations.dart';

/// Empty state widget for various scenarios
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showIllustration;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.showIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration/Icon
            if (showIllustration)
              CustomIllustrations.emptyHabits(context),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty state for no habits
class NoHabitsEmptyState extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const NoHabitsEmptyState({
    super.key,
    required this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.add_task,
      title: 'No Habits Yet',
      description: 'Create your first habit to start tracking your progress and building better routines.',
      actionText: 'Create Habit',
      onAction: onCreateHabit,
    );
  }
}

/// Empty state for no completed habits today
class NoCompletedHabitsEmptyState extends StatelessWidget {
  const NoCompletedHabitsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.schedule,
      title: 'No Habits Completed Today',
      description: 'Start your day by completing some habits! Check off the habits you\'ve accomplished today.',
      showIllustration: true,
    );
  }
}

/// Empty state for calendar with no data
class EmptyCalendarState extends StatelessWidget {
  const EmptyCalendarState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.calendar_today,
      title: 'No Activity Yet',
      description: 'Your calendar will show your habit completion history once you start tracking habits.',
      showIllustration: true,
    );
  }
}