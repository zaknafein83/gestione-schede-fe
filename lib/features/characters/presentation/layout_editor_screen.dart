import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../../paywall/presentation/paywall_dialog.dart';
import '../data/character_detail_providers.dart';
import '../data/character_layout_api.dart';
import '../data/character_layout_providers.dart';
import '../data/characters_api.dart';
import '../data/characters_controller.dart';
import '../models/character_models.dart';
import '../models/layout_models.dart';
import 'character_editor_controller.dart';
import 'widgets/abilities_widget.dart';
import 'widgets/anagrafica_widget.dart';
import 'widgets/combat_widget.dart';
import 'widgets/conditions_widget.dart';
import 'widgets/equip_widget.dart';
import 'widgets/hp_quick_controls.dart';
import 'widgets/notes_widget.dart';
import 'widgets/portrait_view_widget.dart';
import 'widgets/spellcasting_widget.dart';
import 'widgets/stats_widget.dart';
import 'widgets/traits_widget.dart';

/// Editor del layout dashboard custom. Premium-only (verifica via 402 dal
/// backend). Mostra i widget posizionati nel canvas; tap apre popup con
/// azioni (rimuovi, z-order). Drag & resize verranno aggiunti nella
/// prossima iterazione.
class LayoutEditorScreen extends ConsumerWidget {
  const LayoutEditorScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChar   = ref.watch(characterDetailProvider(id));
    final asyncLayout = ref.watch(characterLayoutProvider(id));

    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editorLayoutTitle),
        leading: smartBackButton(context, fallback: '/characters/$id'),
      ),
      body: asyncChar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text(e is ApiError ? e.detail : e.toString())),
        data:    (c) => asyncLayout.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text(e is ApiError ? e.detail : e.toString())),
          data:    (layout) => _LayoutEditorBody(
            characterId: id,
            initialChar: c,
            initialLayout: layout,
          ),
        ),
      ),
    );
  }
}

class _LayoutEditorBody extends ConsumerStatefulWidget {
  const _LayoutEditorBody({
    required this.characterId,
    required this.initialChar,
    required this.initialLayout,
  });

  final String characterId;
  final CharacterDto initialChar;
  final CharacterLayout initialLayout;

  @override
  ConsumerState<_LayoutEditorBody> createState() => _LayoutEditorBodyState();
}

class _LayoutEditorBodyState extends ConsumerState<_LayoutEditorBody> {
  /// Grandezza in pixel di una unità di griglia (snap target).
  static const double _gridUnit = 16.0;

  /// Default per nuovi widget: 16 unità di larghezza × 12 di altezza (~256×192px).
  static const int _defaultW = 16;
  static const int _defaultH = 12;

  late final CharacterEditorController _controller;
  late List<LayoutWidget> _widgets;

  Timer? _saveTimer;
  /// Modifiche alle posizioni/dimensioni dei widget → PUT /layout.
  bool _layoutDirty = false;
  /// Modifiche ai dati della scheda (es. HP, condizioni dentro un widget)
  /// → PATCH /characters/{id}. Triggerato dal listener su dirtyVersion del
  /// controller.
  bool _charDirty = false;
  bool _saving = false;
  String? _saveError;
  DateTime? _lastSavedAt;
  static const _saveDebounce = Duration(seconds: 1);

  bool get _dirty => _layoutDirty || _charDirty;

  @override
  void initState() {
    super.initState();
    _controller = CharacterEditorController(initial: widget.initialChar);
    _widgets = List.of(widget.initialLayout.widgets);
    // I widget dentro il canvas possono editare i campi della scheda (HP,
    // conditions, ecc.). Ascoltiamo dirtyVersion per programmare un PATCH.
    _controller.addListener(_onControllerChanged);
    _controller.dirtyVersion.addListener(_onCharDirty);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dirtyVersion.removeListener(_onCharDirty);
    _controller.dispose();
    _saveTimer?.cancel();
    // Invalida i provider cosi' altre viste (lista, editor classico) fanno
    // fresh fetch al prossimo accesso.
    ref.invalidate(characterDetailProvider(widget.characterId));
    ref.invalidate(characterLayoutProvider(widget.characterId));
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onCharDirty() {
    if (!_charDirty) {
      if (mounted) {
        setState(() => _charDirty = true);
      } else {
        _charDirty = true;
      }
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, _doSave);
  }

  void _scheduleSave() {
    if (!_layoutDirty) {
      if (mounted) {
        setState(() => _layoutDirty = true);
      } else {
        _layoutDirty = true;
      }
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, _doSave);
  }

  /// Flush sincrono prima del pop: cancella il timer di debounce e attende
  /// la fine del save. Evita data-loss se l'utente naviga via entro 1s da
  /// un drag/resize o da un edit di un widget interno.
  Future<void> _flushAndPop(Object? result) async {
    _saveTimer?.cancel();
    if (_dirty) await _doSave();
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _doSave() async {
    if (!_dirty) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) throw StateError('Utente non autenticato');

      // 1. Salva i dati della scheda se modificati (sempre permesso, anche FREE).
      if (_charDirty) {
        await ref.read(charactersApiProvider).patch(
              access,
              widget.characterId,
              _controller.buildPayload(),
            );
        // Aggiorna anche la lista (nome/livello/portrait possono essere cambiati).
        await ref.read(charactersListProvider.notifier).refresh();
        if (!mounted) return;
        setState(() => _charDirty = false);
      }

      // 2. Salva il layout se modificato (gated PREMIUM lato backend).
      if (_layoutDirty) {
        await ref.read(characterLayoutApiProvider).put(
              access,
              widget.characterId,
              widgets: _widgets,
            );
        if (!mounted) return;
        setState(() => _layoutDirty = false);
      }

      if (!mounted) return;
      setState(() => _lastSavedAt = DateTime.now());
    } on ApiError catch (e) {
      if (!mounted) return;
      final shown = await maybeShowPaywall(context, e);
      if (!mounted) return;
      setState(() => _saveError = shown ? null : e.detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveError = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addWidget(LayoutWidgetType type) {
    if (_widgets.any((w) => w.type == type)) return; // singola istanza per tipo (MVP)
    setState(() {
      final maxZ = _widgets.isEmpty ? 0 : _widgets.map((w) => w.z).reduce((a, b) => a > b ? a : b);
      _widgets.add(LayoutWidget(
        type: type,
        x: 0,
        y: 0,
        w: _defaultW,
        h: _defaultH,
        z: maxZ + 1,
      ));
    });
    _scheduleSave();
  }

  void _removeWidget(int index) {
    setState(() => _widgets.removeAt(index));
    _scheduleSave();
  }

  void _bringForward(int index) {
    setState(() {
      final maxZ = _widgets.map((w) => w.z).reduce((a, b) => a > b ? a : b);
      _widgets[index] = _widgets[index].copyWith(z: maxZ + 1);
    });
    _scheduleSave();
  }

  void _sendBackward(int index) {
    setState(() {
      final minZ = _widgets.map((w) => w.z).reduce((a, b) => a < b ? a : b);
      _widgets[index] = _widgets[index].copyWith(z: minZ - 1);
    });
    _scheduleSave();
  }

  void _moveWidget(int index, int x, int y) {
    if (_widgets[index].x == x && _widgets[index].y == y) return;
    setState(() => _widgets[index] = _widgets[index].copyWith(x: x, y: y));
    _scheduleSave();
  }

  void _resizeWidget(int index, int w, int h) {
    if (_widgets[index].w == w && _widgets[index].h == h) return;
    setState(() => _widgets[index] = _widgets[index].copyWith(w: w, h: h));
    _scheduleSave();
  }

  Future<void> _confirmReset() async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editorLayoutResetConfirmTitle),
        content: Text(l10n.editorLayoutResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editorLayoutResetConfirmYes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _saveTimer?.cancel();
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access == null) return;
      await ref.read(characterLayoutApiProvider).delete(access, widget.characterId);
      if (!mounted) return;
      setState(() {
        _widgets = [];
        _layoutDirty = false;
        _lastSavedAt = DateTime.now();
      });
      ref.invalidate(characterLayoutProvider(widget.characterId));
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _saveError = e.detail);
    }
  }

  Future<void> _pickWidgetType() async {
    final l10n = AppL10n.of(context);
    final available = LayoutWidgetType.values
        .where((t) => !_widgets.any((w) => w.type == t))
        .toList();
    if (available.isEmpty) return;
    final chosen = await showModalBottomSheet<LayoutWidgetType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final t in available)
              ListTile(
                leading: Icon(_iconFor(t)),
                title: Text(_labelFor(t, l10n)),
                onTap: () => Navigator.pop(ctx, t),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) _addWidget(chosen);
  }

  IconData _iconFor(LayoutWidgetType t) {
    switch (t) {
      case LayoutWidgetType.anagrafica:   return Icons.badge_outlined;
      case LayoutWidgetType.stats:        return Icons.fitness_center_outlined;
      case LayoutWidgetType.abilities:    return Icons.checklist_outlined;
      case LayoutWidgetType.combat:       return Icons.shield_outlined;
      case LayoutWidgetType.conditions:   return Icons.warning_amber_rounded;
      case LayoutWidgetType.spellcasting: return Icons.auto_awesome_outlined;
      case LayoutWidgetType.equip:        return Icons.inventory_2_outlined;
      case LayoutWidgetType.traits:       return Icons.psychology_outlined;
      case LayoutWidgetType.notes:        return Icons.note_alt_outlined;
      case LayoutWidgetType.hpTracker:    return Icons.favorite_outline;
      case LayoutWidgetType.portrait:     return Icons.image_outlined;
    }
  }

  String _labelFor(LayoutWidgetType t, AppL10n l10n) {
    switch (t) {
      case LayoutWidgetType.anagrafica:   return l10n.editorTabAnagrafica;
      case LayoutWidgetType.stats:        return l10n.editorTabStats;
      case LayoutWidgetType.abilities:    return l10n.editorTabAbilities;
      case LayoutWidgetType.combat:       return l10n.editorTabCombat;
      case LayoutWidgetType.conditions:   return l10n.editorLayoutWidgetConditions;
      case LayoutWidgetType.spellcasting: return l10n.editorTabSpells;
      case LayoutWidgetType.equip:        return l10n.editorTabEquip;
      case LayoutWidgetType.traits:       return l10n.editorTabTraits;
      case LayoutWidgetType.notes:        return l10n.editorTabNotes;
      case LayoutWidgetType.hpTracker:    return l10n.editorLayoutWidgetHpTracker;
      case LayoutWidgetType.portrait:     return l10n.editorLayoutWidgetPortrait;
    }
  }

  Widget _renderWidget(LayoutWidgetType type) {
    switch (type) {
      case LayoutWidgetType.anagrafica:   return AnagraficaWidget(controller: _controller);
      case LayoutWidgetType.stats:        return StatsWidget(controller: _controller);
      case LayoutWidgetType.abilities:    return AbilitiesWidget(controller: _controller);
      case LayoutWidgetType.combat:       return CombatWidget(controller: _controller);
      case LayoutWidgetType.spellcasting: return SpellcastingWidget(controller: _controller);
      case LayoutWidgetType.equip:        return EquipWidget(controller: _controller);
      case LayoutWidgetType.traits:       return TraitsWidget(controller: _controller);
      case LayoutWidgetType.notes:        return NotesWidget(controller: _controller);
      case LayoutWidgetType.hpTracker:    return HpQuickControlsWidget(
            controller: _controller,
            mode: HpControlsMode.expanded,
          );
      case LayoutWidgetType.conditions:   return ConditionsWidget(controller: _controller);
      case LayoutWidgetType.portrait:     return PortraitViewWidget(characterId: widget.characterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sorted = [..._widgets]..sort((a, b) => a.z.compareTo(b.z));

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _flushAndPop(result);
      },
      child: Column(
      children: [
        // Toolbar
        Material(
          color: scheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _pickWidgetType,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.editorLayoutAddWidget),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _widgets.isEmpty ? null : _confirmReset,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.editorLayoutReset),
                ),
                const Spacer(),
                _SaveStatus(saving: _saving, lastSaved: _lastSavedAt, error: _saveError),
              ],
            ),
          ),
        ),
        // Canvas
        Expanded(
          child: _widgets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.editorLayoutEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (ctx, viewport) {
                    final contentW = _contentWidth();
                    final contentH = _contentHeight();
                    // Il canvas riempie sempre il viewport; cresce oltre solo se
                    // i widget si estendono oltre il viewport (allora compaiono scroll).
                    final canvasW = contentW > viewport.maxWidth  ? contentW : viewport.maxWidth;
                    final canvasH = contentH > viewport.maxHeight ? contentH : viewport.maxHeight;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width:  canvasW,
                          height: canvasH,
                          child: Stack(
                            children: [
                              for (var i = 0; i < sorted.length; i++)
                                _PositionedWidget(
                                  key: ValueKey(sorted[i].type),
                                  widget: sorted[i],
                                  gridUnit: _gridUnit,
                                  onRemove:       () => _removeWidget(_widgets.indexOf(sorted[i])),
                                  onBringForward: () => _bringForward(_widgets.indexOf(sorted[i])),
                                  onSendBackward: () => _sendBackward(_widgets.indexOf(sorted[i])),
                                  onMoved:        (x, y) => _moveWidget(_widgets.indexOf(sorted[i]), x, y),
                                  onResized:      (w, h) => _resizeWidget(_widgets.indexOf(sorted[i]), w, h),
                                  child: _renderWidget(sorted[i].type),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
      ),
    );
  }

  /// Larghezza minima del canvas per ospitare tutti i widget (in pixel).
  /// Il canvas vero è max(viewport, contentWidth) per riempire la pagina.
  double _contentWidth() {
    if (_widgets.isEmpty) return 0;
    final maxX = _widgets.map((w) => w.x + w.w).reduce((a, b) => a > b ? a : b);
    return (maxX + 4) * _gridUnit;
  }

  double _contentHeight() {
    if (_widgets.isEmpty) return 0;
    final maxY = _widgets.map((w) => w.y + w.h).reduce((a, b) => a > b ? a : b);
    return (maxY + 4) * _gridUnit;
  }
}

/// Wrapper Positioned + drag header + resize handle.
///
/// Drag: l'header in alto (32px) è il drag handle — pan gesture sposta il
/// widget snappando alle unità di griglia. Il contenuto interno resta
/// scrollable.
///
/// Resize: handle in basso a destra (24×24) — pan gesture ridimensiona
/// snappando alle unità di griglia (w/h ≥ 4).
class _PositionedWidget extends StatefulWidget {
  const _PositionedWidget({
    super.key,
    required this.widget,
    required this.gridUnit,
    required this.onRemove,
    required this.onBringForward,
    required this.onSendBackward,
    required this.onMoved,
    required this.onResized,
    required this.child,
  });

  final LayoutWidget widget;
  final double gridUnit;
  final VoidCallback onRemove;
  final VoidCallback onBringForward;
  final VoidCallback onSendBackward;
  final void Function(int x, int y) onMoved;
  final void Function(int w, int h) onResized;
  final Widget child;

  @override
  State<_PositionedWidget> createState() => _PositionedWidgetState();
}

class _PositionedWidgetState extends State<_PositionedWidget> {
  /// Offset pixel locale durante drag (commit a onPanEnd con snap).
  double _dragDx = 0, _dragDy = 0;
  /// Delta pixel locale durante resize.
  double _resizeDw = 0, _resizeDh = 0;

  static const int _minSize = 4; // 4 unità ~ 64px

  void _commitMove() {
    final newX = (widget.widget.x + _dragDx / widget.gridUnit).round();
    final newY = (widget.widget.y + _dragDy / widget.gridUnit).round();
    setState(() {
      _dragDx = 0;
      _dragDy = 0;
    });
    widget.onMoved(newX < 0 ? 0 : newX, newY < 0 ? 0 : newY);
  }

  void _commitResize() {
    final newW = (widget.widget.w + _resizeDw / widget.gridUnit).round();
    final newH = (widget.widget.h + _resizeDh / widget.gridUnit).round();
    setState(() {
      _resizeDw = 0;
      _resizeDh = 0;
    });
    widget.onResized(
      newW < _minSize ? _minSize : newW,
      newH < _minSize ? _minSize : newH,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = widget.widget;
    final left   = w.x * widget.gridUnit + _dragDx;
    final top    = w.y * widget.gridUnit + _dragDy;
    final width  = w.w * widget.gridUnit + _resizeDw;
    final height = w.h * widget.gridUnit + _resizeDh;

    return Positioned(
      left:   left.clamp(0.0, double.infinity),
      top:    top.clamp(0.0, double.infinity),
      width:  width.clamp(_minSize * widget.gridUnit, double.infinity),
      height: height.clamp(_minSize * widget.gridUnit, double.infinity),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Drag handle header
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _dragDx += details.delta.dx;
                  _dragDy += details.delta.dy;
                });
              },
              onPanEnd: (_) => _commitMove(),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: scheme.surfaceContainerHigh,
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, size: 18, color: scheme.outline),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      tooltip: '',
                      padding: EdgeInsets.zero,
                      onSelected: (v) {
                        switch (v) {
                          case 'forward':  widget.onBringForward(); break;
                          case 'backward': widget.onSendBackward(); break;
                          case 'remove':   widget.onRemove(); break;
                        }
                      },
                      itemBuilder: (ctx) {
                        final l10n = AppL10n.of(ctx);
                        return [
                          PopupMenuItem(
                            value: 'forward',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.flip_to_front),
                              title: Text(l10n.editorLayoutBringForward),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'backward',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.flip_to_back),
                              title: Text(l10n.editorLayoutSendBackward),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.delete_outline),
                              title: Text(l10n.editorLayoutRemoveWidget),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Contenuto
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: widget.child),
                  // Resize handle (corner basso-destra)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        setState(() {
                          _resizeDw += details.delta.dx;
                          _resizeDh += details.delta.dy;
                        });
                      },
                      onPanEnd: (_) => _commitResize(),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.south_east,
                          size: 14,
                          color: scheme.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveStatus extends StatelessWidget {
  const _SaveStatus({required this.saving, required this.lastSaved, required this.error});
  final bool saving;
  final DateTime? lastSaved;
  final String? error;

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
          Text(l10n.autosaveError(error!),
              style: style?.copyWith(color: scheme.error)),
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
      return Row(
        children: [
          Icon(Icons.cloud_done_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(l10n.autosaveSavedAt('$hh:$mm'), style: style),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
