import 'package:flutter/material.dart';

/// Native-feeling shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius = 12,
    this.child,
    this.isLoading = true,
  });

  /// Creates a circular shimmer
  factory ShimmerLoading.circle({
    Key? key,
    required double size,
    bool isLoading = true,
  }) {
    return ShimmerLoading(
      key: key,
      width: size,
      height: size,
      borderRadius: size / 2,
      isLoading: isLoading,
    );
  }

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest;
    final highlightColor = isDark ? theme.colorScheme.surface : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for list items
class SkeletonListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasSubtitle;
  final bool hasTrailing;

  const SkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            ShimmerLoading.circle(size: 48),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 180, height: 16, borderRadius: 8),
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  const ShimmerLoading(width: 120, height: 12, borderRadius: 6),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            const ShimmerLoading(width: 60, height: 24, borderRadius: 12),
          ],
        ],
      ),
    );
  }
}

/// Skeleton card for grid items
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;

  const SkeletonCard({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height ?? 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          const ShimmerLoading(width: 140, height: 16, borderRadius: 8),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 100, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Animated skeleton screen wrapper
class SkeletonScreen extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const SkeletonScreen({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
