import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Riga di link legali (Privacy / Terms / Cookie / Contatti) riutilizzabile
/// in fondo a pagine pubbliche tipo login e register. Layout: Wrap con
/// spacing piccolo, testo outline.
class LegalFooterLinks extends StatelessWidget {
  const LegalFooterLinks({super.key, this.dense = true});

  /// Se true (default) usa font più piccolo e padding minimo — adatto a fondo
  /// pagina di un form. Se false ha più aria.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    final style = TextStyle(
      color: scheme.outline,
      fontSize: dense ? 12 : 13,
    );

    Widget link(String label, String to) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.push(to),
            child: Text(
              label,
              style: style.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        );

    Widget dot() => Text(' · ', style: style);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 8 : 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          link('Prezzi', '/pricing'),
          dot(),
          link(l10n.profileLegalPrivacyLink, '/privacy'),
          dot(),
          link(l10n.profileLegalTermsLink,   '/terms'),
          dot(),
          link('Rimborsi', '/refund'),
          dot(),
          link(l10n.profileLegalCookiesLink, '/cookies'),
          dot(),
          link(l10n.profileLegalContactLink, '/contact'),
        ],
      ),
    );
  }
}
