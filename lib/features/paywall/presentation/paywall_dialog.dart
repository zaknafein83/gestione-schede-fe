import 'package:flutter/material.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';

/// Mostra il paywall placeholder. Per ora nessuna CTA di pagamento — i
/// pagamenti reali arriveranno con MVP-6 (IAP mobile + Stripe web).
Future<void> showPaywallDialog(BuildContext context) {
  final l10n = AppL10n.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.workspace_premium_outlined, size: 40),
      title: Text(l10n.paywallTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paywallBody),
          const SizedBox(height: 12),
          Text(
            l10n.paywallPriceHint,
            style: Theme.of(ctx).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.paywallOk),
        ),
      ],
    ),
  );
}

/// Helper: se l'errore e' un 402 TIER_LIMIT_REACHED, mostra il paywall.
/// Altrimenti ritorna false e il chiamante puo' mostrare il fallback.
Future<bool> maybeShowPaywall(BuildContext context, Object error) async {
  if (error is ApiError && error.status == 402 && error.code == 'TIER_LIMIT_REACHED') {
    await showPaywallDialog(context);
    return true;
  }
  return false;
}
