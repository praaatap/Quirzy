import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-adaptive pull-to-refresh widget
/// Uses CupertinoSliverRefreshControl on iOS and RefreshIndicator on Android
class AdaptiveRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool isSliver;

  const AdaptiveRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (Platform.isIOS) {
      if (isSliver) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
            SliverToBoxAdapter(child: child),
          ],
        );
      }
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverFillRemaining(child: child),
        ],
      );
    }

    // Android - Material refresh indicator
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}

/// Adaptive refresh for scrollable lists
class AdaptiveRefreshList extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Widget? header;
  final Widget? footer;
  final bool shrinkWrap;

  const AdaptiveRefreshList({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.controller,
    this.header,
    this.footer,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (Platform.isIOS) {
      return CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          if (header != null) SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (separator != null) {
                  final itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    return separator;
                  }
                  if (itemIndex >= itemCount) return null;
                  return itemBuilder(context, itemIndex);
                }
                return itemBuilder(context, index);
              }, childCount: separator != null ? itemCount * 2 - 1 : itemCount),
            ),
          ),
          if (footer != null) SliverToBoxAdapter(child: footer),
        ],
      );
    }

    // Android
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: ListView.builder(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            itemCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (header != null && index == 0) return header!;
          if (footer != null && index == itemCount + (header != null ? 1 : 0)) {
            return footer!;
          }
          final adjustedIndex = index - (header != null ? 1 : 0);
          return itemBuilder(context, adjustedIndex);
        },
      ),
    );
  }
}
