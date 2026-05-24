import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../data/shares_api.dart';

/// Apre il dialog "Condividi scheda" per la scheda con [characterId].
Future<void> showShareDialog(BuildContext context, String characterId) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ShareDialog(characterId: characterId),
  );
}

class _ShareDialog extends ConsumerStatefulWidget {
  const _ShareDialog({required this.characterId});
  final String characterId;

  @override
  ConsumerState<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<_ShareDialog> {
  bool _loading = true;
  bool _working = false;
  String? _error;

  ShareDto? _activeShare;
  /// Token in chiaro disponibile solo subito dopo la generazione (POST).
  /// Una volta chiuso il dialog, non sara' piu' recuperabile.
  String?   _tokenPlain;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError('Non autenticato');
      final shares = await ref.read(sharesApiProvider).list(access, widget.characterId);
      _activeShare = shares.where((s) => !s.revoked).firstOrNull;
    } on ApiError catch (e) {
      _error = e.detail;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    setState(() { _working = true; _error = null; });
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError('Non autenticato');
      final dto = await ref.read(sharesApiProvider).create(access, widget.characterId);
      _activeShare = dto;
      _tokenPlain  = dto.token;
    } on ApiError catch (e) {
      _error = e.detail;
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _revoke() async {
    final s = _activeShare;
    if (s == null) return;
    setState(() { _working = true; _error = null; });
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError('Non autenticato');
      await ref.read(sharesApiProvider).revoke(access, widget.characterId, s.id);
      _activeShare = null;
      _tokenPlain  = null;
    } on ApiError catch (e) {
      _error = e.detail;
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String? get _publicUrl {
    final t = _tokenPlain;
    if (t == null) return null;
    final origin = Uri.base.origin;
    return '$origin/share/$t';
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.share_outlined),
          const SizedBox(width: 8),
          Text(l10n.shareDialogTitle),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: _loading
            ? const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.shareDialogIntro,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: TextStyle(color: scheme.error)),
                    ),
                  if (_tokenPlain != null) ...[
                    Text(l10n.shareDialogPublicLink,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SelectableText(
                      _publicUrl!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.shareDialogCopyHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.tertiary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: _publicUrl!));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.shareDialogCopiedSnack)),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: Text(l10n.shareDialogCopy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _working ? null : _revoke,
                          icon: const Icon(Icons.link_off),
                          label: Text(l10n.shareDialogRevoke),
                        ),
                      ],
                    ),
                  ] else if (_activeShare != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, size: 18, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text(l10n.shareDialogActive,
                                  style: Theme.of(context).textTheme.titleSmall),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.shareDialogGeneratedAt(_formatDate(_activeShare!.createdAt)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.shareDialogLostHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _working ? null : _generate,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.shareDialogRegenerate),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _working ? null : _revoke,
                          icon: const Icon(Icons.link_off),
                          label: Text(l10n.shareDialogRevoke),
                        ),
                      ],
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _working ? null : _generate,
                        icon: const Icon(Icons.link),
                        label: Text(l10n.shareDialogGenerate),
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yy = local.year;
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yy $hh:$mi';
  }
}
