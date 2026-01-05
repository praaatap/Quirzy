import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/features/settings/providers/settings_provider.dart';
import 'package:quirzy/core/widgets/app/app_widgets.dart';
import 'package:quirzy/routes/router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

class QuirzyApp extends ConsumerWidget {
  const QuirzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Use select() to only rebuild when theme-related settings change
    // This prevents unnecessary rebuilds when other settings change
    final useSystemTheme = ref.watch(
      settingsProvider.select((s) => s.useSystemTheme),
    );
    final darkMode = ref.watch(settingsProvider.select((s) => s.darkMode));
    final currentLocale = ref.watch(settingsProvider.select((s) => s.locale));

    final themeMode = useSystemTheme
        ? ThemeMode.system
        : (darkMode ? ThemeMode.dark : ThemeMode.light);

    return MaterialApp.router(
      title: 'Quirzy',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      routerConfig: router,

      // ===========================================
      // 🛠 GLOBAL BUILDER
      // ===========================================
      builder: (context, child) {
        // Production-safe error widget
        ErrorWidget.builder = (details) =>
            ProductionErrorWidget(details: details);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: Stack(
            children: [
              if (child != null) ShowCaseWidget(builder: (context) => child),

              const ConnectivityOverlay(),
            ],
          ),
        );
      },
    );
  }
}
