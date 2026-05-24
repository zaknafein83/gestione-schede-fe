import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_api.dart';

/// Schermata raggiunta dal link nell'email: /verify-email?token=XXX
/// Chiama il backend e mostra esito.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(authApiProvider).verifyEmail(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyEmailTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<void>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.verifyEmailWaiting),
                    ],
                  );
                }
                if (snap.hasError) {
                  final err = snap.error;
                  final message = err is ApiError
                      ? err.detail
                      : l10n.verifyEmailUnexpected(err.toString());
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 72, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        l10n.verifyEmailFailed,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: Text(l10n.actionBackHome),
                      ),
                    ],
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 72, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      l10n.verifyEmailOk,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verifyEmailOkBody,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.actionGoHome),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
