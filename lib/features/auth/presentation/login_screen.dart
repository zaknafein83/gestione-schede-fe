import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../core/google_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../legal/presentation/legal_footer_links.dart';
import '../data/auth_controller.dart';
import 'google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// Divisore orizzontale con etichetta centrale tipo "OPPURE". Usato fra il
/// form e il blocco Google sign-in.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _submitting   = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            _email.text.trim().toLowerCase(),
            _password.text,
          );
      // Se il login e' andato a buon fine, lo stato e' AsyncData(UserDto).
      // Il router redirect ci portera' automaticamente su /home, ma per
      // coerenza UX facciamo anche un push esplicito qui.
      if (!mounted) return;
      final st = ref.read(authControllerProvider);
      if (st.asData?.value != null) {
        context.go('/home');
      } else if (st.hasError) {
        final err = st.error;
        final msg = err is ApiError ? err.detail : AppL10n.of(context).loginNetworkError;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Callback invocata dal widget Google Sign-In quando GIS consegna un ID
  /// token. Tenta il login: se l'utente non e' mai stato visto e il backend
  /// risponde 400 PRIVACY_NOT_ACCEPTED o AGE_NOT_DECLARED, suggerisce di
  /// registrarsi (dove troverà entrambe le checkbox).
  Future<void> _onGoogleCredential(String idToken) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle(
            idToken: idToken,
            acceptPrivacy: false,
            declareMinAge: false,
          );
      if (!mounted) return;
      final st = ref.read(authControllerProvider);
      if (st.asData?.value != null) {
        context.go('/home');
      } else if (st.hasError) {
        final err = st.error;
        if (err is ApiError &&
            (err.code == 'PRIVACY_NOT_ACCEPTED' || err.code == 'AGE_NOT_DECLARED')) {
          // L'utente Google e' nuovo: la registrazione richiede la spunta
          // privacy e la dichiarazione di eta'. Lo mandiamo su /register dove
          // troverà il flusso completo (checkbox + bottone Google).
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppL10n.of(context).loginGoogleNeedsRegister)),
          );
          context.go('/register');
        } else {
          final msg = err is ApiError ? err.detail : AppL10n.of(context).loginNetworkError;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginAccessTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.authEmailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.loginEmailRequired;
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                        return l10n.loginEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: !_showPassword,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.authPasswordLabel,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.loginPasswordRequired : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _submitting
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.authBtnLogin),
                    ),
                  ),
                  if (isGoogleAuthEnabled) ...[
                    const SizedBox(height: 20),
                    _OrDivider(label: l10n.authOrDivider),
                    const SizedBox(height: 16),
                    Center(
                      child: GoogleSignInButtonWidget(
                        onCredential: _onGoogleCredential,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(l10n.loginForgotPassword),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(l10n.loginGoRegister),
                  ),
                  const SizedBox(height: 16),
                  const LegalFooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
