import 'package:flutter/material.dart';
import 'package:daymark/app/shared/theme/app_colors.dart';
import 'custom_illustrations.dart';

/// Enhanced error state widget with better UX
class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String? customTitle;
  final String? customDescription;

  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.customTitle,
    this.customDescription,
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
            // Error illustration
            CustomIllustrations.errorState(context),
            
            const SizedBox(height: 24),
            
            // Error title
            Text(
              customTitle ?? 'Something Went Wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Error description
            Text(
              customDescription ?? 'We encountered an issue while loading your data. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Technical error details (collapsible)
            _buildErrorDetails(error, theme),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
                
                const SizedBox(width: 12),
                
                ElevatedButton(
                  onPressed: () {
                    // Could implement more advanced error handling here
                    onRetry();
                  },
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
                  child: const Text('Reload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDetails(String error, ThemeData theme) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Technical Details',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

/// Network error specific state
class NetworkErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      error: 'Network connection error',
      onRetry: onRetry,
      customTitle: 'Connection Issue',
      customDescription: 'Unable to connect to the server. Please check your internet connection and try again.',
    );
  }
}

/// Data loading error state
class DataLoadingErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const DataLoadingErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      error: 'Failed to load data',
      onRetry: onRetry,
      customTitle: 'Data Loading Failed',
      customDescription: 'We couldn\'t load your habit data. This might be a temporary issue.',
    );
  }
}