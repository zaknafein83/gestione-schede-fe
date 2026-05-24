import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Schermata di "ti abbiamo mandato una email": l'utente arriva qui dopo
/// la registrazione. Mostra l'email a cui e' stato inviato il link.
class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkEmailTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 72),
                const SizedBox(height: 16),
                Text(
                  l10n.checkEmailHeader,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: l10n.checkEmailBodyStart),
                      TextSpan(
                        text: email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: l10n.checkEmailBodyEnd),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.actionBackHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
