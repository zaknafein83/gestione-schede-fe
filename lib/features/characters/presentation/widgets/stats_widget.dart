import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dice/presentation/dice_roller_dialog.dart';
import '../../logic/character_calc.dart';
import '../character_editor_controller.dart';
import 'editor_form_fields.dart';

/// Tab "Stats": le 6 caratteristiche con modificatore in label e bottone 🎲.
class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editorStatsTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorStatsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          editorRow([
            _AbilityField(controller: controller.str,   label: l10n.sheetAbilityStr, characterId: controller.characterId),
            _AbilityField(controller: controller.dex,   label: l10n.sheetAbilityDex, characterId: controller.characterId),
          ]),
          editorRow([
            _AbilityField(controller: controller.con,   label: l10n.sheetAbilityCon, characterId: controller.characterId),
            _AbilityField(controller: controller.intel, label: l10n.sheetAbilityInt, characterId: controller.characterId),
          ]),
          editorRow([
            _AbilityField(controller: controller.wis,   label: l10n.sheetAbilityWis, characterId: controller.characterId),
            _AbilityField(controller: controller.cha,   label: l10n.sheetAbilityCha, characterId: controller.characterId),
          ]),
        ],
      ),
    );
  }
}

/// Campo numerico per una caratteristica (1-30) con il modificatore mostrato
/// nella label e un bottone 🎲 a fianco che apre il dice roller con
/// `1d20+mod` precompilato.
class _AbilityField extends StatelessWidget {
  const _AbilityField({
    required this.controller,
    required this.label,
    required this.characterId,
  });

  final TextEditingController controller;
  final String label;
  final String characterId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final n = tryParseInt(value.text);
        final mod = abilityMod(n);
        final modText = mod == null ? '—' : formatModifier(mod);
        return Row(
          children: [
            Expanded(
              child: editorTextField(
                controller,
                label: '$label  ($modText)',
                kind: EditorFieldKind.intRanged,
                min: 1, max: 30,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: mod == null
                  ? AppL10n.of(context).editorAbilityTooltipNeedsValue
                  : AppL10n.of(context).editorAbilityTooltipRoll(
                      '1d20${formatModifier(mod)}', label),
              icon: const Icon(Icons.casino_outlined),
              onPressed: mod == null
                  ? null
                  : () => showDiceRoller(
                        context,
                        initialFormula: '1d20${formatModifier(mod)}',
                        characterId:    characterId,
                      ),
            ),
          ],
        );
      },
    );
  }
}
