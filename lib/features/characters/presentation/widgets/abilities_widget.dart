import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dice/presentation/dice_roller_dialog.dart';
import '../../logic/character_calc.dart';
import '../../logic/character_catalog.dart';
import '../character_editor_controller.dart';
import '../character_editor_models.dart';

/// Tab "Abilità": elenco skill con calcolo automatico del modificatore.
/// I tiri salvezza sono in [SavesWidget] (widget separato).
class AbilitiesWidget extends StatelessWidget {
  const AbilitiesWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    return _AbilitiesScaffold(
      controller: controller,
      builder: (context, mods, profBonus) {
        final l10n = AppL10n.of(context);
        return [
          Text(l10n.sheetSkillsLabel,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _AbilitiesHeader(),
          for (final e in skillsCatalog)
            _FlagRowTile(
              catalog:    e,
              row:        controller.skills[e.key]!,
              abilityMod: mods[e.abilityKey],
              profBonus:  profBonus,
              characterId: controller.characterId,
              onProficientChanged: (v) => controller.setSkillProficient(e.key, v),
              onExpertiseChanged:  (v) => controller.setSkillExpertise(e.key, v),
              isSkill: true,
            ),
        ];
      },
    );
  }
}

/// Tab/Widget "Tiri salvezza": una riga per ogni saving throw, con i due
/// checkbox (competenza/maestria) e il totale calcolato. Stesso look del
/// [AbilitiesWidget] per coerenza visiva fra i due.
class SavesWidget extends StatelessWidget {
  const SavesWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    return _AbilitiesScaffold(
      controller: controller,
      builder: (context, mods, profBonus) {
        final l10n = AppL10n.of(context);
        return [
          Text(l10n.sheetSavingThrowsLabel,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // showExpertise=false: i TS in 5e non hanno la maestria.
          const _AbilitiesHeader(showExpertise: false),
          for (final e in savingThrowsCatalog)
            _FlagRowTile(
              catalog:    e,
              row:        controller.savingThrows[e.key]!,
              abilityMod: mods[e.abilityKey],
              profBonus:  profBonus,
              characterId: controller.characterId,
              onProficientChanged: (v) => controller.setSavingThrowProficient(e.key, v),
              onExpertiseChanged:  (_) {},  // no-op: nessun checkbox maestria sui TS
              isSkill: false,
            ),
        ];
      },
    );
  }
}

/// Scaffolding condiviso fra [AbilitiesWidget] e [SavesWidget]: ascolta i
/// controller delle stat, calcola modificatori e prof. bonus e mostra la chip
/// del prof. bonus in alto. Il [builder] riceve mods e profBonus e produce le
/// righe specifiche del widget.
class _AbilitiesScaffold extends StatelessWidget {
  const _AbilitiesScaffold({required this.controller, required this.builder});

  final CharacterEditorController controller;
  final List<Widget> Function(
    BuildContext context,
    Map<String, int?> mods,
    int? profBonus,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final listenables = [
      controller.str, controller.dex, controller.con,
      controller.intel, controller.wis, controller.cha,
      controller.level, controller.proficiencyBonus,
    ];
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        final mods = <String, int?>{
          'str': abilityMod(tryParseInt(controller.str.text)),
          'dex': abilityMod(tryParseInt(controller.dex.text)),
          'con': abilityMod(tryParseInt(controller.con.text)),
          'int': abilityMod(tryParseInt(controller.intel.text)),
          'wis': abilityMod(tryParseInt(controller.wis.text)),
          'cha': abilityMod(tryParseInt(controller.cha.text)),
        };
        final overrideProf = tryParseInt(controller.proficiencyBonus.text);
        final autoProf     = profBonusForLevel(tryParseInt(controller.level.text));
        final profBonus    = overrideProf ?? autoProf;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Spacer(),
                  _ProfBonusChip(profBonus: profBonus, fromOverride: overrideProf != null),
                ],
              ),
              const SizedBox(height: 8),
              ...builder(context, mods, profBonus),
            ],
          ),
        );
      },
    );
  }
}

class _ProfBonusChip extends StatelessWidget {
  const _ProfBonusChip({required this.profBonus, required this.fromOverride});
  final int? profBonus;
  final bool fromOverride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final text = profBonus == null ? '—' : formatModifier(profBonus!);
    return Tooltip(
      message: fromOverride
          ? l10n.editorProfBonusOverrideTooltip
          : l10n.editorProfBonusAutoTooltip,
      child: Chip(
        avatar: const Icon(Icons.shield_outlined, size: 18),
        label: Text(l10n.editorProfBonusChipLabel(text)),
        backgroundColor: fromOverride
            ? Theme.of(context).colorScheme.tertiaryContainer
            : null,
      ),
    );
  }
}

/// Header colonne per le sezioni TS e Skill. Per i TS mostriamo solo
/// "Competenza" e "Totale" (in D&D 5e i tiri salvezza non beneficiano di
/// Maestria/Expertise — quella e' una feature delle skill, es. Rogue).
class _AbilitiesHeader extends StatelessWidget {
  const _AbilitiesHeader({this.showExpertise = true});

  /// Se false (sezione Tiri salvezza) la colonna "Maestria" e' nascosta.
  final bool showExpertise;

  @override
  Widget build(BuildContext context) {
    final l10n  = AppL10n.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: Text(l10n.editorColComp, style: style))),
          if (showExpertise)
            SizedBox(width: 48, child: Center(child: Text(l10n.editorColExpert, style: style))),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox.shrink()),
          SizedBox(
            width: 48,
            child: Text(l10n.editorColTotal, textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FlagRowTile extends StatelessWidget {
  const _FlagRowTile({
    required this.catalog,
    required this.row,
    required this.abilityMod,
    required this.profBonus,
    required this.characterId,
    required this.onProficientChanged,
    required this.onExpertiseChanged,
    required this.isSkill,
  });

  final CatalogEntry  catalog;
  final FlagRow       row;
  final int?          abilityMod;
  final int?          profBonus;
  final String        characterId;
  final ValueChanged<bool> onProficientChanged;
  final ValueChanged<bool> onExpertiseChanged;
  /// true se il tile fa parte della sezione skill (label via [labelForSkill]),
  /// false se TS (label via [labelForSavingThrow]).
  final bool          isSkill;

  /// Valore finale: customValue override → altrimenti
  /// mod + (proficient ? prof : 0) + (expertise && isSkill ? prof : 0).
  /// Null se ability/profBonus non disponibili e nessun override. La maestria
  /// (expertise) e' applicata solo per le skill: i TS in 5e non la prevedono.
  int? _finalValue() {
    if (row.customValue != null) return row.customValue;
    if (abilityMod == null) return null;
    var v = abilityMod!;
    if (row.proficient && profBonus != null) {
      v += profBonus!;
      if (isSkill && row.expertise) v += profBonus!;
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final v = _finalValue();
    final canRoll = v != null;
    return InkWell(
      onTap: canRoll
          ? () => showDiceRoller(
                context,
                initialFormula: '1d20${formatModifier(v)}',
                characterId:    characterId,
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: row.proficient,
              onChanged: (b) => onProficientChanged(b ?? false),
            ),
            // Maestria/Expertise solo per le skill: in 5e i TS non la usano.
            if (isSkill)
              Checkbox(
                value: row.expertise && row.proficient,
                onChanged: row.proficient
                    ? (b) => onExpertiseChanged(b ?? false)
                    : null,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Builder(builder: (ctx) {
                final l10n = AppL10n.of(ctx);
                final label = isSkill
                    ? labelForSkill(catalog.key, l10n)
                    : labelForSavingThrow(catalog.key, l10n);
                return Text.rich(
                  TextSpan(children: [
                    TextSpan(text: label),
                    TextSpan(
                      text: '  · ${abilityShort(catalog.abilityKey, l10n)}',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    if (row.customValue != null)
                      TextSpan(
                        text: '  · ${l10n.editorFlagOverrideTag}',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: Theme.of(ctx).colorScheme.tertiary),
                      ),
                  ]),
                );
              }),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              child: Text(
                v == null ? '—' : formatModifier(v),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
