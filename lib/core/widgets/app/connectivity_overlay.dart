import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/connection_provider.dart';
import 'package:quirzy/core/widgets/connectivity/no_internet_screen.dart';

/// Displays overlay when internet is unavailable
class ConnectivityOverlay extends ConsumerWidget {
  const ConnectivityOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);

    return connectionState.when(
      data: (hasConnection) {
        if (!hasConnection) {
          return Positioned.fill(
            child: NoInternetScreen(
              onRetry: () => ref.invalidate(connectionProvider),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
