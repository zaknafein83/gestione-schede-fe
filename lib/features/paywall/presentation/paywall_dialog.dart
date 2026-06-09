import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../../payment/data/payment_api.dart';

/// Mostra il dialog di paywall.
///
/// Comportamento del bottone "Acquista":
///   1. Chiama `POST /me/billing/checkout`.
///   2. Se il pagamento e' configurato, ritorna {url} → apriamo la pagina di
///      checkout Paddle (checkout.html) sullo stesso tab in web.
///   3. Se NON e' configurato (503 PADDLE_NOT_CONFIGURED), restiamo sul dialog
///      e cambiamo il sottotitolo a "presto disponibile" — flusso graceful:
///      codice live ma feature OFF finche' non si popolano le env vars.
///   4. Errori generici → snackbar.
///
/// Per renderlo riusabile dai vari call site senza dover passare ref
/// ovunque, lo wrappiamo in un ConsumerStatefulWidget interno.
Future<void> showPaywallDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _PaywallDialog(),
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

class _PaywallDialog extends ConsumerStatefulWidget {
  const _PaywallDialog();

  @override
  ConsumerState<_PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends ConsumerState<_PaywallDialog> {
  bool _submitting = false;
  bool _billingUnavailable = false;

  Future<void> _onBuy() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final l10n = AppL10n.of(context);
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) {
        // L'utente dovrebbe essere loggato per arrivare al paywall;
        // se non lo e' chiudiamo silenziosamente.
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final checkout = await ref.read(paymentApiProvider).createCheckout(access);
      // Redirect alla pagina di checkout Paddle (checkout.html). webOnlyWindowName
      // '_self' su web equivale a window.location.
      final uri = Uri.parse(checkout.url);
      await launchUrl(uri, webOnlyWindowName: '_self');
      // Non chiudiamo il dialog: in web la pagina viene rimpiazzata,
      // su mobile l'app resta e il dialog tornerà visibile quando l'utente
      // chiude il browser esterno.
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.status == 503 && e.code == 'PADDLE_NOT_CONFIGURED') {
        setState(() => _billingUnavailable = true);
      } else if (e.status == 400 && e.code == 'ALREADY_PREMIUM') {
        // Edge case: l'utente e' gia' Premium ma per qualche motivo vede
        // ancora il paywall (cache stale). Chiudiamo + suggerimento refresh.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.billingAlreadyPremium)),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.detail)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonNetworkError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      icon: const Icon(Icons.workspace_premium_outlined, size: 40),
      title: Text(l10n.paywallTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paywallBody),
          const SizedBox(height: 12),
          Text(
            _billingUnavailable
                ? l10n.paywallPriceHintComingSoon
                : l10n.paywallPriceHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.paywallClose),
        ),
        if (!_billingUnavailable)
          FilledButton.icon(
            onPressed: _submitting ? null : _onBuy,
            icon: _submitting
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outlined, size: 18),
            label: Text(l10n.paywallBuy),
          ),
      ],
    );
  }
}
