import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable loading overlay that grays out the UI and disables interactions
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Duration minimumDisplayTime;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.minimumDisplayTime = const Duration(milliseconds: 300),
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  bool _showLoading = false;
  DateTime? _loadingStartTime;
  Timer? _hideTimer;

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !_showLoading) {
      // Start showing loading
      _loadingStartTime = DateTime.now();
      _showLoading = true;
    } else if (!widget.isLoading && _showLoading) {
      // Check if minimum display time has elapsed
      final elapsed = DateTime.now().difference(_loadingStartTime!);
      if (elapsed >= widget.minimumDisplayTime) {
        // Minimum time has passed, hide immediately
        _showLoading = false;
      } else {
        // Wait for remaining time before hiding
        final remainingTime = widget.minimumDisplayTime - elapsed;
        _hideTimer?.cancel(); // Cancel any existing timer
        _hideTimer = Timer(remainingTime, _hideLoading);
      }
    }
  }

  void _hideLoading() {
    if (mounted && !widget.isLoading) {
      setState(() {
        _showLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Loading overlay
        if (_showLoading)
          Semantics(
            // Announce loading state to screen readers
            label: widget.loadingText ?? 'Loading...',
            liveRegion: true,
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: 'Loading indicator',
                          child: const CircularProgressIndicator(),
                        ),
                        if (widget.loadingText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.loadingText!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
