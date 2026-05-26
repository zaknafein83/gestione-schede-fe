import 'dart:collection';

import 'package:flutter/material.dart';

import '../logic/character_calc.dart';
import '../logic/character_catalog.dart';
import '../logic/spell_slot_tables.dart';
import '../models/character_models.dart';
import 'character_editor_models.dart';

/// Possiede tutto lo stato editabile di una scheda personaggio.
///
/// Separazione responsabilità rispetto al widget `_EditorBodyState`:
///   - questo controller: stato della scheda + mutazioni + `buildPayload()`
///   - widget container: TabController, Form, autosave timer + chiamate API,
///     interazioni con `ref` Riverpod, dialog/snackbar.
///
/// Doppia notifica:
///   - [notifyListeners] per qualsiasi mutazione (rebuild UI).
///   - [dirtyVersion] incrementato solo per mutazioni che devono triggerare
///     autosave. Es. [setSpellProgression] è in-session e NON tocca dirty.
class CharacterEditorController extends ChangeNotifier {
  CharacterEditorController({required this.initial}) {
    _init();
  }

  final CharacterDto initial;
  String get characterId => initial.id;

  /// Incrementato a ogni mutazione che richiede autosave. Il widget container
  /// ascolta questo notifier per programmare il debounce.
  final ValueNotifier<int> dirtyVersion = ValueNotifier<int>(0);

  // ----- Anagrafica -----
  late final TextEditingController name, race, subrace, className, subclass;
  late final TextEditingController level, background, alignment, experience;
  bool _inspiration = false;
  bool get inspiration => _inspiration;

  // ----- Stats -----
  late final TextEditingController str, dex, con, intel, wis, cha;

  // ----- Saving throws & skills -----
  late final Map<String, FlagRow> savingThrows;
  late final Map<String, FlagRow> skills;

  // ----- Condizioni PHB -----
  late final Set<String> conditions;

  // ----- Combat -----
  late final TextEditingController armorClass, initiative, speed;
  late final TextEditingController hpMax, hpCurrent, hpTemp;
  late final TextEditingController hitDiceTotal, hitDiceUsed;
  late final TextEditingController deathSavesSuccesses, deathSavesFailures;
  late final TextEditingController proficiencyBonus;

  // ----- Incantesimi -----
  late final TextEditingController spellcastingClass, spellSaveDc, spellAttackBonus;
  late final Map<String, SlotRow> spellSlots;
  late final List<SpellRow> spells;
  /// Progressione per la precompilazione PHB; solo in-session (non persistita).
  SpellProgression _spellProgression = SpellProgression.none;
  SpellProgression get spellProgression => _spellProgression;

  // ----- Equip -----
  late final TextEditingController coinCp, coinSp, coinEp, coinGp, coinPp;
  late final List<InventoryRow> inventory;

  // ----- Tratti -----
  late final TextEditingController personalityTraits, ideals, bonds, flaws;
  late final List<String> languages;
  late final TextEditingController armorProf, weaponProf, toolProf, featuresAndTraits;

  // ----- Note -----
  late final TextEditingController backstory, alliesAndOrganizations;
  late final TextEditingController symbol, physicalDescription, notes;

  // ==================================================================
  //                              INIT
  // ==================================================================

  void _init() {
    final raw = initial.raw;

    name        = _tc(initial.name);
    race        = _tc(initial.race);
    subrace     = _tc(_s(raw, 'subrace'));
    className   = _tc(initial.className);
    subclass    = _tc(_s(raw, 'subclass'));
    level       = _tc(initial.level?.toString());
    background  = _tc(_s(raw, 'background'));
    alignment   = _tc(_s(raw, 'alignment'));
    experience  = _tc(_n(raw, 'experience'));
    _inspiration = (raw['inspiration'] as bool?) ?? false;

    str   = _tc(_n(raw, 'str'));
    dex   = _tc(_n(raw, 'dex'));
    con   = _tc(_n(raw, 'con'));
    intel = _tc(_n(raw, 'intel'));
    wis   = _tc(_n(raw, 'wis'));
    cha   = _tc(_n(raw, 'cha'));

    final initSt = (raw['savingThrows'] as Map<String, dynamic>?) ?? const {};
    savingThrows = {
      for (final c in savingThrowsCatalog)
        c.key: FlagRow.fromMap(initSt[c.key] as Map<String, dynamic>?),
    };
    final initSk = (raw['skills'] as Map<String, dynamic>?) ?? const {};
    skills = {
      for (final c in skillsCatalog)
        c.key: FlagRow.fromMap(initSk[c.key] as Map<String, dynamic>?),
    };

    final initConditions = (raw['conditions'] as List<dynamic>?) ?? const [];
    conditions = LinkedHashSet<String>.from(initConditions.cast<String>());

    armorClass          = _tc(_n(raw, 'armorClass'));
    initiative          = _tc(_n(raw, 'initiative'));
    speed               = _tc(_n(raw, 'speed'));
    hpMax               = _tc(_n(raw, 'hpMax'));
    hpCurrent           = _tc(_n(raw, 'hpCurrent'));
    hpTemp              = _tc(_n(raw, 'hpTemp'));
    hitDiceTotal        = _tc(_n(raw, 'hitDiceTotal'));
    hitDiceUsed         = _tc(_n(raw, 'hitDiceUsed'));
    deathSavesSuccesses = _tc(_n(raw, 'deathSavesSuccesses'));
    deathSavesFailures  = _tc(_n(raw, 'deathSavesFailures'));
    proficiencyBonus    = _tc(_n(raw, 'proficiencyBonus'));

    spellcastingClass = _tc(_s(raw, 'spellcastingClass'));
    spellSaveDc       = _tc(_n(raw, 'spellSaveDc'));
    spellAttackBonus  = _tc(_n(raw, 'spellAttackBonus'));
    final initSlots = (raw['spellSlots'] as Map<String, dynamic>?) ?? const {};
    spellSlots = {
      for (var lvl = 1; lvl <= 9; lvl++)
        '$lvl': SlotRow.fromMap(initSlots['$lvl'] as Map<String, dynamic>?),
    };
    final initSpells = (raw['spells'] as List<dynamic>?) ?? const [];
    spells = initSpells
        .map((e) => SpellRow.fromMap(e as Map<String, dynamic>))
        .toList();

    final coins = (raw['coins'] as Map<String, dynamic>?) ?? const {};
    coinCp = _tc(_n(coins, 'cp'));
    coinSp = _tc(_n(coins, 'sp'));
    coinEp = _tc(_n(coins, 'ep'));
    coinGp = _tc(_n(coins, 'gp'));
    coinPp = _tc(_n(coins, 'pp'));
    final initInv = (raw['inventory'] as List<dynamic>?) ?? const [];
    inventory = initInv
        .map((e) => InventoryRow.fromMap(e as Map<String, dynamic>))
        .toList();

    personalityTraits = _tc(_s(raw, 'personalityTraits'));
    ideals            = _tc(_s(raw, 'ideals'));
    bonds             = _tc(_s(raw, 'bonds'));
    flaws             = _tc(_s(raw, 'flaws'));
    final initLangs = (raw['languages'] as List<dynamic>?) ?? const [];
    languages = initLangs.map((e) => e as String).toList();
    armorProf         = _tc(_s(raw, 'armorProficiencies'));
    weaponProf        = _tc(_s(raw, 'weaponProficiencies'));
    toolProf          = _tc(_s(raw, 'toolProficiencies'));
    featuresAndTraits = _tc(_s(raw, 'featuresAndTraits'));

    backstory              = _tc(_s(raw, 'backstory'));
    alliesAndOrganizations = _tc(_s(raw, 'alliesAndOrganizations'));
    symbol                 = _tc(_s(raw, 'symbol'));
    physicalDescription    = _tc(_s(raw, 'physicalDescription'));
    notes                  = _tc(_s(raw, 'notes'));

    for (final c in _allFixedControllers()) {
      c.addListener(_markDirty);
    }
    for (final r in spellSlots.values) {
      _attachAutosaveTo(r.controllers);
    }
    for (final r in spells) {
      _attachAutosaveTo(r.controllers);
    }
    for (final r in inventory) {
      _attachAutosaveTo(r.controllers);
    }
  }

  List<TextEditingController> _allFixedControllers() => [
        name, race, subrace, className, subclass, level,
        background, alignment, experience,
        str, dex, con, intel, wis, cha,
        armorClass, initiative, speed, hpMax, hpCurrent, hpTemp,
        hitDiceTotal, hitDiceUsed, deathSavesSuccesses, deathSavesFailures,
        proficiencyBonus,
        spellcastingClass, spellSaveDc, spellAttackBonus,
        coinCp, coinSp, coinEp, coinGp, coinPp,
        personalityTraits, ideals, bonds, flaws,
        armorProf, weaponProf, toolProf, featuresAndTraits,
        backstory, alliesAndOrganizations, symbol, physicalDescription, notes,
      ];

  void _attachAutosaveTo(List<TextEditingController> ctrls) {
    for (final c in ctrls) {
      c.addListener(_markDirty);
    }
  }

  void _detachAutosaveFrom(List<TextEditingController> ctrls) {
    for (final c in ctrls) {
      c.removeListener(_markDirty);
    }
  }

  void _markDirty() {
    dirtyVersion.value++;
  }

  static TextEditingController _tc(String? v) =>
      TextEditingController(text: v ?? '');
  static String? _s(Map<String, dynamic> m, String k) => m[k] as String?;
  static String? _n(Map<String, dynamic> m, String k) =>
      (m[k] as num?)?.toString();

  // ==================================================================
  //                              MUTATORS
  // ==================================================================

  void setInspiration(bool v) {
    _inspiration = v;
    _markDirty();
    notifyListeners();
  }

  /// Inserisce un SpellRow già costruito (dal catalogo o custom) registrandolo
  /// per l'autosave. Il fetch del SpellDetail dal catalogo è responsabilità
  /// del widget container che ha accesso a `ref` Riverpod.
  void addSpellRow(SpellRow row) {
    _attachAutosaveTo(row.controllers);
    spells.add(row);
    _markDirty();
    notifyListeners();
  }

  void replaceCustomSpellData(int i, Map<String, dynamic> data) {
    spells[i].applyCustomData(data);
    _markDirty();
    notifyListeners();
  }

  /// Converte una spell del catalogo in custom: azzera spellId, lasciando
  /// i campi snapshot come sono. Da qui l'utente può modificarli liberamente.
  void convertToCustom(int i) {
    final r = spells[i];
    r.spellId = null;
    if (r.classes != null) r.classes = List<String>.from(r.classes!);
    if (r.components != null) r.components = Map<String, dynamic>.from(r.components!);
    r.source = null;
    _markDirty();
    notifyListeners();
  }

  void removeSpell(int i) {
    _detachAutosaveFrom(spells[i].controllers);
    spells[i].dispose();
    spells.removeAt(i);
    _markDirty();
    notifyListeners();
  }

  void setSpellPrepared(int i, bool v) {
    spells[i].prepared = v;
    _markDirty();
    notifyListeners();
  }

  void setSpellAlwaysPrepared(int i, bool v) {
    spells[i].alwaysPrepared = v;
    _markDirty();
    notifyListeners();
  }

  void addInventory() {
    final r = InventoryRow.empty();
    _attachAutosaveTo(r.controllers);
    inventory.add(r);
    _markDirty();
    notifyListeners();
  }

  void removeInventory(int i) {
    _detachAutosaveFrom(inventory[i].controllers);
    inventory[i].dispose();
    inventory.removeAt(i);
    _markDirty();
    notifyListeners();
  }

  /// Triggera autosave dopo mutazione manuale della lista `languages`
  /// (i `_LanguagesChips` modificano la lista direttamente per mantenere
  /// l'API esistente).
  void redrawTraits() {
    _markDirty();
    notifyListeners();
  }

  /// SpellProgression NON triggera autosave (e' solo in-session).
  void setSpellProgression(SpellProgression v) {
    _spellProgression = v;
    notifyListeners();
  }

  // ---------------- HP & riposi ----------------

  int? get hpMaxValue     => tryParseInt(hpMax.text);
  int? get hpCurrentValue => tryParseInt(hpCurrent.text);
  int? get hpTempValue    => tryParseInt(hpTemp.text);

  void setHpCurrent(int v) {
    hpCurrent.text = v.toString();
  }

  void setHpTemp(int v) {
    hpTemp.text = v <= 0 ? '' : v.toString();
  }

  /// Applica cure: aumenta hpCurrent fino a hpMax (no overheal).
  void applyHealing(int amount) {
    if (amount <= 0) return;
    final cur = hpCurrentValue ?? 0;
    final max = hpMaxValue;
    final next = max == null ? cur + amount : (cur + amount).clamp(0, max);
    setHpCurrent(next);
    notifyListeners();
  }

  /// Applica danno: prima dai PF temporanei, l'eccesso da hpCurrent (min 0).
  void applyDamage(int amount) {
    if (amount <= 0) return;
    var remaining = amount;
    final temp = hpTempValue ?? 0;
    if (temp > 0) {
      if (temp >= remaining) {
        setHpTemp(temp - remaining);
        notifyListeners();
        return;
      } else {
        setHpTemp(0);
        remaining -= temp;
      }
    }
    final cur = hpCurrentValue ?? 0;
    final next = (cur - remaining).clamp(0, 1 << 31);
    setHpCurrent(next);
    notifyListeners();
  }

  void adjustHp(int delta) {
    if (delta > 0) {
      applyHealing(delta);
    } else if (delta < 0) {
      applyDamage(-delta);
    }
  }

  /// Riposo breve: reset death saves. Slot warlock pieni se la progressione
  /// corrente e' warlock.
  void shortRest() {
    deathSavesSuccesses.text = '';
    deathSavesFailures.text  = '';
    if (_spellProgression == SpellProgression.warlock) {
      for (final s in spellSlots.values) {
        final m = int.tryParse(s.max.text.trim());
        if (m != null) s.current.text = '$m';
      }
    }
    notifyListeners();
  }

  /// Riposo lungo: HP=max, hpTemp=0, slot pieni, dadi vita recuperati per
  /// meta' (arrotondato per difetto, min 1), death saves reset.
  void longRest() {
    final max = hpMaxValue;
    if (max != null) setHpCurrent(max);
    hpTemp.text = '';
    deathSavesSuccesses.text = '';
    deathSavesFailures.text  = '';
    for (final s in spellSlots.values) {
      final m = int.tryParse(s.max.text.trim());
      if (m != null) s.current.text = '$m';
    }
    final tot   = int.tryParse(hitDiceTotal.text.trim());
    final used  = int.tryParse(hitDiceUsed.text.trim()) ?? 0;
    if (tot != null && used > 0) {
      final recover = (tot ~/ 2).clamp(1, used);
      hitDiceUsed.text = '${used - recover}';
    }
    notifyListeners();
  }

  /// Riempie spellSlots.max secondo la tabella PHB per progressione e
  /// livello. Per i livelli senza slot in tabella, azzera. Per current:
  /// se vuoto, lo allinea a max; se gia' valorizzato, lo clampa a max.
  void applySpellSlotsFromTable() {
    final lvl = tryParseInt(level.text);
    final table = spellSlotsFor(_spellProgression, lvl);
    for (var i = 1; i <= 9; i++) {
      final key = '$i';
      final newMax = table[key];
      final row = spellSlots[key]!;
      if (newMax == null) {
        row.max.text     = '';
        row.current.text = '';
      } else {
        row.max.text = '$newMax';
        final curN = int.tryParse(row.current.text.trim());
        if (curN == null) {
          row.current.text = '$newMax';
        } else if (curN > newMax) {
          row.current.text = '$newMax';
        }
      }
    }
    notifyListeners();
  }

  // ---------------- Condizioni ----------------
  void toggleCondition(String key, bool on) {
    if (on) {
      conditions.add(key);
    } else {
      conditions.remove(key);
    }
    _markDirty();
    notifyListeners();
  }

  // ---------------- Saving throws / skills ----------------
  void setSavingThrowProficient(String key, bool v) {
    savingThrows[key]!.proficient = v;
    _markDirty();
    notifyListeners();
  }
  void setSavingThrowExpertise(String key, bool v) {
    savingThrows[key]!.expertise = v;
    _markDirty();
    notifyListeners();
  }
  void setSkillProficient(String key, bool v) {
    skills[key]!.proficient = v;
    _markDirty();
    notifyListeners();
  }
  void setSkillExpertise(String key, bool v) {
    skills[key]!.expertise = v;
    _markDirty();
    notifyListeners();
  }

  // ==================================================================
  //                              PAYLOAD
  // ==================================================================

  /// Costruisce il payload PATCH:
  ///  - stringhe (anche vuote) sempre incluse — backend trimma+null su vuote
  ///  - numerici vuoti OMESSI (backend conserva valore precedente)
  ///  - flag/booleani e collezioni sempre inclusi (sostituiscono interi)
  Map<String, dynamic> buildPayload() {
    final m = <String, dynamic>{};

    // Anagrafica
    m['name']        = name.text;
    m['race']        = race.text;
    m['subrace']     = subrace.text;
    m['className']   = className.text;
    m['subclass']    = subclass.text;
    _putInt(m, 'level',      level.text);
    m['background']  = background.text;
    m['alignment']   = alignment.text;
    _putInt(m, 'experience', experience.text);
    m['inspiration'] = _inspiration;

    // Stats
    _putInt(m, 'str',   str.text);
    _putInt(m, 'dex',   dex.text);
    _putInt(m, 'con',   con.text);
    _putInt(m, 'intel', intel.text);
    _putInt(m, 'wis',   wis.text);
    _putInt(m, 'cha',   cha.text);

    // TS & skills
    m['savingThrows'] = {
      for (final e in savingThrows.entries) e.key: e.value.toJson(),
    };
    m['skills'] = {
      for (final e in skills.entries) e.key: e.value.toJson(),
    };

    // Combat
    _putInt(m, 'armorClass',          armorClass.text);
    _putInt(m, 'initiative',          initiative.text);
    _putInt(m, 'speed',               speed.text);
    _putInt(m, 'hpMax',               hpMax.text);
    _putInt(m, 'hpCurrent',           hpCurrent.text);
    _putInt(m, 'hpTemp',              hpTemp.text);
    _putInt(m, 'hitDiceTotal',        hitDiceTotal.text);
    _putInt(m, 'hitDiceUsed',         hitDiceUsed.text);
    _putInt(m, 'deathSavesSuccesses', deathSavesSuccesses.text);
    _putInt(m, 'deathSavesFailures',  deathSavesFailures.text);
    _putInt(m, 'proficiencyBonus',    proficiencyBonus.text);

    // Incantesimi
    m['spellcastingClass'] = spellcastingClass.text;
    _putInt(m, 'spellSaveDc',      spellSaveDc.text);
    _putInt(m, 'spellAttackBonus', spellAttackBonus.text);
    m['spellSlots'] = {
      for (final e in spellSlots.entries)
        if (e.value.hasAny()) e.key: e.value.toJson(),
    };
    m['spells'] = spells
        .map((s) => s.toJson())
        .where((j) => j.isNotEmpty)
        .toList();

    // Equip
    m['coins'] = {
      if (coinCp.text.trim().isNotEmpty) 'cp': int.tryParse(coinCp.text.trim()),
      if (coinSp.text.trim().isNotEmpty) 'sp': int.tryParse(coinSp.text.trim()),
      if (coinEp.text.trim().isNotEmpty) 'ep': int.tryParse(coinEp.text.trim()),
      if (coinGp.text.trim().isNotEmpty) 'gp': int.tryParse(coinGp.text.trim()),
      if (coinPp.text.trim().isNotEmpty) 'pp': int.tryParse(coinPp.text.trim()),
    };
    m['inventory'] = inventory
        .map((i) => i.toJson())
        .where((j) => j.isNotEmpty)
        .toList();

    // Stato (condizioni)
    m['conditions'] = conditions.toList();

    // Tratti
    m['personalityTraits']   = personalityTraits.text;
    m['ideals']              = ideals.text;
    m['bonds']               = bonds.text;
    m['flaws']               = flaws.text;
    m['languages']           = List<String>.from(languages);
    m['armorProficiencies']  = armorProf.text;
    m['weaponProficiencies'] = weaponProf.text;
    m['toolProficiencies']   = toolProf.text;
    m['featuresAndTraits']   = featuresAndTraits.text;

    // Note
    m['backstory']              = backstory.text;
    m['alliesAndOrganizations'] = alliesAndOrganizations.text;
    m['symbol']                 = symbol.text;
    m['physicalDescription']    = physicalDescription.text;
    m['notes']                  = notes.text;

    return m;
  }

  static void _putInt(Map<String, dynamic> m, String key, String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    final n = int.tryParse(t);
    if (n != null) m[key] = n;
  }

  @override
  void dispose() {
    dirtyVersion.dispose();
    for (final c in _allFixedControllers()) {
      c.dispose();
    }
    for (final s in spellSlots.values) {
      s.dispose();
    }
    for (final s in spells) {
      s.dispose();
    }
    for (final i in inventory) {
      i.dispose();
    }
    super.dispose();
  }
}
