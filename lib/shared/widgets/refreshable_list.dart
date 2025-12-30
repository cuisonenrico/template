import 'package:flutter/material.dart';

/// A wrapper widget that provides pull-to-refresh functionality
/// Works with any scrollable child (ListView, GridView, SingleChildScrollView, etc.)
class RefreshableList<T> extends StatelessWidget {
  /// The async function to call when refresh is triggered
  final Future<void> Function() onRefresh;

  /// The scrollable child widget
  final Widget child;

  /// Whether to show a loading indicator on initial load
  final bool isLoading;

  /// Whether the list has an error state
  final bool hasError;

  /// Error message to display
  final String? errorMessage;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Whether the list is empty
  final bool isEmpty;

  /// Widget to show when list is empty
  final Widget? emptyWidget;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Custom error widget builder
  final Widget Function(String message, VoidCallback? onRetry)? errorBuilder;

  /// Pull-to-refresh indicator color
  final Color? refreshIndicatorColor;

  /// Pull-to-refresh background color
  final Color? refreshIndicatorBackgroundColor;

  /// Displacement for the refresh indicator
  final double displacement;

  const RefreshableList({
    super.key,
    required this.onRefresh,
    required this.child,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyWidget,
    this.loadingWidget,
    this.errorBuilder,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.displacement = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading && !hasError) {
      return loadingWidget ?? _buildDefaultLoading(context);
    }

    // Show error state
    if (hasError) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: refreshIndicatorColor ?? Theme.of(context).colorScheme.primary,
        backgroundColor: refreshIndicatorBackgroundColor,
        displacement: displacement,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child:
                errorBuilder?.call(
                  errorMessage ?? 'An error occurred',
                  onRetry,
                ) ??
                _buildDefaultError(context),
          ),
        ),
      );
    }

    // Show empty state
    if (isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: refreshIndicatorColor ?? Theme.of(context).colorScheme.primary,
        backgroundColor: refreshIndicatorBackgroundColor,
        displacement: displacement,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: emptyWidget ?? _buildDefaultEmpty(context),
          ),
        ),
      );
    }

    // Show content with refresh capability
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? Theme.of(context).colorScheme.primary,
      backgroundColor: refreshIndicatorBackgroundColor,
      displacement: displacement,
      child: child,
    );
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDefaultError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No items yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget with customizable icon, title, and description
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
