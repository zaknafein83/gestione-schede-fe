import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/auth_storage.dart';
import '../../../spells/data/spells_api.dart';
import '../../../spells/models/spell_models.dart';
import '../../../spells/presentation/spell_detail_dialog.dart';
import '../../../spells/presentation/spell_picker_dialog.dart';
import '../../logic/character_calc.dart';
import '../../logic/spell_slot_tables.dart';
import '../character_editor_controller.dart';
import '../character_editor_models.dart';
import '../custom_spell_dialog.dart';
import 'editor_form_fields.dart';

/// Tab "Incantesimi": classe caster, save DC, attack, slot per livello,
/// lista spell (catalogo + custom).
class SpellcastingWidget extends ConsumerWidget {
  const SpellcastingWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.sheetSectionSpells, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorRow([
            editorTextField(controller.spellcastingClass, label: l10n.editorSpellsCasterClassLabel),
            const SizedBox.shrink(),
          ]),
          editorRow([
            editorTextField(controller.spellSaveDc,      label: l10n.editorSpellsSaveDcLabel, kind: EditorFieldKind.intMin0),
            editorTextField(controller.spellAttackBonus, label: l10n.editorSpellsAttackLabel, kind: EditorFieldKind.intAny),
          ]),
          const SizedBox(height: 24),
          Text(l10n.sheetSpellsSlotsByLevel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorSpellsSlotsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _SpellSlotsPrefiller(controller: controller),
          const SizedBox(height: 12),
          for (final lvl in const ['1','2','3','4','5','6','7','8','9'])
            _SlotEditor(lvl: lvl, row: controller.spellSlots[lvl]!),
          const SizedBox(height: 24),
          Text(l10n.editorSpellsListTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorSpellsListHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < controller.spells.length; i++)
            _SpellCard(
              row:                     controller.spells[i],
              onRemove:                () => controller.removeSpell(i),
              onPreparedChanged:       (v) => controller.setSpellPrepared(i, v),
              onAlwaysPreparedChanged: (v) => controller.setSpellAlwaysPrepared(i, v),
              onShowDetail:            () => _showSpellDetail(context, controller.spells[i]),
              onEditCustom:            () => _editCustomSpell(context, i),
              onConvertToCustom:       () => _confirmConvertToCustom(context, i),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _pickAndAddCatalogSpell(context, ref),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.editorSpellsAddFromCatalog),
              ),
              OutlinedButton.icon(
                onPressed: () => _addCustomSpell(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.editorSpellsCustomSpell),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddCatalogSpell(BuildContext context, WidgetRef ref) async {
    final initialClass = controller.spellcastingClass.text.trim().isEmpty
        ? null
        : controller.spellcastingClass.text.trim();
    final picked = await showSpellPicker(context, initialClass: initialClass);
    if (picked == null) return;

    SpellDetail? detail;
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access != null) {
        detail = await ref.read(spellsApiProvider).get(access, picked.id);
      }
    } catch (_) {
      // fallback ai soli campi del summary
    }
    final r = detail != null
        ? SpellRow.fromCatalogDetail(detail)
        : SpellRow.fromCatalog(picked);
    controller.addSpellRow(r);
  }

  Future<void> _addCustomSpell(BuildContext context) async {
    final data = await showCustomSpellDialog(context);
    if (data != null && data.isNotEmpty) {
      final r = SpellRow.newCustom()..applyCustomData(data);
      controller.addSpellRow(r);
    }
  }

  Future<void> _editCustomSpell(BuildContext context, int i) async {
    final data = await showCustomSpellDialog(context, initial: controller.spells[i].toEditMap());
    if (data != null) {
      controller.replaceCustomSpellData(i, data);
    }
  }

  Future<void> _confirmConvertToCustom(BuildContext context, int i) async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editorSpellsConvertTitle),
        content: Text(l10n.editorSpellsConvertBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editorSpellsConvertConfirm),
          ),
        ],
      ),
    );
    if (ok == true) controller.convertToCustom(i);
  }

  void _showSpellDetail(BuildContext context, SpellRow row) {
    // Spell del catalogo: fetcha SEMPRE dal backend per avere le traduzioni
    // (le translations non sono salvate nel SpellRow, vivono nel catalogo).
    // Custom: dati locali — l'utente li ha appena editati, niente catalogo.
    if (row.isCatalog) {
      showSpellDetail(context, row.spellId!);
    } else {
      showSpellDetailFromData(context, row.toDetail());
    }
  }
}

/// Dropdown progressione + bottone "Compila da PHB". Su tap, dialog di
/// conferma e quindi popola gli slot dalla tabella.
class _SpellSlotsPrefiller extends StatelessWidget {
  const _SpellSlotsPrefiller({required this.controller});
  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n      = AppL10n.of(context);
    final lvl       = tryParseInt(controller.level.text);
    final canApply  = controller.spellProgression != SpellProgression.none && lvl != null;
    final preview   = canApply
        ? spellSlotsFor(controller.spellProgression, lvl)
        : const <String, int>{};
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(builder: (context, c) {
              final dropdown = DropdownButtonFormField<SpellProgression>(
                initialValue: controller.spellProgression,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.editorSpellsProgressionLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: SpellProgression.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(spellProgressionLabel(p, l10n),
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.setSpellProgression(v);
                },
              );
              final button = FilledButton.tonalIcon(
                onPressed: canApply
                    ? () => _confirmAndApply(context)
                    : null,
                icon: const Icon(Icons.auto_fix_high),
                label: Text(l10n.editorSpellsFillFromPhb),
              );
              if (c.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [dropdown, const SizedBox(height: 8), button],
                );
              }
              return Row(
                children: [
                  Expanded(child: dropdown),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            }),
            if (canApply) ...[
              const SizedBox(height: 12),
              Text(
                l10n.editorSpellsPrefillerPreview(lvl, _formatPreview(preview, l10n)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (controller.spellProgression != SpellProgression.none) ...[
              const SizedBox(height: 12),
              Text(
                l10n.editorSpellsSetLevelFirst,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPreview(Map<String, int> slots, AppL10n l10n) {
    if (slots.isEmpty) return l10n.editorSpellsNoSlotsAtLevel;
    final parts = <String>[];
    for (var i = 1; i <= 9; i++) {
      final n = slots['$i'];
      if (n != null && n > 0) parts.add('L$i: $n');
    }
    return parts.join(' · ');
  }

  Future<void> _confirmAndApply(BuildContext context) async {
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editorSpellsFillConfirmTitle),
        content: Text(l10n.editorSpellsFillConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editorSpellsFillConfirmYes),
          ),
        ],
      ),
    );
    if (ok == true) {
      controller.applySpellSlotsFromTable();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.editorSpellsFillSnack)),
        );
      }
    }
  }
}

class _SlotEditor extends StatelessWidget {
  const _SlotEditor({required this.lvl, required this.row});
  final String lvl;
  final SlotRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(l10n.editorSpellsSlotLevel(lvl),
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          SizedBox(
            width: 88,
            child: editorTextField(row.max, label: l10n.editorSpellsSlotMax, kind: EditorFieldKind.intMin0),
          ),
          const SizedBox(width: 12),
          Expanded(child: _SlotDotsRow(row: row)),
        ],
      ),
    );
  }
}

/// Riga di pallini cliccabili: pieni = disponibili, vuoti = consumati.
/// Tap su i-esimo pallino imposta `current` a (i) se era pieno (consuma),
/// a (i+1) se era vuoto (ripristina).
class _SlotDotsRow extends StatelessWidget {
  const _SlotDotsRow({required this.row});
  final SlotRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([row.max, row.current]),
      builder: (context, _) {
        final max = int.tryParse(row.max.text.trim()) ?? 0;
        if (max <= 0) {
          return Text(
            l10n.editorSpellsNoSlotsLine,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final cur = (int.tryParse(row.current.text.trim()) ?? max).clamp(0, max);
        final scheme = Theme.of(context).colorScheme;
        return Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            for (var i = 0; i < max; i++)
              IconButton(
                tooltip: i < cur ? l10n.editorSpellsConsumeSlot : l10n.editorSpellsRestoreSlot,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  i < cur ? Icons.circle : Icons.circle_outlined,
                  size: 22,
                  color: i < cur ? scheme.primary : scheme.outline,
                ),
                onPressed: () {
                  // Era pieno → consuma a "i". Era vuoto → ripristina a "i+1".
                  final next = i < cur ? i : i + 1;
                  row.current.text = '$next';
                },
              ),
          ],
        );
      },
    );
  }
}

class _SpellCard extends StatelessWidget {
  const _SpellCard({
    required this.row,
    required this.onRemove,
    required this.onPreparedChanged,
    required this.onAlwaysPreparedChanged,
    required this.onShowDetail,
    required this.onEditCustom,
    required this.onConvertToCustom,
  });
  final SpellRow row;
  final VoidCallback       onRemove;
  final ValueChanged<bool> onPreparedChanged;
  final ValueChanged<bool> onAlwaysPreparedChanged;
  final VoidCallback       onShowDetail;
  final VoidCallback       onEditCustom;
  final VoidCallback       onConvertToCustom;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t      = Theme.of(context).textTheme;

    final levelLabel = row.level == null
        ? '—'
        : (row.level == 0 ? l10n.editorSpellsLevelChipCantrip : l10n.editorSpellsLevelChipLvl(row.level!));
    final subtitle = [
      if (row.school != null) row.school!,
      if (row.castingTime != null) row.castingTime!,
      if (row.range != null) row.range!,
    ].join(' · ');

    final chips = <Widget>[
      if (row.ritual)
        const Chip(
          label: Text('R'),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      if (row.concentration)
        const Chip(
          label: Text('C'),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onShowDetail,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Text(levelLabel,
                        style: t.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                row.name ?? l10n.charactersNoName,
                                style: t.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (row.isCatalog)
                              Tooltip(
                                message: l10n.editorSpellsFromCatalog(row.source ?? 'SRD'),
                                child: Icon(Icons.menu_book_outlined,
                                    size: 14, color: scheme.outline),
                              )
                            else
                              Tooltip(
                                message: l10n.editorSpellsCustomHomebrewTooltip,
                                child: Icon(Icons.build_circle_outlined,
                                    size: 14, color: scheme.tertiary),
                              ),
                          ],
                        ),
                        if (subtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              style: t.bodySmall?.copyWith(color: scheme.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...chips,
                  PopupMenuButton<_SpellAction>(
                    tooltip: l10n.editorSpellsActionsTooltip,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (a) {
                      switch (a) {
                        case _SpellAction.detail:    onShowDetail();        break;
                        case _SpellAction.edit:      onEditCustom();        break;
                        case _SpellAction.customize: onConvertToCustom();   break;
                        case _SpellAction.delete:    onRemove();            break;
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _SpellAction.detail,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline),
                          title: Text(l10n.spellPickerDetails),
                        ),
                      ),
                      if (!row.isCatalog)
                        PopupMenuItem(
                          value: _SpellAction.edit,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.edit_outlined),
                            title: Text(l10n.actionEdit),
                          ),
                        ),
                      if (row.isCatalog)
                        PopupMenuItem(
                          value: _SpellAction.customize,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.build_outlined),
                            title: Text(l10n.editorSpellsConvertConfirm),
                          ),
                        ),
                      PopupMenuItem(
                        value: _SpellAction.delete,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete_outline),
                          title: Text(l10n.actionRemove),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  FilterChip(
                    label: Text(l10n.sheetSpellPrepared),
                    selected: row.prepared,
                    onSelected: onPreparedChanged,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text(l10n.editorSpellsAlwaysPreparedShort),
                    selected: row.alwaysPrepared,
                    onSelected: onAlwaysPreparedChanged,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              editorTextField(row.notes, label: l10n.editorSpellsNotesLabel, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SpellAction { detail, edit, customize, delete }
