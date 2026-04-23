// lib/app.dart
//
// Root widget. Wires together:
//   - go_router (navigation)
//   - AppTheme (dark/light, user-switchable)
//   - AppLocalizations (EN + IT + stubs)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

class ClassSchedulerApp extends ConsumerWidget {
  const ClassSchedulerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale    = ref.watch(localeProvider);
    final router    = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ClassScheduler',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────────
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  themeMode,

      // ── Routing ───────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localisation ──────────────────────────────────────────────────
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // FR-I18N-03: auto-detect; fall back to English if unsupported
        if (deviceLocale == null) return kDefaultLocale;
        for (final supported in supportedLocales) {
          if (supported.languageCode == deviceLocale.languageCode) {
            return supported;
          }
        }
        return kDefaultLocale;
      },
    );
  }
}
