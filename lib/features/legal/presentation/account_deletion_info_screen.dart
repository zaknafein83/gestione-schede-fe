import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Pagina pubblica raggiungibile via URL diretto `/account-deletion-info`.
///
/// Serve a soddisfare il requisito Google Play (Data Safety) di esporre una
/// pagina web pubblica che spieghi come cancellare il proprio account, anche
/// per utenti che non hanno installato/aperto l'app. È bilingue (usa l10n).
class AccountDeletionInfoScreen extends StatelessWidget {
  const AccountDeletionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final t      = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deletionInfoTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.deletionInfoBackHome,
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card "azione rapida"
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.delete_forever_outlined, color: scheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.deletionInfoIntro,
                                style: t.bodyMedium?.copyWith(height: 1.5)),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              icon: const Icon(Icons.login),
                              label: Text(l10n.deletionInfoLoginBtn),
                              onPressed: () => context.push('/login'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(l10n.deletionInfoStepsTitle,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _Step(n: 1, text: l10n.deletionInfoStep1),
                _Step(n: 2, text: l10n.deletionInfoStep2),
                _Step(n: 3, text: l10n.deletionInfoStep3),
                _Step(n: 4, text: l10n.deletionInfoStep4),

                const SizedBox(height: 32),
                Text(l10n.deletionInfoWhatRemovedTitle,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(l10n.deletionInfoWhatRemoved, style: t.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 8),
                _Bullet(l10n.deletionInfoBullet1),
                _Bullet(l10n.deletionInfoBullet2),
                _Bullet(l10n.deletionInfoBullet3),
                _Bullet(l10n.deletionInfoBullet4),
                _Bullet(l10n.deletionInfoBullet5),

                const SizedBox(height: 32),
                Text(l10n.deletionInfoCannotLoginTitle,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(l10n.deletionInfoCannotLogin, style: t.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 12),
                SelectableText(
                  l10n.deletionInfoEmail,
                  style: t.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.deletionInfoBackHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text});
  final int    n;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ),
        ],
      ),
    );
  }
}
