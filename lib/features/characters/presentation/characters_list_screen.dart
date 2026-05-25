import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../paywall/presentation/paywall_dialog.dart';
import '../../share/logic/file_download.dart';
import '../data/characters_controller.dart';
import '../models/character_models.dart';
import 'character_portrait_widget.dart';

/// Lista delle schede personaggio dell'utente loggato.
/// Su layout wide (web) mostra una grid di card; FAB '+' crea una scheda vuota.
class CharactersListScreen extends ConsumerWidget {
  const CharactersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(charactersListProvider);

    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCharacters),
        leading: smartBackButton(context, fallback: '/home'),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.charactersImportTooltip,
            icon: const Icon(Icons.file_upload_outlined),
            onSelected: (v) => _onImport(context, ref, foundry: v == 'foundry'),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'json',    child: Text(l10n.charactersImportJson)),
              PopupMenuItem(value: 'foundry', child: Text(l10n.charactersImportFoundry)),
            ],
          ),
          IconButton(
            tooltip: l10n.actionReload,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(charactersListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onCreate(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.charactersNewBtn),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e),
        data: (items) {
          if (items.isEmpty) return const _EmptyState();
          return _CharactersGrid(items: items);
        },
      ),
    );
  }

  Future<void> _onCreate(BuildContext context, WidgetRef ref) async {
    try {
      final id = await ref.read(charactersListProvider.notifier).createEmpty();
      if (!context.mounted) return;
      context.push('/characters/$id');
    } on ApiError catch (e) {
      if (!context.mounted) return;
      if (await maybeShowPaywall(context, e)) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).charactersErrorCreate(e.detail))),
      );
    }
  }

  Future<void> _onImport(
    BuildContext context,
    WidgetRef ref, {
    required bool foundry,
  }) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    if (f.bytes == null) return;

    try {
      final text = utf8.decode(f.bytes!);
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) {
        throw FormatException(
            context.mounted ? AppL10n.of(context).charactersErrorJsonNotObject : 'invalid');
      }
      final notifier = ref.read(charactersListProvider.notifier);
      final id = foundry
          ? await notifier.importFromFoundry(json)
          : await notifier.importFromJson(json);
      if (!context.mounted) return;
      final l10n = AppL10n.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(foundry
              ? l10n.charactersSnackImportedFoundry
              : l10n.charactersSnackImportedJson),
        ),
      );
      context.push('/characters/$id');
    } on ApiError catch (e) {
      if (!context.mounted) return;
      if (await maybeShowPaywall(context, e)) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).charactersErrorImport(e.detail))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).charactersErrorJsonInvalid(e.toString()))),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 80, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.charactersEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.charactersEmptyHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final msg = error is ApiError ? (error as ApiError).detail : error.toString();
    return Center(child: Text(AppL10n.of(context).commonErrorPrefix(msg)));
  }
}

class _CharactersGrid extends ConsumerWidget {
  const _CharactersGrid({required this.items});
  final List<CharacterSummary> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Numero colonne in base alla larghezza disponibile (web-friendly).
        final w = constraints.maxWidth;
        final cols = w >= 1200
            ? 4
            : w >= 800
                ? 3
                : w >= 500
                    ? 2
                    : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _CharacterCard(c: items[i]),
        );
      },
    );
  }
}

class _CharacterCard extends ConsumerWidget {
  const _CharacterCard({required this.c});
  final CharacterSummary c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final subtitle = _buildSubtitle(context, c);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/characters/${c.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CharacterPortraitWidget(id: c.id, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.name?.isNotEmpty == true ? c.name! : l10n.charactersNoName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.charactersActionsTooltip,
                onSelected: (v) => _onAction(context, ref, v),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'rename',         child: Text(l10n.charactersActionRename)),
                  PopupMenuItem(value: 'duplicate',      child: Text(l10n.charactersActionDuplicate)),
                  PopupMenuItem(value: 'export',         child: Text(l10n.charactersActionExportJson)),
                  PopupMenuItem(value: 'export-foundry', child: Text(l10n.charactersActionExportFoundry)),
                  PopupMenuItem(value: 'export-pdf',     child: Text(l10n.charactersActionExportPdf)),
                  PopupMenuItem(value: 'delete',         child: Text(l10n.charactersActionDelete)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _safeFileName(String? name) {
    final base = (name ?? 'scheda').trim();
    if (base.isEmpty) return 'scheda';
    // sostituisci caratteri non sicuri con underscore
    return base.replaceAll(RegExp(r'[^\w\s\-.]+'), '_').replaceAll(RegExp(r'\s+'), '_');
  }

  Future<String?> _askNewName(BuildContext context, {String? current}) async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.charactersRenameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(
            labelText: l10n.charactersRenameLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  String _buildSubtitle(BuildContext context, CharacterSummary c) {
    final l10n = AppL10n.of(context);
    final parts = <String>[];
    if (c.race?.isNotEmpty == true)      parts.add(c.race!);
    if (c.className?.isNotEmpty == true) parts.add(c.className!);
    if (c.level != null)                 parts.add(l10n.charactersLevelLabel(c.level!));
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, String action) async {
    final l10n     = AppL10n.of(context);
    final notifier = ref.read(charactersListProvider.notifier);
    try {
      switch (action) {
        case 'rename':
          final newName = await _askNewName(context, current: c.name);
          if (newName == null) break;
          await notifier.rename(c.id, newName);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.charactersSnackRenamed)),
            );
          }
          break;
        case 'duplicate':
          await notifier.duplicate(c.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.charactersSnackDuplicated)),
            );
          }
          break;
        case 'export':
          final json = await notifier.exportToJson(c.id);
          final fname = '${_safeFileName(c.name)}.json';
          downloadJsonFile(fname, json);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.charactersSnackExported(fname))),
            );
          }
          break;
        case 'export-foundry':
          final json = await notifier.exportToFoundry(c.id);
          final fname = '${_safeFileName(c.name)}-foundry.json';
          downloadJsonFile(fname, json);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.charactersSnackExportedFoundry(fname))),
            );
          }
          break;
        case 'export-pdf':
          final pdfBytes = await notifier.exportToPdf(c.id, l10n);
          final fname = '${_safeFileName(c.name)}.pdf';
          downloadBytesFile(fname, pdfBytes, mime: 'application/pdf');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.charactersSnackExportedPdf(fname))),
            );
          }
          break;
        case 'delete':
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(l10n.charactersDeleteDialogTitle),
              content: Text(
                l10n.charactersDeleteDialogBody(c.name ?? l10n.charactersNoName),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          );
          if (ok == true) {
            await notifier.deleteOne(c.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.charactersSnackDeleted)),
              );
            }
          }
          break;
      }
    } on ApiError catch (e) {
      if (!context.mounted) return;
      if (await maybeShowPaywall(context, e)) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonErrorPrefix(e.detail))),
        );
      }
    }
  }
}
