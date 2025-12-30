import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

/// Pagination state for managing paginated data
@freezed
class PaginatedState<T> with _$PaginatedState<T> {
  const factory PaginatedState({
    @Default([]) List<T> items,
    @Default(1) int currentPage,
    @Default(20) int pageSize,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    String? error,
    @Default(0) int totalItems,
  }) = _PaginatedState<T>;

  const PaginatedState._();

  /// Whether initial load has happened
  bool get hasLoaded => items.isNotEmpty || hasReachedEnd || error != null;

  /// Whether can load more items
  bool get canLoadMore => !isLoadingMore && !hasReachedEnd && !isLoading;

  /// Whether the list is empty (after loading)
  bool get isEmpty => hasLoaded && items.isEmpty;

  /// Total number of pages
  int get totalPages => (totalItems / pageSize).ceil();

  /// Reset to initial state
  PaginatedState<T> reset() => PaginatedState<T>(pageSize: pageSize);

  /// Set loading state for initial load
  PaginatedState<T> loading() => copyWith(isLoading: true, error: null);

  /// Set loading state for loading more
  PaginatedState<T> loadingMore() => copyWith(isLoadingMore: true, error: null);

  /// Update with new page of data
  PaginatedState<T> addPage(List<T> newItems, {int? total, bool? reachedEnd}) {
    return copyWith(
      items: [...items, ...newItems],
      currentPage: currentPage + 1,
      isLoading: false,
      isLoadingMore: false,
      hasReachedEnd: reachedEnd ?? newItems.length < pageSize,
      totalItems: total ?? totalItems,
      error: null,
    );
  }

  /// Replace all items with new data (for refresh)
  PaginatedState<T> replaceItems(
    List<T> newItems, {
    int? total,
    bool? reachedEnd,
  }) {
    return copyWith(
      items: newItems,
      currentPage: 1,
      isLoading: false,
      isLoadingMore: false,
      hasReachedEnd: reachedEnd ?? newItems.length < pageSize,
      totalItems: total ?? totalItems,
      error: null,
    );
  }

  /// Set error state
  PaginatedState<T> withError(String message) =>
      copyWith(isLoading: false, isLoadingMore: false, error: message);

  /// Update a single item
  PaginatedState<T> updateItem(int index, T item) {
    if (index < 0 || index >= items.length) return this;
    final newItems = [...items];
    newItems[index] = item;
    return copyWith(items: newItems);
  }

  /// Remove an item
  PaginatedState<T> removeItem(int index) {
    if (index < 0 || index >= items.length) return this;
    final newItems = [...items];
    newItems.removeAt(index);
    return copyWith(
      items: newItems,
      totalItems: totalItems > 0 ? totalItems - 1 : 0,
    );
  }

  /// Add an item at the beginning
  PaginatedState<T> prependItem(T item) =>
      copyWith(items: [item, ...items], totalItems: totalItems + 1);

  /// Add an item at the end
  PaginatedState<T> appendItem(T item) =>
      copyWith(items: [...items, item], totalItems: totalItems + 1);
}

/// Widget for infinite scroll pagination
class PaginatedListView<T> extends StatefulWidget {
  /// Paginated state
  final PaginatedState<T> state;

  /// Called when reaching the bottom to load more
  final VoidCallback onLoadMore;

  /// Called when pulling to refresh
  final Future<void> Function() onRefresh;

  /// Builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional separator between items
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Widget to show at the bottom when loading more
  final Widget? loadingMoreWidget;

  /// Widget to show when list is empty
  final Widget? emptyWidget;

  /// Widget to show when there's an error
  final Widget Function(String error, VoidCallback retry)? errorBuilder;

  /// Widget to show during initial load
  final Widget? loadingWidget;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Threshold to trigger load more (distance from bottom in pixels)
  final double loadMoreThreshold;

  /// Whether to shrink wrap the list
  final bool shrinkWrap;

  /// Scroll controller
  final ScrollController? controller;

  const PaginatedListView({
    super.key,
    required this.state,
    required this.onLoadMore,
    required this.onRefresh,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loadingMoreWidget,
    this.emptyWidget,
    this.errorBuilder,
    this.loadingWidget,
    this.padding,
    this.physics,
    this.loadMoreThreshold = 200,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.state.canLoadMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initial loading state
    if (widget.state.isLoading && widget.state.items.isEmpty) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    // Error state (no items loaded yet)
    if (widget.state.error != null && widget.state.items.isEmpty) {
      return widget.errorBuilder?.call(
            widget.state.error!,
            widget.onRefresh as VoidCallback,
          ) ??
          _buildDefaultError();
    }

    // Empty state
    if (widget.state.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: widget.emptyWidget ?? _buildDefaultEmpty(),
          ),
        ),
      );
    }

    // List with items
    final itemCount =
        widget.state.items.length +
        (widget.state.isLoadingMore || widget.state.hasReachedEnd ? 1 : 0);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.separatorBuilder != null
          ? ListView.separated(
              controller: _scrollController,
              physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              itemCount: itemCount,
              separatorBuilder: widget.separatorBuilder!,
              itemBuilder: _buildItem,
            )
          : ListView.builder(
              controller: _scrollController,
              physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              itemCount: itemCount,
              itemBuilder: _buildItem,
            ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    // Loading more indicator at bottom
    if (index >= widget.state.items.length) {
      if (widget.state.isLoadingMore) {
        return widget.loadingMoreWidget ?? _buildLoadingMore();
      }
      if (widget.state.hasReachedEnd) {
        return _buildEndOfList();
      }
      return const SizedBox.shrink();
    }

    return widget.itemBuilder(context, widget.state.items[index], index);
  }

  Widget _buildDefaultLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDefaultError() {
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
              widget.state.error ?? 'An error occurred',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => widget.onRefresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No items', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'End of list',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Grid view with pagination support
class PaginatedGridView<T> extends StatefulWidget {
  final PaginatedState<T> state;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final double loadMoreThreshold;
  final ScrollController? controller;

  const PaginatedGridView({
    super.key,
    required this.state,
    required this.onLoadMore,
    required this.onRefresh,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.loadMoreThreshold = 200,
    this.controller,
  });

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.state.canLoadMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading && widget.state.items.isEmpty) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (widget.state.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child:
                widget.emptyWidget ??
                Center(
                  child: Text(
                    'No items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          childAspectRatio: widget.childAspectRatio,
        ),
        itemCount: widget.state.items.length,
        itemBuilder: (context, index) =>
            widget.itemBuilder(context, widget.state.items[index], index),
      ),
    );
  }
}
