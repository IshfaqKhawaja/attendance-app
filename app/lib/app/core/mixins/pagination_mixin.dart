import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Mixin for handling pagination in lists
mixin PaginationMixin<T> on GetxController {
  final RxList<T> _items = <T>[].obs;
  final RxInt _currentPage = 0.obs;
  final RxInt _totalPages = 0.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasReachedEnd = false.obs;
  final int _itemsPerPage = 20;
  
  /// Current list of items
  List<T> get items => _items.toList();
  
  /// Current page number
  int get currentPage => _currentPage.value;
  
  /// Total number of pages
  int get totalPages => _totalPages.value;
  
  /// Whether currently loading more items
  bool get isLoadingMore => _isLoadingMore.value;
  
  /// Whether reached end of data
  bool get hasReachedEnd => _hasReachedEnd.value;
  
  /// Items per page
  int get itemsPerPage => _itemsPerPage;
  
  /// Load first page
  Future<void> loadFirstPage() async {
    _currentPage.value = 0;
    _items.clear();
    _hasReachedEnd.value = false;
    await loadNextPage();
  }
  
  /// Load next page
  Future<void> loadNextPage() async {
    if (_isLoadingMore.value || _hasReachedEnd.value) return;
    
    _isLoadingMore.value = true;
    
    try {
      final result = await fetchPage(_currentPage.value + 1, _itemsPerPage);
      
      if (result.items.isEmpty) {
        _hasReachedEnd.value = true;
      } else {
        _currentPage.value++;
        _items.addAll(result.items);
        _totalPages.value = result.totalPages;
        
        if (_currentPage.value >= result.totalPages) {
          _hasReachedEnd.value = true;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load more items: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }
  
  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await loadFirstPage();
  }
  
  /// Add new item to the beginning
  void addItem(T item) {
    _items.insert(0, item);
  }
  
  /// Remove item
  void removeItem(T item) {
    _items.remove(item);
  }
  
  /// Update item
  void updateItem(T oldItem, T newItem) {
    final index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
    }
  }
  
  /// Clear all items
  void clearItems() {
    _items.clear();
    _currentPage.value = 0;
    _totalPages.value = 0;
    _hasReachedEnd.value = false;
  }
  
  /// Abstract method to fetch page data - must be implemented by using class
  Future<PaginationResult<T>> fetchPage(int page, int limit);
}

/// Result wrapper for pagination
class PaginationResult<T> {
  final List<T> items;
  final int totalPages;
  final int currentPage;
  final int totalItems;
  
  const PaginationResult({
    required this.items,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });
}

/// Widget for handling list with pagination
class PaginatedListView<T> extends StatelessWidget {
  final GetxController controller;
  final List<T> Function() itemsProvider;
  final bool Function() isLoadingProvider;
  final bool Function() hasReachedEndProvider;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final Widget Function(T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final ScrollController? scrollController;
  
  const PaginatedListView({
    Key? key,
    required this.controller,
    required this.itemsProvider,
    required this.isLoadingProvider,
    required this.hasReachedEndProvider,
    required this.onLoadMore,
    required this.onRefresh,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.scrollController,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GetxController>(
      init: controller,
      builder: (_) {
        final items = itemsProvider();
        
        if (items.isEmpty) {
          return emptyWidget ?? const Center(
            child: Text('No items found'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!isLoadingProvider() && 
                  !hasReachedEndProvider() &&
                  scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                onLoadMore();
              }
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: items.length + (isLoadingProvider() ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return loadingWidget ?? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return itemBuilder(items[index], index);
              },
            ),
          ),
        );
      },
    );
  }
}