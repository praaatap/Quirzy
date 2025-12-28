import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/core/widgets/app/app_widgets.dart';
import 'package:quirzy/routes/router.dart';

class QuirzyApp extends ConsumerWidget {
  const QuirzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quirzy',
      debugShowCheckedModeBanner: false,

      // ===========================================
      // 🎨 BLUE + GREEN QUIZ THEME
      // ===========================================
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // System controlled (Light / Dark)

      routerConfig: router,

      // ===========================================
      // 🛠 GLOBAL BUILDER
      // ===========================================
      builder: (context, child) {
        // Production-safe error widget
        ErrorWidget.builder =
            (details) => ProductionErrorWidget(details: details);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Prevent text from breaking layouts
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: Stack(
            children: [
              if (child != null)
                ShowCaseWidget(
                  builder: (context) => child,
                ),

              const ConnectivityOverlay(),
            ],
          ),
        );
      },
    );
  }
}
