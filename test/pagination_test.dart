import 'package:flutter_test/flutter_test.dart';
import 'package:template/core/utils/pagination.dart';

void main() {
  group('PaginatedState', () {
    test('initial state has correct defaults', () {
      final state = PaginatedState<String>();

      expect(state.items, isEmpty);
      expect(state.currentPage, 1);
      expect(state.pageSize, 20);
      expect(state.isLoading, false);
      expect(state.isLoadingMore, false);
      expect(state.hasReachedEnd, false);
      expect(state.error, isNull);
      expect(state.totalItems, 0);
    });

    test('hasLoaded returns false for initial state', () {
      final state = PaginatedState<String>();
      expect(state.hasLoaded, false);
    });

    test('hasLoaded returns true after items added', () {
      final state = PaginatedState<String>(items: ['item1']);
      expect(state.hasLoaded, true);
    });

    test('hasLoaded returns true when hasReachedEnd', () {
      final state = PaginatedState<String>(hasReachedEnd: true);
      expect(state.hasLoaded, true);
    });

    test('canLoadMore returns true when appropriate', () {
      final state = PaginatedState<String>(items: ['item1']);
      expect(state.canLoadMore, true);
    });

    test('canLoadMore returns false when loading', () {
      final state = PaginatedState<String>(isLoadingMore: true);
      expect(state.canLoadMore, false);
    });

    test('canLoadMore returns false when reached end', () {
      final state = PaginatedState<String>(hasReachedEnd: true);
      expect(state.canLoadMore, false);
    });

    test('isEmpty returns true for empty loaded list', () {
      final state = PaginatedState<String>(hasReachedEnd: true, items: []);
      expect(state.isEmpty, true);
    });

    test('isEmpty returns false when has items', () {
      final state = PaginatedState<String>(items: ['item1']);
      expect(state.isEmpty, false);
    });

    test('loading() sets loading state', () {
      final state = PaginatedState<String>(error: 'old error');
      final loadingState = state.loading();

      expect(loadingState.isLoading, true);
      expect(loadingState.error, isNull);
    });

    test('loadingMore() sets loadingMore state', () {
      final state = PaginatedState<String>();
      final loadingMoreState = state.loadingMore();

      expect(loadingMoreState.isLoadingMore, true);
    });

    test('addPage appends items and increments page', () {
      final state = PaginatedState<String>(items: ['item1', 'item2']);
      final newState = state.addPage(['item3', 'item4']);

      expect(newState.items, ['item1', 'item2', 'item3', 'item4']);
      expect(newState.currentPage, 2);
      expect(newState.isLoading, false);
      expect(newState.isLoadingMore, false);
    });

    test('addPage sets hasReachedEnd when less than pageSize', () {
      final state = PaginatedState<String>(pageSize: 10);
      final newState = state.addPage(['item1', 'item2', 'item3']);

      expect(newState.hasReachedEnd, true);
    });

    test('replaceItems replaces all items', () {
      final state = PaginatedState<String>(
        items: ['old1', 'old2'],
        currentPage: 5,
      );
      final newState = state.replaceItems(['new1', 'new2']);

      expect(newState.items, ['new1', 'new2']);
      expect(newState.currentPage, 1);
    });

    test('withError sets error state', () {
      final state = PaginatedState<String>(isLoading: true);
      final errorState = state.withError('Something went wrong');

      expect(errorState.error, 'Something went wrong');
      expect(errorState.isLoading, false);
      expect(errorState.isLoadingMore, false);
    });

    test('updateItem updates item at index', () {
      final state = PaginatedState<String>(items: ['a', 'b', 'c']);
      final newState = state.updateItem(1, 'updated');

      expect(newState.items, ['a', 'updated', 'c']);
    });

    test('updateItem returns same state for invalid index', () {
      final state = PaginatedState<String>(items: ['a', 'b']);
      final newState = state.updateItem(5, 'invalid');

      expect(newState, state);
    });

    test('removeItem removes item at index', () {
      final state = PaginatedState<String>(
        items: ['a', 'b', 'c'],
        totalItems: 3,
      );
      final newState = state.removeItem(1);

      expect(newState.items, ['a', 'c']);
      expect(newState.totalItems, 2);
    });

    test('prependItem adds item at beginning', () {
      final state = PaginatedState<String>(items: ['b', 'c'], totalItems: 2);
      final newState = state.prependItem('a');

      expect(newState.items, ['a', 'b', 'c']);
      expect(newState.totalItems, 3);
    });

    test('appendItem adds item at end', () {
      final state = PaginatedState<String>(items: ['a', 'b'], totalItems: 2);
      final newState = state.appendItem('c');

      expect(newState.items, ['a', 'b', 'c']);
      expect(newState.totalItems, 3);
    });

    test('reset returns initial state with same pageSize', () {
      final state = PaginatedState<String>(
        items: ['a', 'b'],
        currentPage: 5,
        pageSize: 50,
        isLoading: true,
      );
      final resetState = state.reset();

      expect(resetState.items, isEmpty);
      expect(resetState.currentPage, 1);
      expect(resetState.pageSize, 50);
      expect(resetState.isLoading, false);
    });

    test('totalPages calculates correctly', () {
      final state = PaginatedState<String>(totalItems: 95, pageSize: 20);
      expect(state.totalPages, 5);
    });
  });
}
