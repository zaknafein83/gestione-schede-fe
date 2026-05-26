import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../logic/character_calc.dart';
import '../../logic/character_catalog.dart';
import '../../logic/conditions_catalog.dart';
import '../character_editor_controller.dart';
import 'conditions_dialog.dart';
import 'editor_form_fields.dart';
import 'hp_quick_controls.dart';

/// Tab "Combattimento": AC/iniziativa/velocità, HP, hit dice, death saves,
/// condizioni attive, riposo breve/lungo.
class CombatWidget extends StatelessWidget {
  const CombatWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final dexShort = abilityShort('dex', l10n);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editorCombatDefenseMovement, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorRow([
            _DerivedIntField(
              controller: controller.armorClass,
              label: l10n.editorCombatArmorClassLabel,
              kind: EditorFieldKind.intMin0,
              listenables: [controller.dex],
              hint: () {
                final m = abilityMod(tryParseInt(controller.dex.text));
                return m == null ? null : l10n.editorCombatHintAcAuto(10 + m, dexShort);
              },
            ),
            _DerivedIntField(
              controller: controller.initiative,
              label: l10n.sheetCombatInitiative,
              kind: EditorFieldKind.intAny,
              listenables: [controller.dex],
              hint: () {
                final m = abilityMod(tryParseInt(controller.dex.text));
                return m == null ? null : l10n.editorCombatHintInitAuto(formatModifier(m), dexShort);
              },
            ),
          ]),
          editorRow([
            editorTextField(controller.speed, label: l10n.editorCombatSpeedLabel, kind: EditorFieldKind.intMin0),
            _DerivedIntField(
              controller: controller.proficiencyBonus,
              label: l10n.editorCombatProfBonusLabel,
              kind: EditorFieldKind.intMin0,
              listenables: [controller.level],
              hint: () {
                final p = profBonusForLevel(tryParseInt(controller.level.text));
                return p == null ? null : l10n.editorCombatHintProfAuto(formatModifier(p));
              },
            ),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatHpSectionTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          HpQuickControlsWidget(controller: controller, mode: HpControlsMode.expanded),
          const SizedBox(height: 12),
          editorRow([
            editorTextField(controller.hpMax,     label: l10n.editorCombatHpMaxLabel,     kind: EditorFieldKind.intMin0),
            editorTextField(controller.hpCurrent, label: l10n.editorCombatHpCurrentLabel, kind: EditorFieldKind.intAny),
          ]),
          editorRow([
            editorTextField(controller.hpTemp,    label: l10n.editorHpTempLabel, kind: EditorFieldKind.intMin0),
            const SizedBox.shrink(),
          ]),
          const SizedBox(height: 24),
          Text(l10n.sheetCombatHitDice, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorRow([
            editorTextField(controller.hitDiceTotal, label: l10n.editorCombatHitDiceTotalLabel, kind: EditorFieldKind.intMin0),
            editorTextField(controller.hitDiceUsed,  label: l10n.editorCombatHitDiceUsedLabel,  kind: EditorFieldKind.intMin0),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatDeathSavesSectionTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorRow([
            editorTextField(controller.deathSavesSuccesses, label: l10n.editorCombatDeathSavesSuccLabel, kind: EditorFieldKind.intRanged, min: 0, max: 3),
            editorTextField(controller.deathSavesFailures,  label: l10n.editorCombatDeathSavesFailLabel, kind: EditorFieldKind.intRanged, min: 0, max: 3),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatConditionsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorCombatConditionsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _ConditionsSection(controller: controller),
          const SizedBox(height: 24),
          Text(l10n.editorCombatRestsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorCombatRestsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmRest(context, controller, isLong: false),
                  icon: const Icon(Icons.local_cafe_outlined),
                  label: Text(l10n.editorRestShort),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _confirmRest(context, controller, isLong: true),
                  icon: const Icon(Icons.bedtime_outlined),
                  label: Text(l10n.editorRestLong),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Campo numerico che mostra un hint reattivo (es. "auto: +3 (mod DES)")
/// nel helperText. Se l'utente valorizza il campo, l'hint resta visibile a
/// scopo informativo — al MVP-2 non sovrascriviamo automaticamente.
class _DerivedIntField extends StatelessWidget {
  const _DerivedIntField({
    required this.controller,
    required this.label,
    required this.kind,
    required this.listenables,
    required this.hint,
  });

  final TextEditingController        controller;
  final String                       label;
  final EditorFieldKind              kind;
  final List<TextEditingController>  listenables;
  final String? Function()           hint;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) => editorTextField(
        controller,
        label: label,
        kind: kind,
        helperText: hint(),
      ),
    );
  }
}

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({required this.controller});
  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in conditionsCatalog)
          _ConditionChip(
            entry: c,
            active: controller.conditions.contains(c.key),
            onToggle: (on) => controller.toggleCondition(c.key, on),
          ),
      ],
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.entry,
    required this.active,
    required this.onToggle,
  });

  final ConditionEntry entry;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: active,
      onSelected: onToggle,
      label: Text(labelForCondition(entry.key, AppL10n.of(context))),
      avatar: active
          ? Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error)
          : null,
      selectedColor: scheme.errorContainer,
      deleteIcon: const Icon(Icons.info_outline, size: 18),
      onDeleted: () => showConditionInfo(context, entry),
    );
  }
}

Future<void> _confirmRest(
  BuildContext context,
  CharacterEditorController controller, {
  required bool isLong,
}) async {
  final l10n  = AppL10n.of(context);
  final btnLabel    = isLong ? l10n.editorRestLong               : l10n.editorRestShort;
  final dialogTitle = isLong ? l10n.editorRestLongConfirmTitle   : l10n.editorRestShortConfirmTitle;
  final body        = isLong ? l10n.editorRestLongBody           : l10n.editorRestShortBody;
  final snack       = isLong ? l10n.editorRestLongApplied        : l10n.editorRestShortApplied;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(dialogTitle),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(btnLabel),
        ),
      ],
    ),
  );
  if (ok != true) return;
  if (isLong) {
    controller.longRest();
  } else {
    controller.shortRest();
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snack)),
    );
  }
}
