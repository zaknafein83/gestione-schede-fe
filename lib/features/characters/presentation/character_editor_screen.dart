import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../../dice/presentation/dice_roller_dialog.dart';
import '../../share/presentation/share_dialog.dart';
import '../data/character_detail_providers.dart';
import '../data/characters_api.dart';
import '../data/characters_controller.dart';
import '../data/portrait_providers.dart';
import '../models/character_models.dart';
import 'character_editor_controller.dart';
import 'widgets/abilities_widget.dart';
import 'widgets/anagrafica_widget.dart';
import 'widgets/combat_widget.dart';
import 'widgets/equip_widget.dart';
import 'widgets/hp_quick_controls.dart';
import 'widgets/notes_widget.dart';
import 'widgets/portrait_header.dart';
import 'widgets/spellcasting_widget.dart';
import 'widgets/stats_widget.dart';
import 'widgets/traits_widget.dart';

/// Editor della scheda personaggio. Al MVP-1 nessun calcolo automatico:
/// l'utente edita tutti i campi a mano.
///
/// Tab: Anagrafica · Stats · Combat · Incantesimi · Equip · Tratti · Note.
/// Salvataggio esplicito via bottone "Salva" — invia tutto il form in PATCH.
class CharacterEditorScreen extends ConsumerStatefulWidget {
  const CharacterEditorScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CharacterEditorScreen> createState() =>
      _CharacterEditorScreenState();
}

class _CharacterEditorScreenState extends ConsumerState<CharacterEditorScreen> {
  @override
  void initState() {
    super.initState();
    // Forza fresh fetch al mount: autoDispose ha un microtask delay e
    // navigando rapidamente fra screens il provider potrebbe ritornare
    // l'ultima cached value (post PATCH dell'altra view).
    ref.invalidate(characterDetailProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(characterDetailProvider(widget.id));

    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCharacterEditor),
        leading: smartBackButton(context, fallback: '/characters'),
        actions: [
          IconButton(
            tooltip: l10n.editorToolbarShare,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => showShareDialog(context, widget.id),
          ),
          IconButton(
            tooltip: l10n.diceTitle,
            icon: const Icon(Icons.casino_outlined),
            onPressed: () => showDiceRoller(context, characterId: widget.id),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is ApiError ? e.detail : e.toString()),
        ),
        // ValueKey su updatedAt: quando i dati cambiano (fetch fresh post-save
        // dall'altra vista), Flutter ricrea lo State invece di riusarlo.
        data: (c) => _EditorBody(
          key: ValueKey('${c.id}-${c.updatedAt?.millisecondsSinceEpoch ?? 0}'),
          initial: c,
        ),
      ),
    );
  }
}

class _EditorBody extends ConsumerStatefulWidget {
  const _EditorBody({super.key, required this.initial});
  final CharacterDto initial;

  @override
  ConsumerState<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends ConsumerState<_EditorBody>
    with TickerProviderStateMixin {

  late final TabController _tab;
  late final CharacterEditorController controller;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ----- Autosave -----
  Timer?    _autosaveTimer;
  bool      _autosaveDirty = false;
  DateTime? _lastSavedAt;
  String?   _autosaveError;
  static const _autosaveDebounce = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 8, vsync: this);
    controller = CharacterEditorController(initial: widget.initial);
    controller.addListener(_onControllerChanged);
    controller.dirtyVersion.addListener(_scheduleAutosave);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dirtyVersion.removeListener(_scheduleAutosave);
    controller.dispose();
    _autosaveTimer?.cancel();
    _tab.dispose();
    // Fresh fetch al prossimo accesso (layout editor o shared link).
    ref.invalidate(characterDetailProvider(widget.initial.id));
    super.dispose();
  }

  // -------------------------- UI ----------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_autosaveDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _flushAndMaybePop(result);
      },
      child: Column(
      children: [
        PortraitHeader(
          characterId: widget.initial.id,
          onPick:      _pickAndUploadPortrait,
          onRemove:    _removePortrait,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: HpQuickControlsWidget(controller: controller, mode: HpControlsMode.compact),
        ),
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: Builder(builder: (ctx) {
            final l10n = AppL10n.of(ctx);
            return TabBar(
              controller: _tab,
              isScrollable: true,
              tabs: [
                Tab(text: l10n.editorTabAnagrafica, icon: const Icon(Icons.badge_outlined)),
                Tab(text: l10n.editorTabStats,      icon: const Icon(Icons.fitness_center_outlined)),
                Tab(text: l10n.editorTabAbilities,  icon: const Icon(Icons.checklist_outlined)),
                Tab(text: l10n.editorTabCombat,     icon: const Icon(Icons.shield_outlined)),
                Tab(text: l10n.editorTabSpells,     icon: const Icon(Icons.auto_awesome_outlined)),
                Tab(text: l10n.editorTabEquip,      icon: const Icon(Icons.inventory_2_outlined)),
                Tab(text: l10n.editorTabTraits,     icon: const Icon(Icons.psychology_outlined)),
                Tab(text: l10n.editorTabNotes,      icon: const Icon(Icons.note_alt_outlined)),
              ],
            );
          }),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tab,
              children: [
                AnagraficaWidget(controller: controller),
                StatsWidget(controller: controller),
                AbilitiesWidget(controller: controller),
                CombatWidget(controller: controller),
                SpellcastingWidget(controller: controller),
                EquipWidget(controller: controller),
                TraitsWidget(controller: controller),
                NotesWidget(controller: controller),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _AutosaveStatus(
              saving:    _saving,
              lastSaved: _lastSavedAt,
              error:     _autosaveError,
            ),
          ),
        ),
      ],
      ),
    );
  }

  /// Intercetta il tentativo di pop quando ci sono modifiche non salvate.
  /// Tenta un flush sincrono dell'autosave; se la validazione fallisce
  /// chiede conferma all'utente prima di scartare le modifiche.
  Future<void> _flushAndMaybePop(Object? result) async {
    _autosaveTimer?.cancel();
    await _doAutosave();
    if (!mounted) return;
    if (_autosaveDirty) {
      // Save fallito (validation o errore di rete). Chiediamo conferma.
      final l10n = AppL10n.of(context);
      final exit = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.editorExitDirtyTitle),
          content: Text(l10n.editorExitDirtyBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.editorExitDirtyDiscard),
            ),
          ],
        ),
      );
      if (!mounted || exit != true) return;
    }
    Navigator.of(context).pop(result);
  }

  Future<void> _pickAndUploadPortrait() async {
    final notAuthMsg = AppL10n.of(context).editorNotAuthError;
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    final bytes = f.bytes;
    if (bytes == null) return;

    final ext = (f.extension ?? '').toLowerCase();
    final contentType = switch (ext) {
      'png'          => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp'         => 'image/webp',
      _              => 'application/octet-stream',
    };

    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError(notAuthMsg);
      await ref.read(charactersApiProvider).uploadPortrait(
            access,
            widget.initial.id,
            bytes: bytes,
            filename: f.name,
            contentType: contentType,
          );
      ref.read(characterPortraitVersionsProvider.notifier).bump(widget.initial.id);
      ref.invalidate(characterDetailProvider(widget.initial.id));
      await ref.read(charactersListProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).editorPortraitUpdatedSnack)),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.detail)),
      );
    }
  }

  Future<void> _removePortrait() async {
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) return;
      await ref.read(charactersApiProvider).deletePortrait(access, widget.initial.id);
      ref.read(characterPortraitVersionsProvider.notifier).bump(widget.initial.id);
      ref.invalidate(characterDetailProvider(widget.initial.id));
      await ref.read(charactersListProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).editorPortraitRemovedSnack)),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.detail)),
      );
    }
  }

  /// Programma un autosave con debounce. Chiamato dai listener dei controllers
  /// e dai setter discreti (switch, +/- HP, riposi, add/remove cards, ecc.).
  /// Setta `_autosaveDirty` via setState cosÃ¬ `PopScope.canPop` ricalcola.
  void _scheduleAutosave() {
    if (!_autosaveDirty) {
      if (mounted) {
        setState(() => _autosaveDirty = true);
      } else {
        _autosaveDirty = true;
      }
    }
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, _doAutosave);
  }

  Future<void> _doAutosave() async {
    if (!_autosaveDirty) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autosaveError = AppL10n.of(context).autosaveFormInvalid);
      return;
    }
    setState(() {
      _saving = true;
      _autosaveError = null;
    });
    final notAuthMsg = AppL10n.of(context).editorNotAuthError;
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError(notAuthMsg);
      final payload = controller.buildPayload();
      await ref.read(charactersApiProvider).patch(access, widget.initial.id, payload);
      // NB: NON invalidiamo characterDetailProvider qui — l'utente sta
      // editando, non vogliamo che il rifetch sovrascriva i controllers.
      // La lista, invece, va aggiornata (nome/livello/portrait possono cambiare).
      await ref.read(charactersListProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _autosaveDirty = false;
        _lastSavedAt = DateTime.now();
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _autosaveError = e.detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _autosaveError = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

}

// ===========================================================================
//                              Autosave status
// ===========================================================================

class _AutosaveStatus extends StatelessWidget {
  const _AutosaveStatus({
    required this.saving,
    required this.lastSaved,
    required this.error,
  });

  final bool      saving;
  final DateTime? lastSaved;
  final String?   error;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style  = Theme.of(context).textTheme.bodySmall;

    if (error != null && !saving) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: scheme.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.autosaveError(error!),
              style: style?.copyWith(color: scheme.error),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    if (saving) {
      return Row(
        children: [
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(l10n.autosaveSaving, style: style),
        ],
      );
    }
    if (lastSaved != null) {
      final t = lastSaved!;
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      final ss = t.second.toString().padLeft(2, '0');
      return Row(
        children: [
          Icon(Icons.cloud_done_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(l10n.autosaveSavedAt('$hh:$mm:$ss'), style: style),
        ],
      );
    }
    return Row(
      children: [
        Icon(Icons.cloud_outlined, size: 16, color: scheme.outline),
        const SizedBox(width: 6),
        Text(l10n.autosaveIdle, style: style),
      ],
    );
  }
}

