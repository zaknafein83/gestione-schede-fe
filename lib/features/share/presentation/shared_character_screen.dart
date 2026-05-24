import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../characters/logic/character_calc.dart';
import '../../characters/logic/character_catalog.dart';
import '../../characters/logic/conditions_catalog.dart';
import '../../characters/models/character_models.dart';
import '../data/shares_api.dart';

/// Pagina PUBBLICA: visualizza una scheda condivisa via token. Niente login,
/// niente modifiche, niente dice roller. Solo display in sezioni.
class SharedCharacterScreen extends ConsumerStatefulWidget {
  const SharedCharacterScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<SharedCharacterScreen> createState() => _SharedCharacterScreenState();
}

class _SharedCharacterScreenState extends ConsumerState<SharedCharacterScreen> {
  late Future<CharacterDto> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(sharesApiProvider).publicView(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.of(context).navSharedSheet),
      ),
      body: FutureBuilder<CharacterDto>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final e = snap.error;
            final msg = e is ApiError
                ? (e.status == 404 ? AppL10n.of(context).sharedInvalidLink : e.detail)
                : e.toString();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_off,
                        size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(msg, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return _CharacterReadOnlyView(c: snap.data!);
        },
      ),
    );
  }
}

class _CharacterReadOnlyView extends StatelessWidget {
  const _CharacterReadOnlyView({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(c: c),
            const SizedBox(height: 16),
            _HpAndConditions(c: c),
            const SizedBox(height: 16),
            _Section(
              title: l10n.sheetSectionAbilities,
              child: _AbilitiesGrid(c: c),
            ),
            _Section(
              title: l10n.sheetSectionSavesSkills,
              child: _SkillsTable(c: c),
            ),
            _Section(
              title: l10n.sheetSectionCombat,
              child: _CombatBlock(c: c),
            ),
            if (_hasSpells(c)) _Section(
              title: l10n.sheetSectionSpells,
              child: _SpellsBlock(c: c),
            ),
            if (_hasEquip(c)) _Section(
              title: l10n.sheetSectionEquipment,
              child: _EquipBlock(c: c),
            ),
            if (_hasTraits(c)) _Section(
              title: l10n.sheetSectionTraits,
              child: _TraitsBlock(c: c),
            ),
            if (_hasNotes(c)) _Section(
              title: l10n.sheetSectionNotes,
              child: _NotesBlock(c: c),
            ),
            const SizedBox(height: 8),
            _SrdFooter(),
          ],
        ),
      ),
    );
  }

  bool _hasSpells(CharacterDto c) {
    final slots = c.raw['spellSlots'] as Map<String, dynamic>?;
    final spells = c.raw['spells'] as List<dynamic>?;
    return (slots != null && slots.isNotEmpty) ||
           (spells != null && spells.isNotEmpty) ||
           _s(c, 'spellcastingClass')?.isNotEmpty == true;
  }

  bool _hasEquip(CharacterDto c) {
    final inv = c.raw['inventory'] as List<dynamic>?;
    final coins = c.raw['coins'] as Map<String, dynamic>?;
    return (inv != null && inv.isNotEmpty) || (coins != null && coins.values.any((v) => v != null));
  }

  bool _hasTraits(CharacterDto c) {
    return _s(c, 'personalityTraits')?.isNotEmpty == true
        || _s(c, 'ideals')?.isNotEmpty == true
        || _s(c, 'bonds')?.isNotEmpty == true
        || _s(c, 'flaws')?.isNotEmpty == true
        || _s(c, 'featuresAndTraits')?.isNotEmpty == true
        || (c.raw['languages'] as List?)?.isNotEmpty == true;
  }

  bool _hasNotes(CharacterDto c) {
    return _s(c, 'backstory')?.isNotEmpty == true
        || _s(c, 'alliesAndOrganizations')?.isNotEmpty == true
        || _s(c, 'physicalDescription')?.isNotEmpty == true
        || _s(c, 'notes')?.isNotEmpty == true;
  }

  static String? _s(CharacterDto c, String k) => c.raw[k] as String?;
}

// ===========================================================================
//                                  Header
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final subtitle = <String>[
      if (c.race?.isNotEmpty == true) c.race!,
      if (c.className?.isNotEmpty == true) c.className!,
      if (c.level != null) l10n.charactersLevelLabel(c.level!),
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: const Icon(Icons.person, size: 44),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name?.isNotEmpty == true ? c.name! : l10n.charactersNoName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  ..._row(c, 'background',  l10n.sheetHeaderBackground),
                  ..._row(c, 'alignment',   l10n.sheetHeaderAlignment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _row(CharacterDto c, String key, String label) {
    final v = c.raw[key] as String?;
    if (v == null || v.isEmpty) return const [];
    return [
      const SizedBox(height: 2),
      Text('$label: $v',
          style: TextStyle(
            color: Colors.grey[700], fontSize: 13,
          )),
    ];
  }
}

// ===========================================================================
//                              HP & condizioni
// ===========================================================================

class _HpAndConditions extends StatelessWidget {
  const _HpAndConditions({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hpMax = (c.raw['hpMax']     as num?)?.toInt();
    final hpCur = (c.raw['hpCurrent'] as num?)?.toInt();
    final hpTmp = (c.raw['hpTemp']    as num?)?.toInt() ?? 0;
    final conds = (c.raw['conditions'] as List<dynamic>?)
        ?.cast<String>()
        .map(findCondition)
        .whereType<ConditionEntry>()
        .toList()
        ?? const <ConditionEntry>[];

    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: scheme.error),
                const SizedBox(width: 8),
                Text(l10n.sheetHpLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Text(
                  '${hpCur ?? "—"} / ${hpMax ?? "—"}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (hpTmp > 0) ...[
                  const SizedBox(width: 8),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('+$hpTmp temp'),
                    backgroundColor: scheme.tertiaryContainer,
                  ),
                ],
              ],
            ),
            if (conds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final cond in conds)
                    Chip(
                      avatar: Icon(Icons.warning_amber_rounded,
                          size: 16, color: scheme.error),
                      label: Text(labelForCondition(cond.key, l10n)),
                      backgroundColor: scheme.errorContainer,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//                                 Section
// ===========================================================================

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//                              Caratteristiche
// ===========================================================================

class _AbilitiesGrid extends StatelessWidget {
  const _AbilitiesGrid({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final stats = <(String, String, int?)>[
      (l10n.sheetAbilityStr, 'str', (c.raw['str']   as num?)?.toInt()),
      (l10n.sheetAbilityDex, 'dex', (c.raw['dex']   as num?)?.toInt()),
      (l10n.sheetAbilityCon, 'con', (c.raw['con']   as num?)?.toInt()),
      (l10n.sheetAbilityInt, 'int', (c.raw['intel'] as num?)?.toInt()),
      (l10n.sheetAbilityWis, 'wis', (c.raw['wis']   as num?)?.toInt()),
      (l10n.sheetAbilityCha, 'cha', (c.raw['cha']   as num?)?.toInt()),
    ];

    return LayoutBuilder(builder: (context, lc) {
      final cols = lc.maxWidth >= 700 ? 6 : (lc.maxWidth >= 400 ? 3 : 2);
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          for (final (label, _, score) in stats)
            _AbilityCard(label: label, score: score, mod: abilityMod(score)),
        ],
      );
    });
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({required this.label, required this.score, required this.mod});
  final String label;
  final int?   score;
  final int?   mod;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            mod == null ? '—' : formatModifier(mod!),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            score == null ? '—' : '$score',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//                               Skills & TS
// ===========================================================================

class _SkillsTable extends StatelessWidget {
  const _SkillsTable({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final mods = <String, int?>{
      'str': abilityMod((c.raw['str']   as num?)?.toInt()),
      'dex': abilityMod((c.raw['dex']   as num?)?.toInt()),
      'con': abilityMod((c.raw['con']   as num?)?.toInt()),
      'int': abilityMod((c.raw['intel'] as num?)?.toInt()),
      'wis': abilityMod((c.raw['wis']   as num?)?.toInt()),
      'cha': abilityMod((c.raw['cha']   as num?)?.toInt()),
    };
    final overrideProf = (c.raw['proficiencyBonus'] as num?)?.toInt();
    final autoProf     = profBonusForLevel(c.level);
    final pb           = overrideProf ?? autoProf;

    final st = (c.raw['savingThrows'] as Map<String, dynamic>?) ?? const {};
    final sk = (c.raw['skills']       as Map<String, dynamic>?) ?? const {};

    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.sheetSavingThrowsLabel,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final e in savingThrowsCatalog)
          _ReadOnlyFlagRow(
            label: labelForSavingThrow(e.key, l10n),
            ability: e.abilityKey,
            entry: st[e.key] as Map<String, dynamic>?,
            abilityMod: mods[e.abilityKey],
            profBonus:  pb,
          ),
        const SizedBox(height: 16),
        Text(l10n.sheetSkillsLabel,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final e in skillsCatalog)
          _ReadOnlyFlagRow(
            label: labelForSkill(e.key, l10n),
            ability: e.abilityKey,
            entry: sk[e.key] as Map<String, dynamic>?,
            abilityMod: mods[e.abilityKey],
            profBonus:  pb,
          ),
      ],
    );
  }
}

class _ReadOnlyFlagRow extends StatelessWidget {
  const _ReadOnlyFlagRow({
    required this.label,
    required this.ability,
    required this.entry,
    required this.abilityMod,
    required this.profBonus,
  });

  final String  label;
  final String  ability;
  final Map<String, dynamic>? entry;
  final int?    abilityMod;
  final int?    profBonus;

  @override
  Widget build(BuildContext context) {
    final proficient = (entry?['proficient'] as bool?) ?? false;
    final expertise  = (entry?['expertise']  as bool?) ?? false;
    final cv         = (entry?['customValue'] as num?)?.toInt();

    int? finalValue() {
      if (cv != null) return cv;
      if (abilityMod == null) return null;
      var v = abilityMod!;
      if (proficient && profBonus != null) {
        v += profBonus!;
        if (expertise) v += profBonus!;
      }
      return v;
    }

    final v = finalValue();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            proficient
                ? (expertise ? Icons.star : Icons.check_circle)
                : Icons.radio_button_unchecked,
            size: 16,
            color: proficient
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: label),
              TextSpan(
                text: '  · ${abilityShort(ability, AppL10n.of(context))}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ])),
          ),
          SizedBox(
            width: 48,
            child: Text(
              v == null ? '—' : formatModifier(v),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//                              Combat block
// ===========================================================================

class _CombatBlock extends StatelessWidget {
  const _CombatBlock({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    int? n(String k) => (c.raw[k] as num?)?.toInt();
    final items = <(String, String)>[
      (l10n.sheetCombatAc,         n('armorClass')?.toString() ?? '—'),
      (l10n.sheetCombatInitiative, n('initiative') != null ? formatModifier(n('initiative')!) : '—'),
      (l10n.sheetCombatSpeed,      n('speed') != null ? '${n('speed')} ft' : '—'),
      (l10n.sheetCombatProfBonus,  n('proficiencyBonus') != null ? formatModifier(n('proficiencyBonus')!) : '—'),
      (l10n.sheetCombatHitDice,    _hitDice(n('hitDiceTotal'), n('hitDiceUsed'))),
      (l10n.sheetCombatDeathSaves, _deathSaves(l10n, n('deathSavesSuccesses'), n('deathSavesFailures'))),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final (label, value) in items)
          _LabelValue(label: label, value: value),
      ],
    );
  }

  String _hitDice(int? tot, int? used) {
    if (tot == null) return '—';
    final u = used ?? 0;
    return '${tot - u} / $tot';
  }

  String _deathSaves(AppL10n l10n, int? s, int? f) {
    if ((s ?? 0) == 0 && (f ?? 0) == 0) return '—';
    return l10n.sheetCombatDeathSavesValue(s ?? 0, f ?? 0);
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

// ===========================================================================
//                               Spells block
// ===========================================================================

class _SpellsBlock extends StatelessWidget {
  const _SpellsBlock({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final slots  = (c.raw['spellSlots'] as Map<String, dynamic>?) ?? const {};
    final spells = (c.raw['spells']     as List<dynamic>?) ?? const [];
    final ic     = c.raw['spellcastingClass'] as String?;
    final dc     = (c.raw['spellSaveDc']      as num?)?.toInt();
    final bonus  = (c.raw['spellAttackBonus'] as num?)?.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          children: [
            if (ic?.isNotEmpty == true) _LabelValue(label: l10n.sheetSpellsClass,        value: ic!),
            if (dc != null)             _LabelValue(label: l10n.sheetSpellsSaveDc,       value: '$dc'),
            if (bonus != null)          _LabelValue(label: l10n.sheetSpellsAttackBonus,  value: formatModifier(bonus)),
          ],
        ),
        if (slots.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.sheetSpellsSlotsByLevel,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (var i = 1; i <= 9; i++)
            if (slots['$i'] != null)
              _SlotRowRO(
                level: i,
                max:     (slots['$i']['max']     as num?)?.toInt(),
                current: (slots['$i']['current'] as num?)?.toInt(),
              ),
        ],
        if (spells.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.sheetSpellsKnown,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final s in spells.cast<Map<String, dynamic>>())
            _SpellRowRO(spell: s),
        ],
      ],
    );
  }
}

class _SlotRowRO extends StatelessWidget {
  const _SlotRowRO({required this.level, required this.max, required this.current});
  final int level;
  final int? max;
  final int? current;

  @override
  Widget build(BuildContext context) {
    final m = max ?? 0;
    final c = (current ?? m).clamp(0, m);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(AppL10n.of(context).sheetSpellLevelShort(level))),
          Wrap(
            spacing: 2,
            children: [
              for (var i = 0; i < m; i++)
                Icon(
                  i < c ? Icons.circle : Icons.circle_outlined,
                  size: 18,
                  color: i < c ? scheme.primary : scheme.outline,
                ),
            ],
          ),
          const SizedBox(width: 8),
          Text('$c / $m', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SpellRowRO extends StatelessWidget {
  const _SpellRowRO({required this.spell});
  final Map<String, dynamic> spell;

  @override
  Widget build(BuildContext context) {
    final name           = spell['name']    as String?;
    final level          = (spell['level']  as num?)?.toInt();
    final notes          = spell['notes']   as String?;
    final school         = spell['school']  as String?;
    final castingTime    = spell['castingTime'] as String?;
    final range          = spell['range']   as String?;
    final ritual         = (spell['ritual']         as bool?) ?? false;
    final concentration  = (spell['concentration']  as bool?) ?? false;
    final prepared       = (spell['prepared']       as bool?) ?? false;
    final alwaysPrepared = (spell['alwaysPrepared'] as bool?) ?? false;
    if ((name == null || name.isEmpty) && level == null) {
      return const SizedBox.shrink();
    }
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t      = Theme.of(context).textTheme;
    final subtitle = [
      ?school,
      ?castingTime,
      ?range,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(level == null
                ? '—'
                : (level == 0 ? l10n.sheetSpellCantrip : l10n.sheetSpellLevelShort(level))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      name ?? l10n.charactersNoName,
                      style: TextStyle(
                        fontWeight: (prepared || alwaysPrepared)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (ritual)
                      _miniChip('R', scheme.tertiaryContainer, scheme.onTertiaryContainer),
                    if (concentration)
                      _miniChip('C', scheme.secondaryContainer, scheme.onSecondaryContainer),
                  ],
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle,
                        style: t.bodySmall?.copyWith(color: scheme.outline)),
                  ),
                if (notes?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(notes!, style: t.bodySmall),
                  ),
              ],
            ),
          ),
          if (alwaysPrepared)
            Tooltip(
              message: l10n.sheetSpellAlwaysPrepared,
              child: Icon(Icons.push_pin, size: 16, color: scheme.primary),
            )
          else if (prepared)
            Tooltip(
              message: l10n.sheetSpellPrepared,
              child: Icon(Icons.bookmark, size: 16, color: scheme.primary),
            ),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

// ===========================================================================
//                              Equip / Tratti / Note
// ===========================================================================

class _EquipBlock extends StatelessWidget {
  const _EquipBlock({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final coins = (c.raw['coins'] as Map<String, dynamic>?) ?? const {};
    final inv   = (c.raw['inventory'] as List<dynamic>?) ?? const [];

    final coinChips = <Widget>[
      for (final k in const ['cp','sp','ep','gp','pp'])
        if (coins[k] != null)
          Chip(label: Text('${coins[k]} ${k.toUpperCase()}')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (coinChips.isNotEmpty)
          Wrap(spacing: 6, runSpacing: 4, children: coinChips),
        if (inv.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(AppL10n.of(context).sheetEquipmentInventory,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final it in inv.cast<Map<String, dynamic>>())
            _InventoryRowRO(item: it),
        ],
      ],
    );
  }
}

class _InventoryRowRO extends StatelessWidget {
  const _InventoryRowRO({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name  = item['name']     as String? ?? AppL10n.of(context).charactersNoName;
    final qty   = (item['qty']     as num?)?.toInt();
    final w     = (item['weightLb'] as num?)?.toDouble();
    final notes = item['notes']     as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${qty != null ? "$qty× " : ""}$name'
            '${w != null ? " (${w}lb)" : ""}',
          ),
          if (notes?.isNotEmpty == true)
            Text(notes!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TraitsBlock extends StatelessWidget {
  const _TraitsBlock({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n  = AppL10n.of(context);
    final langs = (c.raw['languages'] as List<dynamic>?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _txt(c, 'personalityTraits', l10n.sheetTraitsPersonality),
        _txt(c, 'ideals',            l10n.sheetTraitsIdeals),
        _txt(c, 'bonds',             l10n.sheetTraitsBonds),
        _txt(c, 'flaws',             l10n.sheetTraitsFlaws),
        if (langs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.sheetTraitsLanguages,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final l in langs) Chip(label: Text(l)),
          ]),
        ],
        _txt(c, 'armorProficiencies',  l10n.sheetTraitsArmor),
        _txt(c, 'weaponProficiencies', l10n.sheetTraitsWeapons),
        _txt(c, 'toolProficiencies',   l10n.sheetTraitsTools),
        _txt(c, 'featuresAndTraits',   l10n.sheetTraitsFeatures),
      ],
    );
  }

  Widget _txt(CharacterDto c, String key, String label) {
    final v = c.raw[key] as String?;
    if (v == null || v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(v),
        ],
      ),
    );
  }
}

class _SrdFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Text(
        AppL10n.of(context).aboutSrdCredit,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.outline,
            ),
      ),
    );
  }
}

class _NotesBlock extends StatelessWidget {
  const _NotesBlock({required this.c});
  final CharacterDto c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _txt(c, 'backstory',              l10n.sheetNotesBackstory),
        _txt(c, 'alliesAndOrganizations', l10n.sheetNotesAllies),
        _txt(c, 'symbol',                 l10n.sheetNotesSymbol),
        _txt(c, 'physicalDescription',    l10n.sheetNotesPhysical),
        _txt(c, 'notes',                  l10n.sheetNotesNotes),
      ],
    );
  }

  Widget _txt(CharacterDto c, String key, String label) {
    final v = c.raw[key] as String?;
    if (v == null || v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(v),
        ],
      ),
    );
  }
}
