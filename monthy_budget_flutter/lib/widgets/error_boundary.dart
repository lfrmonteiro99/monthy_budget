import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Catches errors in its child widget tree and displays a user-friendly
/// fallback UI instead of crashing the entire app.
///
/// Wraps [ErrorWidget.builder] during its lifecycle so that framework-level
/// build/layout/paint errors in [child] are captured and rendered as a
/// recoverable card with a retry button.
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  /// Optional callback invoked when an error is caught, useful for logging.
  final void Function(Object error, StackTrace? stack)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _installErrorHandler();
  }

  void _installErrorHandler() {
    final originalBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Only capture if this boundary hasn't already captured an error.
      if (_error == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _error = details.exception;
          });
          widget.onError?.call(details.exception, details.stack);
        });
      }
      // Return the original error widget so the framework doesn't break
      // during the current build pass.
      return originalBuilder(details);
    };
  }

  void _retry() {
    setState(() {
      _error = null;
    });
    _installErrorHandler();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorFallback(
        error: _error!,
        onRetry: _retry,
      );
    }
    return widget.child;
  }
}

class _ErrorFallback extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorFallback({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: AppColors.error(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This section encountered an error.\nThe rest of the app is unaffected.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
