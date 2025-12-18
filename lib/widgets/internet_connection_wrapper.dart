import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/connection_provider.dart';
import 'package:quirzy/screen/NoInternetScreen.dart';

class InternetConnectionWrapper extends ConsumerWidget {
  final Widget child;
  
  const InternetConnectionWrapper({
    super.key,
    required this.child,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);
    
    return connectionState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (hasConnection) {
        if (!hasConnection) {
          return NoInternetScreen(
            onRetry: () => ref.refresh(connectionProvider.future),
          );
        }
        return child;
      },
    );
  }
}