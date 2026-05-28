import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Atterraggio quando l'utente chiude Stripe Checkout senza pagare.
/// Stripe redirige qui via cancel_url. Nessun pagamento e' stato fatto,
/// rassicurazione + bottone per tornare alla home.
class BillingCancelScreen extends StatelessWidget {
  const BillingCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.billingCancelTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(l10n.billingCancelHeading,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(l10n.billingCancelBody, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(l10n.billingCancelCtaHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
