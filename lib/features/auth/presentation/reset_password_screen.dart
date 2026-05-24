import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_api.dart';

/// Schermata di reset password: l'utente arriva dal link nella mail
/// (`/reset-password?token=XXX`), sceglie una nuova password e conferma.
///
/// Al successo, il backend revoca tutti i refresh token attivi: l'utente
/// deve fare login con la nuova password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  bool _show       = false;
  bool _submitting = false;
  bool _done       = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validatePassword(AppL10n l10n, String? v) {
    if (v == null || v.isEmpty) return l10n.registerPasswordRequired;
    if (v.length < 10) return l10n.registerPasswordMin;
    if (v.length > 100) return l10n.registerPasswordMax;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return l10n.registerPasswordUpper;
    if (!RegExp(r'\d').hasMatch(v))    return l10n.registerPasswordDigit;
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authApiProvider).resetPassword(widget.token, _password.text);
      if (!mounted) return;
      setState(() => _done = true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).commonNetworkError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (widget.token.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(l10n.resetPasswordMissingToken,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: Text(l10n.resetPasswordRequestNew),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _done ? _DoneView() : _formView(l10n),
          ),
        ),
      ),
    );
  }

  Widget _formView(AppL10n l10n) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.resetPasswordIntro,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _password,
            obscureText: !_show,
            autofillHints: const [AutofillHints.newPassword],
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.changePwdNewLabel,
              helperText: l10n.changePwdNewHelper,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _show = !_show),
              ),
            ),
            validator: (v) => _validatePassword(l10n, v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: !_show,
            decoration: InputDecoration(
              labelText: l10n.changePwdConfirmLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                v == _password.text ? null : l10n.registerPasswordsMismatch,
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
                  : Text(l10n.resetPasswordSubmit),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified, size: 72, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          l10n.resetPasswordDoneTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.resetPasswordDoneBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/login'),
          child: Text(l10n.authBtnLogin),
        ),
      ],
    );
  }
}
