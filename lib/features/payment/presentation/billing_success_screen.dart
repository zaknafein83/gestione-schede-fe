import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_storage.dart';

/// Pagina di atterraggio dopo che Stripe redirige l'utente post-pagamento.
///
/// Il webhook arriva server-to-server (asincrono): potrebbe essere processato
/// PRIMA o DOPO che il browser arriva qui. Strategia: poll `GET /me` ogni 2s
/// per max 30s, finche' `tier == PREMIUM`. Poi refresh dello stato auth e
/// mostra CTA "Vai alle schede".
///
/// Se 30s passano senza esito, suggerisci all'utente di ricontrollare piu'
/// tardi (il webhook arrivera' comunque, l'addebito Stripe e' affidabile).
class BillingSuccessScreen extends ConsumerStatefulWidget {
  const BillingSuccessScreen({super.key, this.sessionId});

  /// session_id Stripe (query param). Non lo usiamo lato client per nulla
  /// di security-critical — la verifica vera e' lato webhook.
  final String? sessionId;

  @override
  ConsumerState<BillingSuccessScreen> createState() => _BillingSuccessScreenState();
}

class _BillingSuccessScreenState extends ConsumerState<BillingSuccessScreen> {
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  bool _isPremium = false;
  bool _timedOut  = false;
  int  _polls     = 0;

  static const _pollInterval   = Duration(seconds: 2);
  static const _maxPollSeconds = 30;

  @override
  void initState() {
    super.initState();
    // Primo check immediato
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPremium());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPremium());
    _timeoutTimer = Timer(const Duration(seconds: _maxPollSeconds), () {
      if (mounted && !_isPremium) {
        setState(() => _timedOut = true);
        _pollTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPremium() async {
    if (!mounted || _isPremium) return;
    _polls++;
    try {
      final token = await ref.read(authStorageProvider).loadAccess();
      if (token == null) return;
      final user = await ref.read(authApiProvider).me(token);
      if (user.isPremium && mounted) {
        setState(() => _isPremium = true);
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        // Aggiorna lo stato auth globale (rifrescha tier visibile dalle UI)
        ref.invalidate(authControllerProvider);
      }
    } catch (_) {
      // Errori transienti: il prossimo tick riprovera'.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billingSuccessTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _isPremium
                ? _confirmed(l10n)
                : _timedOut
                    ? _pending(l10n)
                    : _waiting(l10n),
          ),
        ),
      ),
    );
  }

  Widget _waiting(AppL10n l10n) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            l10n.billingSuccessWaiting,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.billingSuccessPollAttempt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );

  Widget _confirmed(AppL10n l10n) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium, size: 80,
              color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 16),
          Text(l10n.billingSuccessConfirmedTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(l10n.billingSuccessConfirmedBody,
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go('/characters'),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(l10n.billingSuccessCtaCharacters),
          ),
        ],
      );

  Widget _pending(AppL10n l10n) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 64,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(l10n.billingSuccessPendingTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(l10n.billingSuccessPendingBody,
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            child: Text(l10n.billingSuccessCtaHome),
          ),
        ],
      );
}
