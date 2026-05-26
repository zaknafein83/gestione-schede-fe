import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../legal/presentation/legal_footer_links.dart';
import '../data/auth_api.dart';
import '../models/auth_models.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email       = TextEditingController();
  final _password    = TextEditingController();
  final _confirmPwd  = TextEditingController();
  final _username    = TextEditingController();
  final _displayName = TextEditingController();

  bool _submitting    = false;
  bool _showPassword  = false;
  bool _acceptPrivacy = false;
  bool _showAcceptError = false;  // mostra l'errore solo dopo un tentativo di submit

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPwd.dispose();
    _username.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    // Privacy/Terms vanno spuntati — controllo separato dal Form (è uno stato)
    if (!_acceptPrivacy) {
      setState(() => _showAcceptError = true);
    }
    if (!formOk || !_acceptPrivacy) return;

    setState(() => _submitting = true);

    final req = RegisterRequest(
      email:         _email.text.trim().toLowerCase(),
      password:      _password.text,
      username:      _username.text.trim(),
      displayName:   _displayName.text.trim(),
      acceptPrivacy: _acceptPrivacy,
    );

    try {
      await ref.read(authApiProvider).register(req);
      if (!mounted) return;
      context.go('/check-email', extra: req.email);
    } on ApiError catch (e) {
      if (!mounted) return;
      // Caso particolare: la validazione backend del consenso GDPR risponde
      // con detail "acceptPrivacy: ...". Lo rendiamo user-friendly mostrando
      // il messaggio i18n e evidenziando la checkbox.
      if (e.detail.contains('acceptPrivacy')) {
        setState(() => _showAcceptError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).registerAcceptRequired)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).commonNetworkError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ----- validators (prendono l10n per i messaggi) -----

  String? _validateEmail(AppL10n l10n, String? v) {
    if (v == null || v.trim().isEmpty) return l10n.registerEmailRequired;
    final s = v.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s)) {
      return l10n.registerEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(AppL10n l10n, String? v) {
    if (v == null || v.isEmpty) return l10n.registerPasswordRequired;
    if (v.length < 10)       return l10n.registerPasswordMin;
    if (v.length > 100)      return l10n.registerPasswordMax;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return l10n.registerPasswordUpper;
    if (!RegExp(r'\d').hasMatch(v))    return l10n.registerPasswordDigit;
    return null;
  }

  String? _validateConfirmPwd(AppL10n l10n, String? v) {
    if (v != _password.text) return l10n.registerPasswordsMismatch;
    return null;
  }

  String? _validateUsername(AppL10n l10n, String? v) {
    if (v == null || v.trim().isEmpty) return l10n.registerUsernameRequired;
    final s = v.trim();
    if (s.length < 3)  return l10n.registerUsernameMin;
    if (s.length > 30) return l10n.registerUsernameMax;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s)) {
      return l10n.registerUsernameChars;
    }
    return null;
  }

  String? _validateDisplayName(AppL10n l10n, String? v) {
    if (v == null || v.trim().isEmpty) return l10n.registerDisplayRequired;
    if (v.trim().length > 60) return l10n.registerDisplayMax;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
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
                      validator: (v) => _validateEmail(l10n, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _username,
                      decoration: InputDecoration(
                        labelText: l10n.authUsernameLabel,
                        helperText: l10n.registerUsernameHelper,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => _validateUsername(l10n, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _displayName,
                      decoration: InputDecoration(
                        labelText: l10n.authDisplayNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => _validateDisplayName(l10n, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.authPasswordLabel,
                        helperText: l10n.registerPasswordHelper,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          tooltip: _showPassword
                              ? l10n.registerPasswordHide
                              : l10n.registerPasswordShow,
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) => _validatePassword(l10n, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPwd,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: l10n.registerConfirmLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => _validateConfirmPwd(l10n, v),
                    ),
                    const SizedBox(height: 16),
                    _PrivacyConsentRow(
                      value: _acceptPrivacy,
                      showError: _showAcceptError && !_acceptPrivacy,
                      onChanged: (v) => setState(() {
                        _acceptPrivacy = v ?? false;
                        if (_acceptPrivacy) _showAcceptError = false;
                      }),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _submitting
                            ? const SizedBox(
                                height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.authBtnRegister),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LegalFooterLinks(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Riga di consenso GDPR: checkbox + testo "Ho letto e accetto la Privacy e
/// i Termini" con i link cliccabili che aprono /privacy e /terms.
///
/// Mostra un messaggio di errore rosso sotto quando [showError] è true.
class _PrivacyConsentRow extends StatelessWidget {
  const _PrivacyConsentRow({
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
