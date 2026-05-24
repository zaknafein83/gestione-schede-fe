import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/locale.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const ProviderScope(child: DndSheetsApp()));
}

class DndSheetsApp extends ConsumerWidget {
  const DndSheetsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;
    final locale    = ref.watch(localeProvider).asData?.value;

    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppL10n.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      theme:     buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      locale:    locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
