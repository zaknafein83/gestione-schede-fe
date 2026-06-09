import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_controller.dart';
import 'consent_rows.dart';

/// Mostra il dialog "completa la registrazione" per un nuovo utente Google.
///
/// Diversamente dalla registrazione classica (email/password/displayName), per
/// chi entra con Google chiediamo solo il minimo indispensabile: uno **username**
/// e le due **spunte** (privacy/termini + dichiarazione eta'). L'email è già
/// verificata da Google e il display name viene derivato dal profilo.
///
/// Il dialog esegue lui stesso la chiamata `signInWithGoogle` riusando lo
/// stesso `idToken`: si chiude ritornando `true` solo a login riuscito. Gli
/// errori recuperabili (username già in uso / non valido) vengono mostrati
/// inline così l'utente può correggere senza ripetere il popup Google.
///
/// Ritorna `true` se la registrazione/login è andata a buon fine, altrimenti
/// `null` (annullato).
Future<bool?> showGoogleCompleteRegistrationDialog(
  BuildContext context, {
  required String idToken,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _GoogleCompleteRegistrationDialog(idToken: idToken),
  );
}

class _GoogleCompleteRegistrationDialog extends ConsumerStatefulWidget {
  const _GoogleCompleteRegistrationDialog({required this.idToken});

  final String idToken;

  @override
  ConsumerState<_GoogleCompleteRegistrationDialog> createState() =>
      _GoogleCompleteRegistrationDialogState();
}

class _GoogleCompleteRegistrationDialogState
    extends ConsumerState<_GoogleCompleteRegistrationDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _username = TextEditingController();

  bool _submitting     = false;
  bool _acceptPrivacy  = false;
  bool _declareMinAge  = false;
  bool _showAcceptError = false;
  bool _showAgeError    = false;
  String? _usernameServerError;  // errore lato server (es. username già in uso)

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  String? _validateUsername(AppL10n l10n, String? v) {
    if (v == null || v.trim().isEmpty) return l10n.registerUsernameRequired;
    final s = v.trim();
    if (s.length < 3)  return l10n.registerUsernameMin;
    if (s.length > 30) return l10n.registerUsernameMax;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s)) {
      return l10n.registerUsernameChars;
    }
    return _usernameServerError;  // null se non c'è errore server
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    if (!_acceptPrivacy) setState(() => _showAcceptError = true);
    if (!_declareMinAge) setState(() => _showAgeError    = true);
    if (!formOk || !_acceptPrivacy || !_declareMinAge) return;

    setState(() => _submitting = true);
    final l10n = AppL10n.of(context);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle(
            idToken: widget.idToken,
            acceptPrivacy: true,
            declareMinAge: true,
            username: _username.text.trim(),
          );
      if (!mounted) return;
      final st = ref.read(authControllerProvider);
      if (st.asData?.value != null) {
        Navigator.of(context).pop(true);
        return;
      }
      if (st.hasError) {
        final err = st.error;
        if (err is ApiError &&
            (err.code == 'USERNAME_ALREADY_USED' || err.code == 'INVALID_USERNAME')) {
          // Errore recuperabile: marchiamo il campo e lasciamo il dialog aperto.
          setState(() {
            _usernameServerError = err.code == 'USERNAME_ALREADY_USED'
                ? l10n.googleCompleteUsernameTaken
                : l10n.registerUsernameChars;
          });
          _formKey.currentState!.validate();
        } else {
          final msg = err is ApiError ? err.detail : l10n.loginNetworkError;
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
    return AlertDialog(
      title: Text(l10n.googleCompleteTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.googleCompleteIntro,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _username,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.authUsernameLabel,
                    helperText: l10n.registerUsernameHelper,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => _validateUsername(l10n, v),
                  onChanged: (_) {
                    if (_usernameServerError != null) {
                      setState(() => _usernameServerError = null);
                    }
                  },
                  onFieldSubmitted: (_) => _submitting ? null : _submit(),
                ),
                const SizedBox(height: 16),
                AgeDeclarationRow(
                  value: _declareMinAge,
                  showError: _showAgeError && !_declareMinAge,
                  onChanged: (v) => setState(() {
                    _declareMinAge = v ?? false;
                    if (_declareMinAge) _showAgeError = false;
                  }),
                ),
                const SizedBox(height: 8),
                PrivacyConsentRow(
                  value: _acceptPrivacy,
                  showError: _showAcceptError && !_acceptPrivacy,
                  onChanged: (v) => setState(() {
                    _acceptPrivacy = v ?? false;
                    if (_acceptPrivacy) _showAcceptError = false;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
