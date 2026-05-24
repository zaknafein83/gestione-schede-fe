import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../../characters/logic/character_calc.dart';
import '../../characters/logic/character_catalog.dart';
import '../../characters/logic/conditions_catalog.dart';

/// Costruisce un PDF "scheda di gioco" a partire dal JSON raw della scheda.
/// Layout A4 portrait, una/due pagine. Le label sono localizzate via [l10n]
/// (il PDF rispetta la lingua attiva nell'app al momento dell'export).
Future<Uint8List> buildCharacterPdf(Map<String, dynamic> raw, AppL10n l10n) async {
  final doc = pw.Document();

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
    build: (ctx) => [
      _header(raw, l10n),
      pw.SizedBox(height: 10),
      _hpAndConditions(raw, l10n),
      pw.SizedBox(height: 10),
      _section(l10n.sheetSectionAbilities,    _abilitiesBox(raw, l10n)),
      _section(l10n.sheetSavingThrowsLabel,   _flagsBlock(raw, source: 'savingThrows', catalog: savingThrowsCatalog, l10n: l10n, isSkill: false)),
      _section(l10n.sheetSkillsLabel,         _flagsBlock(raw, source: 'skills',       catalog: skillsCatalog,       l10n: l10n, isSkill: true)),
      _section(l10n.sheetSectionCombat,       _combatBlock(raw, l10n)),
      if (_hasSpells(raw))     _section(l10n.sheetSectionSpells,     _spellsBlock(raw, l10n)),
      if (_hasEquip(raw))      _section(l10n.sheetSectionEquipment,  _equipBlock(raw)),
      if (_hasTraits(raw))     _section(l10n.sheetSectionTraits,     _traitsBlock(raw, l10n)),
      if (_hasNotes(raw))      _section(l10n.sheetSectionNotes,      _notesBlock(raw, l10n)),
      pw.SizedBox(height: 12),
      _srdFooter(),
    ],
  ));

  return doc.save();
}

// ===========================================================================
//                              SRD footer (legal)
// ===========================================================================

pw.Widget _srdFooter() {
  // Bilingue: il PDF non ha context i18n. Una riga corta per ogni lingua.
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Divider(thickness: 0.3, color: PdfColors.grey400),
      pw.SizedBox(height: 4),
      pw.Text(
        'Dati incantesimi dal D&D 5.1 SRD (CC BY 4.0) di Wizards of the Coast. '
        'App non affiliata né approvata da Wizards of the Coast.',
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Spell data from the D&D 5.1 SRD (CC BY 4.0) by Wizards of the Coast. '
        'This app is not affiliated with or endorsed by Wizards of the Coast.',
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
      ),
    ],
  );
}

// ===========================================================================
//                                  Header
// ===========================================================================

pw.Widget _header(Map<String, dynamic> raw, AppL10n l10n) {
  final name  = (raw['name'] as String?) ?? l10n.charactersNoName;
  final parts = <String>[
    if ((raw['race']      as String?)?.isNotEmpty == true) raw['race'] as String,
    if ((raw['className'] as String?)?.isNotEmpty == true) raw['className'] as String,
    if (raw['level'] != null) l10n.charactersLevelLabel(raw['level']!),
  ];
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.deepPurple50,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        if (parts.isNotEmpty) pw.Text(parts.join(' · '), style: const pw.TextStyle(fontSize: 12)),
        if ((raw['background'] as String?)?.isNotEmpty == true)
          pw.Text('${l10n.sheetHeaderBackground}: ${raw['background']}', style: const pw.TextStyle(fontSize: 10)),
        if ((raw['alignment']  as String?)?.isNotEmpty == true)
          pw.Text('${l10n.sheetHeaderAlignment}: ${raw['alignment']}', style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );
}

// ===========================================================================
//                              HP & condizioni
// ===========================================================================

pw.Widget _hpAndConditions(Map<String, dynamic> raw, AppL10n l10n) {
  final hpMax = (raw['hpMax']     as num?)?.toInt();
  final hpCur = (raw['hpCurrent'] as num?)?.toInt();
  final hpTmp = (raw['hpTemp']    as num?)?.toInt() ?? 0;
  final conds = (raw['conditions'] as List<dynamic>?)
      ?.cast<String>()
      .map(findCondition)
      .whereType<ConditionEntry>()
      .toList()
      ?? const <ConditionEntry>[];

  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey200,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          pw.Text('${l10n.sheetHpLabel} ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text('${hpCur ?? "—"} / ${hpMax ?? "—"}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          if (hpTmp > 0) ...[
            pw.SizedBox(width: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text('+$hpTmp temp', style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ]),
        if (conds.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 4, runSpacing: 4,
            children: [
              for (final c in conds)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(labelForCondition(c.key, l10n), style: const pw.TextStyle(fontSize: 9)),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

// ===========================================================================
//                                Section helper
// ===========================================================================

pw.Widget _section(String title, pw.Widget child) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.Divider(height: 6, thickness: 0.4),
        child,
      ],
    ),
  );
}

// ===========================================================================
//                                Caratteristiche
// ===========================================================================

pw.Widget _abilitiesBox(Map<String, dynamic> raw, AppL10n l10n) {
  final stats = <(String, int?)>[
    (l10n.abilityShortStr, (raw['str']   as num?)?.toInt()),
    (l10n.abilityShortDex, (raw['dex']   as num?)?.toInt()),
    (l10n.abilityShortCon, (raw['con']   as num?)?.toInt()),
    (l10n.abilityShortInt, (raw['intel'] as num?)?.toInt()),
    (l10n.abilityShortWis, (raw['wis']   as num?)?.toInt()),
    (l10n.abilityShortCha, (raw['cha']   as num?)?.toInt()),
  ];
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      for (final (label, score) in stats)
        pw.Container(
          width: 70, height: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                abilityMod(score) == null ? '—' : formatModifier(abilityMod(score)!),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(score == null ? '—' : '$score',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
    ],
  );
}

// ===========================================================================
//                                 Skills/TS
// ===========================================================================

pw.Widget _flagsBlock(
  Map<String, dynamic> raw, {
  required String source,
  required List<CatalogEntry> catalog,
  required AppL10n l10n,
  required bool isSkill,
}) {
  final mods = <String, int?>{
    'str': abilityMod((raw['str']   as num?)?.toInt()),
    'dex': abilityMod((raw['dex']   as num?)?.toInt()),
    'con': abilityMod((raw['con']   as num?)?.toInt()),
    'int': abilityMod((raw['intel'] as num?)?.toInt()),
    'wis': abilityMod((raw['wis']   as num?)?.toInt()),
    'cha': abilityMod((raw['cha']   as num?)?.toInt()),
  };
  final overrideProf = (raw['proficiencyBonus'] as num?)?.toInt();
  final autoProf     = profBonusForLevel((raw['level'] as num?)?.toInt());
  final pb           = overrideProf ?? autoProf;
  final entries      = (raw[source] as Map<String, dynamic>?) ?? const {};

  return pw.Wrap(
    spacing: 6,
    runSpacing: 2,
    children: [
      for (final c in catalog)
        _flagRow(
          c,
          entries[c.key] as Map<String, dynamic>?,
          mods[c.abilityKey],
          pb,
          isSkill ? labelForSkill(c.key, l10n) : labelForSavingThrow(c.key, l10n),
          abilityShort(c.abilityKey, l10n),
        ),
    ],
  );
}

pw.Widget _flagRow(CatalogEntry c, Map<String, dynamic>? entry, int? mod, int? pb, String label, String abilityShortLabel) {
  final proficient = (entry?['proficient'] as bool?) ?? false;
  final expertise  = (entry?['expertise']  as bool?) ?? false;
  final cv         = (entry?['customValue'] as num?)?.toInt();

  int? finalValue() {
    if (cv != null) return cv;
    if (mod == null) return null;
    var v = mod;
    if (proficient && pb != null) {
      v += pb;
      if (expertise) v += pb;
    }
    return v;
  }

  final v = finalValue();
  final marker = expertise ? '◆' : (proficient ? '●' : '○');
  return pw.Container(
    width: 175,
    child: pw.Row(
      children: [
        pw.Text(marker, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Text(
            '$label ($abilityShortLabel)',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Text(
          v == null ? '—' : formatModifier(v),
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

// ===========================================================================
//                                  Combat
// ===========================================================================

pw.Widget _combatBlock(Map<String, dynamic> raw, AppL10n l10n) {
  int? n(String k) => (raw[k] as num?)?.toInt();
  final items = <(String, String)>[
    (l10n.sheetCombatAc,         n('armorClass')?.toString() ?? '—'),
    (l10n.sheetCombatInitiative, n('initiative') != null ? formatModifier(n('initiative')!) : '—'),
    (l10n.sheetCombatSpeed,      n('speed') != null ? '${n('speed')} ft' : '—'),
    (l10n.sheetCombatProfBonus,  n('proficiencyBonus') != null ? formatModifier(n('proficiencyBonus')!) : '—'),
    (l10n.sheetCombatHitDice,    _hitDice(n('hitDiceTotal'), n('hitDiceUsed'))),
    (l10n.sheetCombatDeathSaves, l10n.sheetCombatDeathSavesValue(n('deathSavesSuccesses') ?? 0, n('deathSavesFailures') ?? 0)),
  ];
  return pw.Wrap(
    spacing: 16, runSpacing: 4,
    children: [
      for (final (label, value) in items)
        pw.Container(
          width: 110,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
              pw.Text(value,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
    ],
  );
}

String _hitDice(int? tot, int? used) {
  if (tot == null) return '—';
  final u = used ?? 0;
  return '${tot - u} / $tot';
}

// ===========================================================================
//                                 Spells
// ===========================================================================

bool _hasSpells(Map<String, dynamic> raw) {
  final slots = raw['spellSlots'] as Map<String, dynamic>?;
  final spells = raw['spells'] as List<dynamic>?;
  return (slots != null && slots.isNotEmpty)
      || (spells != null && spells.isNotEmpty)
      || (raw['spellcastingClass'] as String?)?.isNotEmpty == true;
}

pw.Widget _spellsBlock(Map<String, dynamic> raw, AppL10n l10n) {
  final slots = (raw['spellSlots'] as Map<String, dynamic>?) ?? const {};
  final spells = (raw['spells'] as List<dynamic>?) ?? const [];
  final dc = (raw['spellSaveDc'] as num?)?.toInt();
  final ab = (raw['spellAttackBonus'] as num?)?.toInt();
  final ic = raw['spellcastingClass'] as String?;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(children: [
        if (ic?.isNotEmpty == true) ...[
          pw.Text('${l10n.sheetSpellsClass}: ', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(ic!, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 10),
        ],
        if (dc != null) pw.Text('${l10n.sheetSpellsSaveDc}: $dc   ', style: const pw.TextStyle(fontSize: 9)),
        if (ab != null) pw.Text('${l10n.sheetSpellsAttackBonus}: ${formatModifier(ab)}',
            style: const pw.TextStyle(fontSize: 9)),
      ]),
      pw.SizedBox(height: 4),
      for (var i = 1; i <= 9; i++)
        if (slots['$i'] != null)
          _slotLine(i,
              (slots['$i']['max']     as num?)?.toInt(),
              (slots['$i']['current'] as num?)?.toInt(),
              l10n),
      if (spells.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Text('${l10n.sheetSpellsKnown}:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        for (final s in spells.cast<Map<String, dynamic>>())
          if ((s['name'] as String?)?.isNotEmpty == true)
            pw.Bullet(
              text: _spellLine(s, l10n),
              style: const pw.TextStyle(fontSize: 9),
            ),
      ],
    ],
  );
}

String _spellLine(Map<String, dynamic> s, AppL10n l10n) {
  final lv     = (s['level'] as num?)?.toInt();
  final prep   = (s['prepared'] as bool?) == true;
  final always = (s['alwaysPrepared'] as bool?) == true;
  final ritual = (s['ritual']        as bool?) == true;
  final conc   = (s['concentration'] as bool?) == true;
  final school = s['school'] as String?;
  final lvText = lv == null
      ? ''
      : (lv == 0 ? '${l10n.sheetSpellCantrip} ' : '${l10n.sheetSpellLevelShort(lv)} ');
  final tags   = <String>[
    ?school,
    if (ritual) l10n.customSpellRitual,
    if (conc)   l10n.customSpellConcentration,
  ];
  final mark = always
      ? ' ◆ ${l10n.sheetSpellAlwaysPrepared}'
      : prep ? ' ✓ ${l10n.sheetSpellPrepared}' : '';
  final tail = tags.isEmpty ? '' : ' — ${tags.join(", ")}';
  return '$lvText${s['name']}$tail$mark';
}

pw.Widget _slotLine(int lvl, int? max, int? current, AppL10n l10n) {
  final m = max ?? 0;
  final c = (current ?? m).clamp(0, m);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      children: [
        pw.Container(width: 40,
            child: pw.Text(l10n.sheetSpellLevelShort(lvl), style: const pw.TextStyle(fontSize: 9))),
        for (var i = 0; i < m; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 2),
            child: pw.Container(
              width: 8, height: 8,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: i < c ? PdfColors.deepPurple : const PdfColor(0, 0, 0, 0),
                border: pw.Border.all(color: PdfColors.deepPurple, width: 0.6),
              ),
            ),
          ),
        pw.SizedBox(width: 6),
        pw.Text('$c / $m', style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}

// ===========================================================================
//                                  Equip
// ===========================================================================

bool _hasEquip(Map<String, dynamic> raw) {
  final inv   = raw['inventory'] as List<dynamic>?;
  final coins = raw['coins'] as Map<String, dynamic>?;
  return (inv != null && inv.isNotEmpty)
      || (coins != null && coins.values.any((v) => v != null));
}

pw.Widget _equipBlock(Map<String, dynamic> raw) {
  final coins = (raw['coins'] as Map<String, dynamic>?) ?? const {};
  final inv   = (raw['inventory'] as List<dynamic>?) ?? const [];

  final coinStr = [
    for (final k in const ['cp','sp','ep','gp','pp'])
      if (coins[k] != null) '${coins[k]} ${k.toUpperCase()}',
  ].join('  ');

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      if (coinStr.isNotEmpty)
        pw.Text(coinStr, style: const pw.TextStyle(fontSize: 9)),
      if (inv.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        for (final it in inv.cast<Map<String, dynamic>>())
          _inventoryLine(it),
      ],
    ],
  );
}

pw.Widget _inventoryLine(Map<String, dynamic> it) {
  final name  = it['name']     as String? ?? '';
  final qty   = (it['qty']     as num?)?.toInt();
  final w     = (it['weightLb'] as num?)?.toDouble();
  if (name.isEmpty) return pw.SizedBox.shrink();
  final line = '${qty != null ? "$qty× " : ""}$name${w != null ? " (${w}lb)" : ""}';
  return pw.Bullet(text: line, style: const pw.TextStyle(fontSize: 9));
}

// ===========================================================================
//                                  Tratti
// ===========================================================================

bool _hasTraits(Map<String, dynamic> raw) {
  return (raw['personalityTraits'] as String?)?.isNotEmpty == true
      || (raw['ideals']            as String?)?.isNotEmpty == true
      || (raw['bonds']             as String?)?.isNotEmpty == true
      || (raw['flaws']             as String?)?.isNotEmpty == true
      || (raw['featuresAndTraits'] as String?)?.isNotEmpty == true
      || ((raw['languages'] as List?)?.isNotEmpty == true);
}

pw.Widget _traitsBlock(Map<String, dynamic> raw, AppL10n l10n) {
  final langs = (raw['languages'] as List<dynamic>?)?.cast<String>() ?? const [];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _para(raw, 'personalityTraits', l10n.sheetTraitsPersonality),
      _para(raw, 'ideals',            l10n.sheetTraitsIdeals),
      _para(raw, 'bonds',             l10n.sheetTraitsBonds),
      _para(raw, 'flaws',             l10n.sheetTraitsFlaws),
      if (langs.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text('${l10n.sheetTraitsLanguages}: ${langs.join(", ")}',
              style: const pw.TextStyle(fontSize: 9)),
        ),
      _para(raw, 'armorProficiencies',  l10n.sheetTraitsArmor),
      _para(raw, 'weaponProficiencies', l10n.sheetTraitsWeapons),
      _para(raw, 'toolProficiencies',   l10n.sheetTraitsTools),
      _para(raw, 'featuresAndTraits',   l10n.sheetTraitsFeatures),
    ],
  );
}

// ===========================================================================
//                                   Note
// ===========================================================================

bool _hasNotes(Map<String, dynamic> raw) {
  return (raw['backstory'] as String?)?.isNotEmpty == true
      || (raw['alliesAndOrganizations'] as String?)?.isNotEmpty == true
      || (raw['physicalDescription']    as String?)?.isNotEmpty == true
      || (raw['notes']                  as String?)?.isNotEmpty == true;
}

pw.Widget _notesBlock(Map<String, dynamic> raw, AppL10n l10n) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _para(raw, 'backstory',              l10n.sheetNotesBackstory),
      _para(raw, 'alliesAndOrganizations', l10n.sheetNotesAllies),
      _para(raw, 'symbol',                 l10n.sheetNotesSymbol),
      _para(raw, 'physicalDescription',    l10n.sheetNotesPhysical),
      _para(raw, 'notes',                  l10n.sheetNotesNotes),
    ],
  );
}

pw.Widget _para(Map<String, dynamic> raw, String key, String label) {
  final v = raw[key] as String?;
  if (v == null || v.isEmpty) return pw.SizedBox.shrink();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(
          text: '$label: ',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.TextSpan(text: v, style: const pw.TextStyle(fontSize: 9)),
      ]),
    ),
  );
}
