import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget de liste virtualisée pour optimiser les performances
/// 
/// Utilise ListView.builder avec optimisations :
/// - Réutilisation des widgets
/// - Chargement paresseux
/// - Gestion du cache
/// - Optimisation du scrolling
class VirtualizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? itemExtent;
  final int? cacheExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final Widget? separator;
  final bool reverse;
  final Axis scrollDirection;

  const VirtualizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.itemExtent,
    this.cacheExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.separator,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<VirtualizedList<T>> createState() => _VirtualizedListState<T>();
}

class _VirtualizedListState<T> extends State<VirtualizedList<T>> {
  late ScrollController _scrollController;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        // Peut être utilisé pour masquer des éléments UI lors du scroll vers le bas
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        // Peut être utilisé pour afficher des éléments UI lors du scroll vers le haut
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si les données sont en cours de chargement
    if (widget.items.isEmpty && widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    // Si la liste est vide
    if (widget.items.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    // Si on a un séparateur, utiliser ListView.separated
    if (widget.separator != null) {
      return ListView.separated(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        padding: widget.padding,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: (widget.cacheExtent ?? 250.0).toDouble(), // Zone de cache par défaut
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => widget.separator!,
        itemBuilder: (context, index) {
          return _buildItem(context, index);
        },
      );
    }

    // Sinon utiliser ListView.builder
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      itemExtent: widget.itemExtent, // Hauteur fixe des items si définie
      cacheExtent: (widget.cacheExtent ?? 250.0).toDouble(),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.items[index];
    
    // Ajouter une clé unique pour optimiser la réutilisation
    return KeyedSubtree(
      key: ValueKey('item_$index'),
      child: widget.itemBuilder(context, item, index),
    );
  }
}

/// Extension pour créer facilement une liste virtualisée sliver
class VirtualizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final Widget? separator;

  const VirtualizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.separator,
  });

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final itemIndex = index ~/ 2;
            if (index.isEven) {
              return KeyedSubtree(
                key: ValueKey('item_$itemIndex'),
                child: itemBuilder(context, items[itemIndex], itemIndex),
              );
            }
            return separator!;
          },
          childCount: items.length * 2 - 1,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          addSemanticIndexes: true,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return KeyedSubtree(
            key: ValueKey('item_$index'),
            child: itemBuilder(context, items[index], index),
          );
        },
        childCount: items.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
      ),
    );
  }
}

/// Widget pour listes avec pagination infinie
class InfiniteVirtualizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<List<T>> Function() onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const InfiniteVirtualizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<InfiniteVirtualizedList<T>> createState() => _InfiniteVirtualizedListState<T>();
}

class _InfiniteVirtualizedListState<T> extends State<InfiniteVirtualizedList<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  List<T> _allItems = [];

  @override
  void initState() {
    super.initState();
    _allItems = List.from(widget.items);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      setState(() {
        _isLoadingMore = true;
      });

      try {
        final newItems = await widget.onLoadMore();
        if (mounted) {
          setState(() {
            _allItems.addAll(newItems);
            _isLoadingMore = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allItems.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 250.0,
      itemCount: _allItems.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allItems.length) {
          return widget.loadingWidget ?? 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
        }

        return KeyedSubtree(
          key: ValueKey('item_$index'),
          child: widget.itemBuilder(context, _allItems[index], index),
        );
      },
    );
  }
}