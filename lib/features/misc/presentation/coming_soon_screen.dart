import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Pagina "lavori in corso" parametrizzata via query string `?for=...`.
///
/// Valori riconosciuti per `topic`:
///   - `ios`     → app iPhone/iPad in arrivo
///   - `android` → app Android in arrivo
///   - `spells`  → catalogo spell pubblico in arrivo
///   - `null` / altro → messaggio generico
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, this.topic});

  final String? topic;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (icon, message) = switch (topic) {
      'ios'     => (Icons.phone_iphone,    l10n.comingSoonIos),
      'android' => (Icons.android,         l10n.comingSoonAndroid),
      'spells'  => (Icons.auto_stories,    l10n.comingSoonSpells),
      _         => (Icons.construction,    l10n.comingSoonGeneric),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icona grande dentro un container circolare
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.comingSoonTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.comingSoonStayTuned,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(l10n.comingSoonBack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
