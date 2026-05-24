import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';

/// Dialog conferma cancellazione account. L'utente deve:
///  1. Digitare il proprio username come "spell check" anti-click-accidentale
///  2. Inserire la password attuale
///
/// Ritorna `true` se l'account è stato cancellato (e l'utente sloggato),
/// `null` se annulla, `false` se errore.
Future<bool?> showDeleteAccountDialog(BuildContext context, {required String expectedUsername}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _DeleteAccountDialog(expectedUsername: expectedUsername),
  );
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.expectedUsername});
  final String expectedUsername;

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _show       = false;
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount(_password.text);
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
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: scheme.error, size: 40),
      title: Text(l10n.deleteAccountTitle),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.deleteAccountWarning,
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteAccountBullets,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _username,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.deleteAccountTypeUsername(widget.expectedUsername),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonRequired;
                  if (v.trim() != widget.expectedUsername) {
                    return l10n.deleteAccountUsernameMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: !_show,
                decoration: InputDecoration(
                  labelText: l10n.deleteAccountPasswordLabel,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _show = !_show),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.commonRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.deleteAccountConfirmBtn),
        ),
      ],
    );
  }
}
