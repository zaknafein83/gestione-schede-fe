import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Riga di autocertificazione eta' minima (art. 8 GDPR + art. 2-quinquies
/// D.Lgs 101/2018, soglia 14 anni in Italia). Checkbox separata dal consenso
/// privacy per non bundlare due dichiarazioni eterogenee.
///
/// Condivisa fra la registrazione classica e il dialog "completa registrazione"
/// del flusso Google.
class AgeDeclarationRow extends StatelessWidget {
  const AgeDeclarationRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.showError,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    final baseStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: scheme.onSurface,
      fontSize: 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(value: value, onChanged: onChanged),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(l10n.registerAgeDeclaration, style: baseStyle),
                ),
              ],
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              l10n.registerAgeRequired,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Riga di consenso GDPR: checkbox + testo "Ho letto e accetto la Privacy e
/// i Termini" con i link cliccabili che aprono /privacy e /terms.
///
/// Mostra un messaggio di errore rosso sotto quando [showError] è true.
/// Condivisa fra la registrazione classica e il dialog "completa
/// registrazione" del flusso Google.
class PrivacyConsentRow extends StatelessWidget {
  const PrivacyConsentRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.showError,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    // Stile esplicito: non usare DefaultTextStyle.of(context).style perche'
    // dentro un Form su tema scuro restituisce un colore nero che rende il
    // testo invisibile su sfondo dark (Material 3 / Flutter web mobile).
    final baseStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: scheme.onSurface,
      fontSize: 14,
    );
    final linkStyle = baseStyle.copyWith(
      color: scheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tap sull'intera riga (checkbox + testo) commuta lo stato — facilita
        // il targeting su mobile. I tap sui link Privacy/ToS hanno priorita'
        // grazie ai TapGestureRecognizer nei TextSpan.
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: value,
                  onChanged: onChanged,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: baseStyle,
                      children: [
                        TextSpan(text: l10n.registerAcceptPart1),
                        TextSpan(
                          text: l10n.registerPrivacyLink,
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/privacy'),
                        ),
                        TextSpan(text: l10n.registerAcceptPart2),
                        TextSpan(
                          text: l10n.registerTermsLink,
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/terms'),
                        ),
                        TextSpan(text: l10n.registerAcceptPart3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              l10n.registerAcceptRequired,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
