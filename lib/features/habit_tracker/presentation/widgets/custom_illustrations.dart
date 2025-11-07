import 'dart:math';
import 'package:flutter/material.dart';
import 'package:daymark/app/shared/theme/app_colors.dart';

/// Custom illustrations for various app states
class CustomIllustrations {
  /// Empty habits illustration
  static Widget emptyHabits(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          
          // Plus icon
          Icon(
            Icons.add,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          
          // Small dots around
          ...List.generate(8, (index) {
            final angle = (index / 8) * 2 * 3.14159;
            final radius = 70.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            
            return Positioned(
              left: 75 + x,
              top: 75 + y,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Error illustration
  static Widget errorState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          
          // Exclamation mark
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.onError,
          ),
          
          // Small warning triangles
          ...List.generate(6, (index) {
            final angle = (index / 6) * 2 * 3.14159;
            final radius = 65.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            
            return Positioned(
              left: 75 + x,
              top: 75 + y,
              child: Icon(
                Icons.warning,
                size: 16,
                color: AppColors.error,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Success illustration
  static Widget successState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          
          // Check mark
          Icon(
            Icons.check,
            size: 48,
            color: AppColors.onSuccess,
          ),
          
          // Small check marks around
          ...List.generate(8, (index) {
            final angle = (index / 8) * 2 * 3.14159;
            final radius = 70.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            
            return Positioned(
              left: 75 + x,
              top: 75 + y,
              child: Icon(
                Icons.check_circle,
                size: 12,
                color: AppColors.success,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Calendar illustration
  static Widget calendarState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Calendar body
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              ),
            ),
          ),
          
          // Calendar header
          Positioned(
            top: 40,
            child: Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          
          // Calendar grid
          Positioned(
            top: 65,
            child: Container(
              width: 100,
              height: 80,
              child: GridView.count(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: List.generate(28, (index) => Container(
                  decoration: BoxDecoration(
                    color: index % 7 == 0 || index % 7 == 6 
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}