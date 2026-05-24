import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';

/// Mostra il dialog di cambio password. Ritorna `true` se la password e' stata
/// cambiata con successo (e l'utente e' stato deslogato), altrimenti `null`.
Future<bool?> showChangePasswordDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPwd  = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _submitting = false;

  @override
  void dispose() {
    _current.dispose();
    _newPwd.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateNew(AppL10n l10n, String? v) {
    if (v == null || v.isEmpty) return l10n.changePwdNewRequired;
    if (v.length < 10) return l10n.registerPasswordMin;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return l10n.registerPasswordUpper;
    if (!RegExp(r'\d').hasMatch(v))    return l10n.registerPasswordDigit;
    if (v == _current.text) return l10n.changePwdMustDiffer;
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier)
              .changePassword(_current.text, _newPwd.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).commonErrorPrefix(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(l10n.changePwdTitle),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: !_show,
              decoration: InputDecoration(
                labelText: l10n.changePwdCurrentLabel,
                suffixIcon: IconButton(
                  icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _show = !_show),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? l10n.changePwdRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPwd,
              obscureText: !_show,
              decoration: InputDecoration(
                labelText: l10n.changePwdNewLabel,
                helperText: l10n.changePwdNewHelper,
              ),
              validator: (v) => _validateNew(l10n, v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: !_show,
              decoration: InputDecoration(labelText: l10n.changePwdConfirmLabel),
              validator: (v) =>
                  v == _newPwd.text ? null : l10n.registerPasswordsMismatch,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.changePwdLogoutWarning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.changePwdSubmit),
        ),
      ],
    );
  }
}
