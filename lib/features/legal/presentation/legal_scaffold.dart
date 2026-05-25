import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Data di ultima revisione dei testi legali. Va aggiornata a mano quando si
/// modificano i contenuti delle 4 pagine (privacy, terms, cookies, contact).
const String legalLastUpdatedDate = '25 maggio 2026';

/// Scaffold condiviso per le pagine legali.
///
/// Mostra:
/// - AppBar con titolo + back
/// - Riga "ultimo aggiornamento"
/// - Notice "i testi sono ufficiali in italiano" se la locale corrente non è IT
/// - Slot per il contenuto (lista di Widget, tipicamente costruiti con gli
///   helper [legalH1], [legalP], [legalUl]).
class LegalScaffold extends StatelessWidget {
  const LegalScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String         title;
  final List<Widget>   children;

  @override
  Widget build(BuildContext context) {
    final l10n     = AppL10n.of(context);
    final scheme   = Theme.of(context).colorScheme;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.legalBackToHome,
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isItalian)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.legalOnlyItalianNotice,
                            style: TextStyle(color: scheme.onSurface, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  l10n.legalLastUpdated(legalLastUpdatedDate),
                  style: TextStyle(
                    color: scheme.outline,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.legalBackToHome),
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

// ============================================================================
//                          Helper di composizione testi
// ============================================================================

/// Titolo di primo livello (sezione numerata).
Widget legalH1(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Builder(
        builder: (context) => Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );

/// Titolo di secondo livello.
Widget legalH2(String text) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Builder(
        builder: (context) => Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );

/// Paragrafo normale.
Widget legalP(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Builder(
        builder: (context) => Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
        ),
      ),
    );

/// Lista non ordinata.
Widget legalUl(List<String> items) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Builder(
        builder: (context) {
          final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((it) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(it, style: style)),
                        ],
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
