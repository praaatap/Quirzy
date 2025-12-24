import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Production-friendly error widget
class ProductionErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const ProductionErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ErrorWidget(details.exception);
  }
}
