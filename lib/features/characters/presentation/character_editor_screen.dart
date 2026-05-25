import 'dart:async';
import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../../dice/presentation/dice_roller_dialog.dart';
import '../../share/presentation/share_dialog.dart';
import '../../spells/data/spells_api.dart';
import '../../spells/models/spell_models.dart';
import '../../spells/presentation/spell_detail_dialog.dart';
import '../../spells/presentation/spell_picker_dialog.dart';
import '../data/character_detail_providers.dart';
import '../data/characters_api.dart';
import '../data/characters_controller.dart';
import '../data/portrait_providers.dart';
import '../logic/character_calc.dart';
import '../logic/character_catalog.dart';
import '../logic/conditions_catalog.dart';
import '../logic/spell_slot_tables.dart';
import '../models/character_models.dart';
import 'character_portrait_widget.dart';
import 'custom_spell_dialog.dart';

/// Editor della scheda personaggio. Al MVP-1 nessun calcolo automatico:
/// l'utente edita tutti i campi a mano.
///
/// Tab: Anagrafica · Stats · Combat · Incantesimi · Equip · Tratti · Note.
/// Salvataggio esplicito via bottone "Salva" — invia tutto il form in PATCH.
class CharacterEditorScreen extends ConsumerWidget {
  const CharacterEditorScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(characterDetailProvider(id));

    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCharacterEditor),
        leading: smartBackButton(context, fallback: '/characters'),
        actions: [
          IconButton(
            tooltip: l10n.editorToolbarShare,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => showShareDialog(context, id),
          ),
          IconButton(
            tooltip: l10n.diceTitle,
            icon: const Icon(Icons.casino_outlined),
            onPressed: () => showDiceRoller(context, characterId: id),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is ApiError ? e.detail : e.toString()),
        ),
        data: (c) => _EditorBody(initial: c),
      ),
    );
  }
}

class _EditorBody extends ConsumerStatefulWidget {
  const _EditorBody({required this.initial});
  final CharacterDto initial;

  @override
  ConsumerState<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends ConsumerState<_EditorBody>
    with TickerProviderStateMixin {

  late final TabController _tab;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ----- Autosave -----
  Timer?    _autosaveTimer;
  bool      _autosaveDirty = false;
  DateTime? _lastSavedAt;
  String?   _autosaveError;
  static const _autosaveDebounce = Duration(milliseconds: 800);

  // ----- Anagrafica -----
  late final TextEditingController _name, _race, _subrace, _className, _subclass;
  late final TextEditingController _level, _background, _alignment, _experience;
  late bool _inspiration;

  // ----- Stats -----
  late final TextEditingController _str, _dex, _con, _intel, _wis, _cha;

  // ----- Saving throws & skills -----
  late final Map<String, _FlagRow> _savingThrows;
  late final Map<String, _FlagRow> _skills;

  // ----- Condizioni PHB -----
  late final Set<String> _conditions;

  // ----- Combat -----
  late final TextEditingController _armorClass, _initiative, _speed;
  late final TextEditingController _hpMax, _hpCurrent, _hpTemp;
  late final TextEditingController _hitDiceTotal, _hitDiceUsed;
  late final TextEditingController _deathSavesSuccesses, _deathSavesFailures;
  late final TextEditingController _proficiencyBonus;

  // ----- Incantesimi -----
  late final TextEditingController _spellcastingClass, _spellSaveDc, _spellAttackBonus;
  late final Map<String, _SlotRow> _spellSlots;
  late final List<_SpellRow> _spells;
  // Progressione per la precompilazione PHB; solo in-session (non persistita)
  SpellProgression _spellProgression = SpellProgression.none;

  // ----- Equip -----
  late final TextEditingController _coinCp, _coinSp, _coinEp, _coinGp, _coinPp;
  late final List<_InventoryRow> _inventory;

  // ----- Tratti -----
  late final TextEditingController _personalityTraits, _ideals, _bonds, _flaws;
  late final List<String> _languages;
  late final TextEditingController _armorProf, _weaponProf, _toolProf, _featuresAndTraits;

  // ----- Note -----
  late final TextEditingController _backstory, _alliesAndOrganizations;
  late final TextEditingController _symbol, _physicalDescription, _notes;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 8, vsync: this);

    final raw = widget.initial.raw;

    _name        = _tc(widget.initial.name);
    _race        = _tc(widget.initial.race);
    _subrace     = _tc(_s(raw, 'subrace'));
    _className   = _tc(widget.initial.className);
    _subclass    = _tc(_s(raw, 'subclass'));
    _level       = _tc(widget.initial.level?.toString());
    _background  = _tc(_s(raw, 'background'));
    _alignment   = _tc(_s(raw, 'alignment'));
    _experience  = _tc(_n(raw, 'experience'));
    _inspiration = (raw['inspiration'] as bool?) ?? false;

    _str   = _tc(_n(raw, 'str'));
    _dex   = _tc(_n(raw, 'dex'));
    _con   = _tc(_n(raw, 'con'));
    _intel = _tc(_n(raw, 'intel'));
    _wis   = _tc(_n(raw, 'wis'));
    _cha   = _tc(_n(raw, 'cha'));

    final initSt = (raw['savingThrows'] as Map<String, dynamic>?) ?? const {};
    _savingThrows = {
      for (final c in savingThrowsCatalog)
        c.key: _FlagRow.fromMap(initSt[c.key] as Map<String, dynamic>?),
    };
    final initSk = (raw['skills'] as Map<String, dynamic>?) ?? const {};
    _skills = {
      for (final c in skillsCatalog)
        c.key: _FlagRow.fromMap(initSk[c.key] as Map<String, dynamic>?),
    };

    final initConditions = (raw['conditions'] as List<dynamic>?) ?? const [];
    _conditions = LinkedHashSet<String>.from(initConditions.cast<String>());

    _armorClass          = _tc(_n(raw, 'armorClass'));
    _initiative          = _tc(_n(raw, 'initiative'));
    _speed               = _tc(_n(raw, 'speed'));
    _hpMax               = _tc(_n(raw, 'hpMax'));
    _hpCurrent           = _tc(_n(raw, 'hpCurrent'));
    _hpTemp              = _tc(_n(raw, 'hpTemp'));
    _hitDiceTotal        = _tc(_n(raw, 'hitDiceTotal'));
    _hitDiceUsed         = _tc(_n(raw, 'hitDiceUsed'));
    _deathSavesSuccesses = _tc(_n(raw, 'deathSavesSuccesses'));
    _deathSavesFailures  = _tc(_n(raw, 'deathSavesFailures'));
    _proficiencyBonus    = _tc(_n(raw, 'proficiencyBonus'));

    _spellcastingClass = _tc(_s(raw, 'spellcastingClass'));
    _spellSaveDc       = _tc(_n(raw, 'spellSaveDc'));
    _spellAttackBonus  = _tc(_n(raw, 'spellAttackBonus'));
    final initSlots = (raw['spellSlots'] as Map<String, dynamic>?) ?? const {};
    _spellSlots = {
      for (var lvl = 1; lvl <= 9; lvl++)
        '$lvl': _SlotRow.fromMap(initSlots['$lvl'] as Map<String, dynamic>?),
    };
    final initSpells = (raw['spells'] as List<dynamic>?) ?? const [];
    _spells = initSpells
        .map((e) => _SpellRow.fromMap(e as Map<String, dynamic>))
        .toList();

    final coins = (raw['coins'] as Map<String, dynamic>?) ?? const {};
    _coinCp = _tc(_n(coins, 'cp'));
    _coinSp = _tc(_n(coins, 'sp'));
    _coinEp = _tc(_n(coins, 'ep'));
    _coinGp = _tc(_n(coins, 'gp'));
    _coinPp = _tc(_n(coins, 'pp'));
    final initInv = (raw['inventory'] as List<dynamic>?) ?? const [];
    _inventory = initInv
        .map((e) => _InventoryRow.fromMap(e as Map<String, dynamic>))
        .toList();

    _personalityTraits = _tc(_s(raw, 'personalityTraits'));
    _ideals            = _tc(_s(raw, 'ideals'));
    _bonds             = _tc(_s(raw, 'bonds'));
    _flaws             = _tc(_s(raw, 'flaws'));
    final initLangs = (raw['languages'] as List<dynamic>?) ?? const [];
    _languages = initLangs.map((e) => e as String).toList();
    _armorProf         = _tc(_s(raw, 'armorProficiencies'));
    _weaponProf        = _tc(_s(raw, 'weaponProficiencies'));
    _toolProf          = _tc(_s(raw, 'toolProficiencies'));
    _featuresAndTraits = _tc(_s(raw, 'featuresAndTraits'));

    _backstory              = _tc(_s(raw, 'backstory'));
    _alliesAndOrganizations = _tc(_s(raw, 'alliesAndOrganizations'));
    _symbol                 = _tc(_s(raw, 'symbol'));
    _physicalDescription    = _tc(_s(raw, 'physicalDescription'));
    _notes                  = _tc(_s(raw, 'notes'));

    _attachAutosaveTo(_allFixedControllers());
    for (final r in _spellSlots.values) {
      _attachAutosaveTo(r.controllers);
    }
    for (final r in _spells) {
      _attachAutosaveTo(r.controllers);
    }
    for (final r in _inventory) {
      _attachAutosaveTo(r.controllers);
    }
  }

  List<TextEditingController> _allFixedControllers() => [
        _name, _race, _subrace, _className, _subclass, _level,
        _background, _alignment, _experience,
        _str, _dex, _con, _intel, _wis, _cha,
        _armorClass, _initiative, _speed, _hpMax, _hpCurrent, _hpTemp,
        _hitDiceTotal, _hitDiceUsed, _deathSavesSuccesses, _deathSavesFailures,
        _proficiencyBonus,
        _spellcastingClass, _spellSaveDc, _spellAttackBonus,
        _coinCp, _coinSp, _coinEp, _coinGp, _coinPp,
        _personalityTraits, _ideals, _bonds, _flaws,
        _armorProf, _weaponProf, _toolProf, _featuresAndTraits,
        _backstory, _alliesAndOrganizations, _symbol, _physicalDescription, _notes,
      ];

  void _attachAutosaveTo(List<TextEditingController> ctrls) {
    for (final c in ctrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  void _detachAutosaveFrom(List<TextEditingController> ctrls) {
    for (final c in ctrls) {
      c.removeListener(_scheduleAutosave);
    }
  }

  static TextEditingController _tc(String? v) =>
      TextEditingController(text: v ?? '');
  static String? _s(Map<String, dynamic> m, String k) => m[k] as String?;
  static String? _n(Map<String, dynamic> m, String k) =>
      (m[k] as num?)?.toString();

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _tab.dispose();
    for (final c in [
      _name, _race, _subrace, _className, _subclass, _level,
      _background, _alignment, _experience,
      _str, _dex, _con, _intel, _wis, _cha,
      _armorClass, _initiative, _speed, _hpMax, _hpCurrent, _hpTemp,
      _hitDiceTotal, _hitDiceUsed, _deathSavesSuccesses, _deathSavesFailures,
      _proficiencyBonus,
      _spellcastingClass, _spellSaveDc, _spellAttackBonus,
      _coinCp, _coinSp, _coinEp, _coinGp, _coinPp,
      _personalityTraits, _ideals, _bonds, _flaws,
      _armorProf, _weaponProf, _toolProf, _featuresAndTraits,
      _backstory, _alliesAndOrganizations, _symbol, _physicalDescription, _notes,
    ]) {
      c.dispose();
    }
    for (final s in _spellSlots.values) { s.dispose(); }
    for (final s in _spells)             { s.dispose(); }
    for (final i in _inventory)          { i.dispose(); }
    super.dispose();
  }

  /// Id della scheda — usato dai widget figli per passarlo al dice roller.
  String get characterId => widget.initial.id;

  void setInspiration(bool v) {
    setState(() => _inspiration = v);
    _scheduleAutosave();
  }

  // Mutazioni delle liste/mappe esposte ai widget figli, per evitare
  // di chiamare setState dall'esterno (warning invalid_use_of_protected_member).

  /// Aggiunge una spell dal catalogo (post-picker). Fa fetch del dettaglio
  /// completo dal backend per popolare tutti i campi snapshot localmente
  /// (l'editor lavora in-memory: senza fetch la card mostrerebbe solo i
  /// pochi campi del summary fino al prossimo reload).
  Future<void> addCatalogSpell(SpellSummary picked) async {
    SpellDetail? detail;
    try {
      final access = await ref.read(authStorageProvider).loadAccess();
      if (access != null) {
        detail = await ref.read(spellsApiProvider).get(access, picked.id);
      }
    } catch (_) {
      // fallback ai soli campi del summary
    }
    setState(() {
      final r = detail != null
          ? _SpellRow.fromCatalogDetail(detail)
          : _SpellRow.fromCatalog(picked);
      _attachAutosaveTo(r.controllers);
      _spells.add(r);
    });
    _scheduleAutosave();
  }

  /// Aggiunge una spell custom dai dati del dialog.
  void addCustomSpell(Map<String, dynamic> data) {
    setState(() {
      final r = _SpellRow.newCustom()..applyCustomData(data);
      _attachAutosaveTo(r.controllers);
      _spells.add(r);
    });
    _scheduleAutosave();
  }

  /// Aggiorna i campi di una spell custom esistente (i-esima).
  void replaceCustomSpellData(int i, Map<String, dynamic> data) {
    setState(() => _spells[i].applyCustomData(data));
    _scheduleAutosave();
  }

  /// Converte una spell del catalogo in custom: azzera spellId, lasciando
  /// i campi snapshot come sono. Da qui l'utente può modificarli liberamente.
  void convertToCustom(int i) {
    setState(() {
      final r = _spells[i];
      r.spellId = null;
      // copia di sicurezza dei riferimenti condivisi
      if (r.classes != null) r.classes = List<String>.from(r.classes!);
      if (r.components != null) r.components = Map<String, dynamic>.from(r.components!);
      // azzera source: era "SRD 5.1" ma ora è custom
      r.source = null;
    });
    _scheduleAutosave();
  }

  void removeSpell(int i) {
    setState(() {
      _detachAutosaveFrom(_spells[i].controllers);
      _spells[i].dispose();
      _spells.removeAt(i);
    });
    _scheduleAutosave();
  }

  void setSpellPrepared(int i, bool v) {
    setState(() => _spells[i].prepared = v);
    _scheduleAutosave();
  }

  void setSpellAlwaysPrepared(int i, bool v) {
    setState(() => _spells[i].alwaysPrepared = v);
    _scheduleAutosave();
  }

  void addInventory() {
    setState(() {
      final r = _InventoryRow.empty();
      _attachAutosaveTo(r.controllers);
      _inventory.add(r);
    });
    _scheduleAutosave();
  }

  void removeInventory(int i) {
    setState(() {
      _detachAutosaveFrom(_inventory[i].controllers);
      _inventory[i].dispose();
      _inventory.removeAt(i);
    });
    _scheduleAutosave();
  }

  void redrawTraits() {
    setState(() {});
    _scheduleAutosave();
  }

  /// Progressione: NON triggera autosave (e' solo in-session, non viene
  /// persistita lato backend).
  void setSpellProgression(SpellProgression v) =>
      setState(() => _spellProgression = v);

  // ---------------- HP & riposi ----------------

  /// Letture/scritture dei campi HP come int. Setter null = stringa vuota.
  int? get hpMax     => tryParseInt(_hpMax.text);
  int? get hpCurrent => tryParseInt(_hpCurrent.text);
  int? get hpTemp    => tryParseInt(_hpTemp.text);

  void _setHpCurrent(int v) =>
      _hpCurrent.text = v.toString();
  void _setHpTemp(int v) =>
      _hpTemp.text = v <= 0 ? '' : v.toString();

  /// Applica cure: aumenta hpCurrent fino a hpMax (no overheal).
  /// Se hpCurrent non valorizzato, parte da 0.
  void applyHealing(int amount) {
    if (amount <= 0) return;
    setState(() {
      final cur = hpCurrent ?? 0;
      final max = hpMax;
      final next = max == null ? cur + amount : (cur + amount).clamp(0, max);
      _setHpCurrent(next);
    });
  }

  /// Applica danno: prima dai PF temporanei, l'eccesso da hpCurrent (min 0).
  void applyDamage(int amount) {
    if (amount <= 0) return;
    setState(() {
      var remaining = amount;
      final temp = hpTemp ?? 0;
      if (temp > 0) {
        if (temp >= remaining) {
          _setHpTemp(temp - remaining);
          return;
        } else {
          _setHpTemp(0);
          remaining -= temp;
        }
      }
      final cur = hpCurrent ?? 0;
      final next = (cur - remaining).clamp(0, 1 << 31);
      _setHpCurrent(next);
    });
  }

  /// Aggiusta hpCurrent di delta (+1/-1 dai bottoni rapidi). Rispetta le
  /// stesse regole di applyDamage/applyHealing.
  void adjustHp(int delta) {
    if (delta > 0) {
      applyHealing(delta);
    } else if (delta < 0) {
      applyDamage(-delta);
    }
  }

  /// Riposo breve: reset death saves. Slot warlock pieni se la progressione
  /// corrente e' warlock (al MVP-3 base la progressione e' in-session).
  void shortRest() {
    setState(() {
      _deathSavesSuccesses.text = '';
      _deathSavesFailures.text  = '';
      if (_spellProgression == SpellProgression.warlock) {
        for (final s in _spellSlots.values) {
          final m = int.tryParse(s.max.text.trim());
          if (m != null) s.current.text = '$m';
        }
      }
    });
  }

  /// Riposo lungo: HP=max, hpTemp=0, slot pieni, dadi vita recuperati per
  /// meta' (arrotondato per difetto, min 1), death saves reset.
  void longRest() {
    setState(() {
      final max = hpMax;
      if (max != null) _setHpCurrent(max);
      _hpTemp.text = '';
      _deathSavesSuccesses.text = '';
      _deathSavesFailures.text  = '';
      for (final s in _spellSlots.values) {
        final m = int.tryParse(s.max.text.trim());
        if (m != null) s.current.text = '$m';
      }
      final tot   = int.tryParse(_hitDiceTotal.text.trim());
      final used  = int.tryParse(_hitDiceUsed.text.trim()) ?? 0;
      if (tot != null && used > 0) {
        final recover = (tot ~/ 2).clamp(1, used);
        _hitDiceUsed.text = '${used - recover}';
      }
    });
  }

  /// Riempie _spellSlots.max secondo la tabella PHB per progressione e
  /// livello. Per i livelli senza slot in tabella, azzera. Per current:
  /// se vuoto, lo allinea a max; se gia' valorizzato, lo clampa a max.
  void applySpellSlotsFromTable() {
    final lvl = tryParseInt(_level.text);
    final table = spellSlotsFor(_spellProgression, lvl);
    setState(() {
      for (var i = 1; i <= 9; i++) {
        final key = '$i';
        final newMax = table[key];
        final row = _spellSlots[key]!;
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
    });
  }

  // Condizioni PHB
  void toggleCondition(String key, bool on) {
    setState(() {
      if (on) {
        _conditions.add(key);
      } else {
        _conditions.remove(key);
      }
    });
    _scheduleAutosave();
  }

  // Saving throws / skills
  void setSavingThrowProficient(String key, bool v) {
    setState(() => _savingThrows[key]!.proficient = v);
    _scheduleAutosave();
  }
  void setSavingThrowExpertise(String key, bool v) {
    setState(() => _savingThrows[key]!.expertise = v);
    _scheduleAutosave();
  }
  void setSkillProficient(String key, bool v) {
    setState(() => _skills[key]!.proficient = v);
    _scheduleAutosave();
  }
  void setSkillExpertise(String key, bool v) {
    setState(() => _skills[key]!.expertise = v);
    _scheduleAutosave();
  }

  // -------------------------- UI ----------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PortraitHeader(
          characterId: widget.initial.id,
          onPick:      _pickAndUploadPortrait,
          onRemove:    _removePortrait,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _HpQuickControls(state: this, mode: _HpDisplayMode.compact),
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
                _AnagraficaTab(state: this),
                _StatsTab(state: this),
                _AbilitiesTab(state: this),
                _CombatTab(state: this),
                _SpellcastingTab(state: this),
                _EquipTab(state: this),
                _TraitsTab(state: this),
                _NotesTab(state: this),
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
    );
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
  void _scheduleAutosave() {
    _autosaveDirty = true;
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
      final payload = _buildPayload();
      await ref.read(charactersApiProvider).patch(access, widget.initial.id, payload);
      // NB: NON invalidiamo characterDetailProvider qui — l'utente sta
      // editando, non vogliamo che il rifetch sovrascriva i controllers.
      // La lista, invece, va aggiornata (nome/livello/portrait possono cambiare).
      await ref.read(charactersListProvider.notifier).refresh();
      _autosaveDirty = false;
      if (!mounted) return;
      setState(() => _lastSavedAt = DateTime.now());
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

  /// Costruisce il payload PATCH:
  ///  - stringhe (anche vuote) sono sempre incluse — il backend le tratta
  ///    come null dopo trim quando vuote
  ///  - numerici vuoti sono OMESSI (il backend conserva il valore precedente)
  ///  - flag/booleani e collezioni sono sempre inclusi (sostituiscono interi)
  Map<String, dynamic> _buildPayload() {
    final m = <String, dynamic>{};

    // Anagrafica
    m['name']        = _name.text;
    m['race']        = _race.text;
    m['subrace']     = _subrace.text;
    m['className']   = _className.text;
    m['subclass']    = _subclass.text;
    _putInt(m, 'level',      _level.text);
    m['background']  = _background.text;
    m['alignment']   = _alignment.text;
    _putInt(m, 'experience', _experience.text);
    m['inspiration'] = _inspiration;

    // Stats
    _putInt(m, 'str',   _str.text);
    _putInt(m, 'dex',   _dex.text);
    _putInt(m, 'con',   _con.text);
    _putInt(m, 'intel', _intel.text);
    _putInt(m, 'wis',   _wis.text);
    _putInt(m, 'cha',   _cha.text);

    // TS & skills
    m['savingThrows'] = {
      for (final e in _savingThrows.entries) e.key: e.value.toJson(),
    };
    m['skills'] = {
      for (final e in _skills.entries) e.key: e.value.toJson(),
    };

    // Combat
    _putInt(m, 'armorClass',          _armorClass.text);
    _putInt(m, 'initiative',          _initiative.text);
    _putInt(m, 'speed',               _speed.text);
    _putInt(m, 'hpMax',               _hpMax.text);
    _putInt(m, 'hpCurrent',           _hpCurrent.text);
    _putInt(m, 'hpTemp',              _hpTemp.text);
    _putInt(m, 'hitDiceTotal',        _hitDiceTotal.text);
    _putInt(m, 'hitDiceUsed',         _hitDiceUsed.text);
    _putInt(m, 'deathSavesSuccesses', _deathSavesSuccesses.text);
    _putInt(m, 'deathSavesFailures',  _deathSavesFailures.text);
    _putInt(m, 'proficiencyBonus',    _proficiencyBonus.text);

    // Incantesimi
    m['spellcastingClass'] = _spellcastingClass.text;
    _putInt(m, 'spellSaveDc',      _spellSaveDc.text);
    _putInt(m, 'spellAttackBonus', _spellAttackBonus.text);
    m['spellSlots'] = {
      for (final e in _spellSlots.entries)
        if (e.value.hasAny()) e.key: e.value.toJson(),
    };
    m['spells'] = _spells
        .map((s) => s.toJson())
        .where((j) => j.isNotEmpty)
        .toList();

    // Equip
    m['coins'] = {
      if (_coinCp.text.trim().isNotEmpty) 'cp': int.tryParse(_coinCp.text.trim()),
      if (_coinSp.text.trim().isNotEmpty) 'sp': int.tryParse(_coinSp.text.trim()),
      if (_coinEp.text.trim().isNotEmpty) 'ep': int.tryParse(_coinEp.text.trim()),
      if (_coinGp.text.trim().isNotEmpty) 'gp': int.tryParse(_coinGp.text.trim()),
      if (_coinPp.text.trim().isNotEmpty) 'pp': int.tryParse(_coinPp.text.trim()),
    };
    m['inventory'] = _inventory
        .map((i) => i.toJson())
        .where((j) => j.isNotEmpty)
        .toList();

    // Stato (condizioni)
    m['conditions'] = _conditions.toList();

    // Tratti
    m['personalityTraits']   = _personalityTraits.text;
    m['ideals']              = _ideals.text;
    m['bonds']               = _bonds.text;
    m['flaws']               = _flaws.text;
    m['languages']           = List<String>.from(_languages);
    m['armorProficiencies']  = _armorProf.text;
    m['weaponProficiencies'] = _weaponProf.text;
    m['toolProficiencies']   = _toolProf.text;
    m['featuresAndTraits']   = _featuresAndTraits.text;

    // Note
    m['backstory']              = _backstory.text;
    m['alliesAndOrganizations'] = _alliesAndOrganizations.text;
    m['symbol']                 = _symbol.text;
    m['physicalDescription']    = _physicalDescription.text;
    m['notes']                  = _notes.text;

    return m;
  }

  static void _putInt(Map<String, dynamic> m, String key, String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    final n = int.tryParse(t);
    if (n != null) m[key] = n;
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

// ===========================================================================
//                              HP quick controls
// ===========================================================================

enum _HpDisplayMode { compact, expanded }

/// Mostra HP correnti/max + temp HP + bottoni rapidi -1/+1 + bottone
/// "Modifica" che apre un dialog cura/danno. Reattivo ai controllers HP
/// del state.
class _HpQuickControls extends StatelessWidget {
  const _HpQuickControls({required this.state, required this.mode});

  final _EditorBodyState state;
  final _HpDisplayMode   mode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        state._hpCurrent, state._hpMax, state._hpTemp,
      ]),
      builder: (context, _) {
        final cur  = state.hpCurrent;
        final max  = state.hpMax;
        final temp = state.hpTemp ?? 0;

        final hpText = '${cur ?? "—"} / ${max ?? "—"}';

        final scheme = Theme.of(context).colorScheme;
        final isAtZero = cur != null && cur <= 0;
        final lowHp    = cur != null && max != null && cur > 0 && cur <= (max / 4);

        Color color = scheme.onSurface;
        if (isAtZero) {
          color = scheme.error;
        } else if (lowHp) {
          color = scheme.tertiary;
        }

        final hpStyle = (mode == _HpDisplayMode.compact
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(color: color, fontWeight: FontWeight.bold);

        final activeConditions = state._conditions
            .map((k) => findCondition(k))
            .whereType<ConditionEntry>()
            .toList();

        return Card(
          color: scheme.surfaceContainerHighest,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mode == _HpDisplayMode.compact ? 12 : 16,
              vertical:   mode == _HpDisplayMode.compact ? 6  : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: 20, color: scheme.error),
                    const SizedBox(width: 8),
                    Text(AppL10n.of(context).sheetHpLabel,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Text(hpText, style: hpStyle),
                    if (temp > 0) ...[
                      const SizedBox(width: 8),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text('+$temp temp'),
                        backgroundColor: scheme.tertiaryContainer,
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: '-1',
                      icon: const Icon(Icons.remove),
                      onPressed: () => state.adjustHp(-1),
                    ),
                    IconButton(
                      tooltip: '+1',
                      icon: const Icon(Icons.add),
                      onPressed: () => state.adjustHp(1),
                    ),
                    if (mode == _HpDisplayMode.expanded) ...[
                      const SizedBox(width: 4),
                      FilledButton.tonalIcon(
                        onPressed: () => _showHpDialog(context, state),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(AppL10n.of(context).actionEdit),
                      ),
                    ] else
                      IconButton(
                        tooltip: AppL10n.of(context).editorHpDialogTitle,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showHpDialog(context, state),
                      ),
                  ],
                ),
                if (activeConditions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final c in activeConditions)
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(Icons.warning_amber_rounded,
                              size: 14, color: scheme.error),
                          label: Text(labelForCondition(c.key, AppL10n.of(context)),
                              style: Theme.of(context).textTheme.bodySmall),
                          backgroundColor: scheme.errorContainer,
                          onPressed: () => _showConditionInfo(context, c),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showHpDialog(BuildContext context, _EditorBodyState state) {
  return showDialog<void>(
    context: context,
    builder: (_) => _HpDialog(state: state),
  );
}

class _HpDialog extends StatefulWidget {
  const _HpDialog({required this.state});
  final _EditorBodyState state;

  @override
  State<_HpDialog> createState() => _HpDialogState();
}

class _HpDialogState extends State<_HpDialog> {
  final _amount   = TextEditingController();
  final _tempCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempCtrl.text = widget.state._hpTemp.text;
  }

  @override
  void dispose() {
    _amount.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  int? get _value => int.tryParse(_amount.text.trim());

  void _heal() {
    final v = _value;
    if (v == null || v <= 0) return;
    widget.state.applyHealing(v);
    Navigator.pop(context);
  }

  void _damage() {
    final v = _value;
    if (v == null || v <= 0) return;
    widget.state.applyDamage(v);
    Navigator.pop(context);
  }

  void _applyTemp() {
    final v = int.tryParse(_tempCtrl.text.trim());
    // PHB: i PF temporanei non si stackano, prendi il massimo
    final cur = widget.state.hpTemp ?? 0;
    final next = (v == null || v < 0) ? 0 : (v > cur ? v : cur);
    widget.state._setHpTemp(next);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(l10n.editorHpDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.editorHpQuantityLabel,
                hintText: l10n.editorHpQuantityHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _heal,
                    icon: const Icon(Icons.healing_outlined),
                    label: Text(l10n.editorHpHeal),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _damage,
                    icon: const Icon(Icons.local_fire_department_outlined),
                    label: Text(l10n.editorHpDamage),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _tempCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.editorHpTempLabel,
                helperText: l10n.editorHpTempHelper,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _applyTemp,
                child: Text(l10n.editorHpTempApply),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}

// ===========================================================================
//                              Portrait header
// ===========================================================================

class _PortraitHeader extends ConsumerWidget {
  const _PortraitHeader({
    required this.characterId,
    required this.onPick,
    required this.onRemove,
  });

  final String       characterId;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPortrait =
        ref.watch(characterPortraitBytesProvider(characterId)).asData?.value != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CharacterPortraitWidget(id: characterId, size: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onPick,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(hasPortrait
                      ? AppL10n.of(context).editorPortraitChange
                      : AppL10n.of(context).editorPortraitUpload),
                ),
                if (hasPortrait)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(AppL10n.of(context).actionRemove),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//                                  Sub-rows
// ===========================================================================

/// Stato di una singola voce TS/skill — proficient/expertise + customValue
/// (preservato dal raw iniziale e mai modificato in UI al M2-A).
class _FlagRow {
  _FlagRow({this.proficient = false, this.expertise = false, this.customValue});

  factory _FlagRow.fromMap(Map<String, dynamic>? m) {
    if (m == null) return _FlagRow();
    return _FlagRow(
      proficient:  (m['proficient'] as bool?) ?? false,
      expertise:   (m['expertise']  as bool?) ?? false,
      customValue: (m['customValue'] as num?)?.toInt(),
    );
  }

  bool proficient;
  bool expertise;
  int? customValue;

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{
      'proficient': proficient,
      'expertise':  expertise,
    };
    if (customValue != null) j['customValue'] = customValue;
    return j;
  }
}

class _SlotRow {
  _SlotRow.fromMap(Map<String, dynamic>? m)
      : max = TextEditingController(text: (m?['max'] as num?)?.toString() ?? ''),
        current = TextEditingController(text: (m?['current'] as num?)?.toString() ?? '');

  final TextEditingController max;
  final TextEditingController current;

  List<TextEditingController> get controllers => [max, current];

  bool hasAny() => max.text.trim().isNotEmpty || current.text.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};
    final mx = int.tryParse(max.text.trim());
    final cu = int.tryParse(current.text.trim());
    if (mx != null) j['max']     = mx;
    if (cu != null) j['current'] = cu;
    return j;
  }

  void dispose() {
    max.dispose();
    current.dispose();
  }
}

/// Entry incantesimo nella lista della scheda. Supporta due modalità:
///
///   - **Catalogo** (`spellId != null`, es. "srd:fireball"): i campi
///     snapshot (name/level/school/...) sono valorizzati dal backend al
///     GET (expansion dal catalogo). In storage salviamo solo lo slug +
///     i campi per-scheda.
///   - **Custom** (`spellId == null`): tutti i campi sono editabili
///     localmente e salvati per intero.
///
/// I campi `prepared`, `alwaysPrepared`, `notes` sono sempre per-scheda.
class _SpellRow {
  _SpellRow._({
    this.spellId,
    this.prepared       = false,
    this.alwaysPrepared = false,
    String? notes,
    this.name,
    this.level,
    this.school,
    this.castingTime,
    this.range,
    this.components,
    this.duration,
    this.concentration  = false,
    this.ritual         = false,
    this.classes,
    this.description,
    this.atHigherLevels,
    this.source,
  }) : notes = TextEditingController(text: notes ?? '');

  factory _SpellRow.fromMap(Map<String, dynamic> m) => _SpellRow._(
        spellId:        m['spellId'] as String?,
        prepared:       (m['prepared']       as bool?) ?? false,
        alwaysPrepared: (m['alwaysPrepared'] as bool?) ?? false,
        notes:          m['notes']  as String?,
        name:           m['name']   as String?,
        level:          (m['level'] as num?)?.toInt(),
        school:         m['school'] as String?,
        castingTime:    m['castingTime'] as String?,
        range:          m['range']       as String?,
        components:     m['components'] is Map
            ? Map<String, dynamic>.from(m['components'] as Map)
            : null,
        duration:       m['duration'] as String?,
        concentration:  (m['concentration'] as bool?) ?? false,
        ritual:         (m['ritual']        as bool?) ?? false,
        classes:        (m['classes'] as List?)?.cast<String>().toList(),
        description:    m['description'] as String?,
        atHigherLevels: m['atHigherLevels'] as String?,
        source:         m['source'] as String?,
      );

  /// Crea una row da una entry del catalogo (post-picker, dati minimi).
  factory _SpellRow.fromCatalog(SpellSummary s) => _SpellRow._(
        spellId:       s.id,
        name:          s.name,
        level:         s.level,
        school:        s.school,
        ritual:        s.ritual,
        concentration: s.concentration,
        classes:       List<String>.from(s.classes),
        source:        s.source,
      );

  /// Crea una row da un dettaglio del catalogo completo.
  factory _SpellRow.fromCatalogDetail(SpellDetail d) => _SpellRow._(
        spellId:        d.id,
        name:           d.name,
        level:          d.level,
        school:         d.school,
        castingTime:    d.castingTime,
        range:          d.range,
        components:     d.components.toJson(),
        duration:       d.duration,
        concentration:  d.concentration,
        ritual:         d.ritual,
        classes:        List<String>.from(d.classes),
        description:    d.description,
        atHigherLevels: d.atHigherLevels,
        source:         d.source,
      );

  /// Crea una row vuota custom (homebrew).
  factory _SpellRow.newCustom() => _SpellRow._();

  String? spellId;
  bool    prepared;
  bool    alwaysPrepared;
  final TextEditingController notes;

  // Snapshot fields (read-only per SRD, editabili via dialog per custom)
  String?               name;
  int?                  level;
  String?               school;
  String?               castingTime;
  String?               range;
  Map<String, dynamic>? components;
  String?               duration;
  bool                  concentration;
  bool                  ritual;
  List<String>?         classes;
  String?               description;
  String?               atHigherLevels;
  String?               source;

  bool get isCatalog => spellId != null && spellId!.isNotEmpty;

  List<TextEditingController> get controllers => [notes];

  /// Applica i campi di una mappa "custom edit" sovrascrivendo i campi
  /// snapshot. Mantiene `spellId` (per supportare anche edit di SRD
  /// "personalizzati" → caller deve aver già azzerato spellId).
  void applyCustomData(Map<String, dynamic> m) {
    name           = m['name']        as String?;
    level          = (m['level']      as num?)?.toInt();
    school         = m['school']      as String?;
    castingTime    = m['castingTime'] as String?;
    range          = m['range']       as String?;
    components     = m['components'] is Map
        ? Map<String, dynamic>.from(m['components'] as Map)
        : null;
    duration       = m['duration']      as String?;
    concentration  = (m['concentration'] as bool?) ?? false;
    ritual         = (m['ritual']        as bool?) ?? false;
    classes        = (m['classes'] as List?)?.cast<String>().toList();
    description    = m['description'] as String?;
    atHigherLevels = m['atHigherLevels'] as String?;
  }

  /// Costruisce un map "piatto" dei campi per il dialog custom edit.
  Map<String, dynamic> toEditMap() => {
        if (name != null)           'name':        name,
        if (level != null)          'level':       level,
        if (school != null)         'school':      school,
        if (castingTime != null)    'castingTime': castingTime,
        if (range != null)          'range':       range,
        if (components != null)     'components':  components,
        if (duration != null)       'duration':    duration,
        'concentration':            concentration,
        'ritual':                   ritual,
        if (classes != null)        'classes':     classes,
        if (description != null)    'description': description,
        if (atHigherLevels != null) 'atHigherLevels': atHigherLevels,
      };

  /// Serializza per il PATCH al backend.
  ///   - se catalog: solo {spellId, prepared, alwaysPrepared, notes}
  ///   - se custom: tutti i campi non vuoti
  Map<String, dynamic> toJson() {
    if (isCatalog) {
      final j = <String, dynamic>{
        'spellId':        spellId,
        'prepared':       prepared,
        'alwaysPrepared': alwaysPrepared,
      };
      if (notes.text.trim().isNotEmpty) j['notes'] = notes.text.trim();
      return j;
    }
    final j = <String, dynamic>{
      'prepared':       prepared,
      'alwaysPrepared': alwaysPrepared,
      'concentration':  concentration,
      'ritual':         ritual,
    };
    if (notes.text.trim().isNotEmpty) j['notes'] = notes.text.trim();
    if ((name        ?? '').trim().isNotEmpty) j['name']        = name!.trim();
    if (level != null)                         j['level']       = level;
    if ((school      ?? '').trim().isNotEmpty) j['school']      = school!.trim();
    if ((castingTime ?? '').trim().isNotEmpty) j['castingTime'] = castingTime!.trim();
    if ((range       ?? '').trim().isNotEmpty) j['range']       = range!.trim();
    if (components != null)                    j['components']  = components;
    if ((duration    ?? '').trim().isNotEmpty) j['duration']    = duration!.trim();
    if (classes != null && classes!.isNotEmpty) j['classes']    = classes;
    if ((description    ?? '').trim().isNotEmpty) j['description']    = description!.trim();
    if ((atHigherLevels ?? '').trim().isNotEmpty) j['atHigherLevels'] = atHigherLevels!.trim();
    if ((source         ?? '').trim().isNotEmpty) j['source']         = source!.trim();
    return j;
  }

  /// Costruisce un [SpellDetail] dai campi attuali — usato per mostrare il
  /// dialog dettagli senza fetch dal backend (sia per SRD espanse che per custom).
  SpellDetail toDetail() => SpellDetail(
        id:             spellId ?? '',
        name:           name ?? '(senza nome)',
        level:          level ?? 0,
        school:         school,
        castingTime:    castingTime,
        range:          range,
        components:     SpellComponents.fromJson(components),
        duration:       duration,
        concentration:  concentration,
        ritual:         ritual,
        classes:        classes ?? const [],
        description:    description,
        atHigherLevels: atHigherLevels,
        source:         source,
      );

  void dispose() {
    notes.dispose();
  }
}

class _InventoryRow {
  _InventoryRow.fromMap(Map<String, dynamic> m)
      : name     = TextEditingController(text: (m['name']     as String?) ?? ''),
        qty      = TextEditingController(text: (m['qty']      as num?)?.toString() ?? ''),
        weightLb = TextEditingController(text: (m['weightLb'] as num?)?.toString() ?? ''),
        notes    = TextEditingController(text: (m['notes']    as String?) ?? '');

  _InventoryRow.empty()
      : name     = TextEditingController(),
        qty      = TextEditingController(),
        weightLb = TextEditingController(),
        notes    = TextEditingController();

  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController weightLb;
  final TextEditingController notes;

  List<TextEditingController> get controllers => [name, qty, weightLb, notes];

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};
    final n = name.text.trim();
    if (n.isNotEmpty) j['name'] = n;
    final q = int.tryParse(qty.text.trim());
    if (q != null) j['qty'] = q;
    final w = double.tryParse(weightLb.text.trim());
    if (w != null) j['weightLb'] = w;
    final nt = notes.text.trim();
    if (nt.isNotEmpty) j['notes'] = nt;
    return j;
  }

  void dispose() {
    name.dispose();
    qty.dispose();
    weightLb.dispose();
    notes.dispose();
  }
}

// ===========================================================================
//                                    Tabs
// ===========================================================================

class _AnagraficaTab extends StatelessWidget {
  const _AnagraficaTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row([
            _textField(state._name,      label: l10n.editorAnagraficaName),
            _textField(state._level,     label: l10n.editorAnagraficaLevel, kind: _Kind.intRanged, min: 1, max: 20),
          ]),
          _row([
            _textField(state._race,      label: l10n.editorAnagraficaRace),
            _textField(state._subrace,   label: l10n.editorAnagraficaSubrace),
          ]),
          _row([
            _textField(state._className, label: l10n.editorAnagraficaClass),
            _textField(state._subclass,  label: l10n.editorAnagraficaSubclass),
          ]),
          _row([
            _textField(state._background, label: l10n.sheetHeaderBackground),
            _textField(state._alignment,  label: l10n.sheetHeaderAlignment),
          ]),
          _row([
            _textField(state._experience, label: l10n.editorAnagraficaExperience, kind: _Kind.intMin0),
            const SizedBox.shrink(),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(l10n.editorAnagraficaInspiration),
            contentPadding: EdgeInsets.zero,
            value: state._inspiration,
            onChanged: state.setInspiration,
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.state});
  final _EditorBodyState state;

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
          _row([
            _AbilityField(controller: state._str,   label: l10n.sheetAbilityStr, characterId: state.characterId),
            _AbilityField(controller: state._dex,   label: l10n.sheetAbilityDex, characterId: state.characterId),
          ]),
          _row([
            _AbilityField(controller: state._con,   label: l10n.sheetAbilityCon, characterId: state.characterId),
            _AbilityField(controller: state._intel, label: l10n.sheetAbilityInt, characterId: state.characterId),
          ]),
          _row([
            _AbilityField(controller: state._wis,   label: l10n.sheetAbilityWis, characterId: state.characterId),
            _AbilityField(controller: state._cha,   label: l10n.sheetAbilityCha, characterId: state.characterId),
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
              child: _textField(
                controller,
                label: '$label  ($modText)',
                kind: _Kind.intRanged,
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
  final _Kind                        kind;
  final List<TextEditingController>  listenables;
  final String? Function()           hint;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) => _textField(
        controller,
        label: label,
        kind: kind,
        helperText: hint(),
      ),
    );
  }
}

class _AbilitiesTab extends StatelessWidget {
  const _AbilitiesTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    // Modificatori correnti delle ability (reattivi via Listenable.merge)
    final listenables = [
      state._str, state._dex, state._con, state._intel, state._wis, state._cha,
      state._level, state._proficiencyBonus,
    ];
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        // Modifier per ability key
        final mods = <String, int?>{
          'str': abilityMod(tryParseInt(state._str.text)),
          'dex': abilityMod(tryParseInt(state._dex.text)),
          'con': abilityMod(tryParseInt(state._con.text)),
          'int': abilityMod(tryParseInt(state._intel.text)),
          'wis': abilityMod(tryParseInt(state._wis.text)),
          'cha': abilityMod(tryParseInt(state._cha.text)),
        };
        // Bonus competenza: override manuale se valorizzato, altrimenti calcolato dal livello
        final overrideProf = tryParseInt(state._proficiencyBonus.text);
        final autoProf     = profBonusForLevel(tryParseInt(state._level.text));
        final profBonus    = overrideProf ?? autoProf;

        final l10n = AppL10n.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.sheetSavingThrowsLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  _ProfBonusChip(profBonus: profBonus, fromOverride: overrideProf != null),
                ],
              ),
              const SizedBox(height: 8),
              const _AbilitiesHeader(),
              for (final e in savingThrowsCatalog)
                _FlagRowTile(
                  catalog:    e,
                  row:        state._savingThrows[e.key]!,
                  abilityMod: mods[e.abilityKey],
                  profBonus:  profBonus,
                  characterId: state.characterId,
                  onProficientChanged: (v) => state.setSavingThrowProficient(e.key, v),
                  onExpertiseChanged:  (v) => state.setSavingThrowExpertise(e.key, v),
                  isSkill: false,
                ),
              const SizedBox(height: 24),
              Text(l10n.sheetSkillsLabel,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _AbilitiesHeader(),
              for (final e in skillsCatalog)
                _FlagRowTile(
                  catalog:    e,
                  row:        state._skills[e.key]!,
                  abilityMod: mods[e.abilityKey],
                  profBonus:  profBonus,
                  characterId: state.characterId,
                  onProficientChanged: (v) => state.setSkillProficient(e.key, v),
                  onExpertiseChanged:  (v) => state.setSkillExpertise(e.key, v),
                  isSkill: true,
                ),
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

/// Header colonne per le sezioni TS e Skill: allinea "Competenza" e
/// "Maestria" sopra i due checkbox e "Totale" sopra il valore finale.
class _AbilitiesHeader extends StatelessWidget {
  const _AbilitiesHeader();

  @override
  Widget build(BuildContext context) {
    final l10n  = AppL10n.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: Text(l10n.editorColComp,   style: style))),
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
  final _FlagRow      row;
  final int?          abilityMod;
  final int?          profBonus;
  final String        characterId;
  final ValueChanged<bool> onProficientChanged;
  final ValueChanged<bool> onExpertiseChanged;
  /// true se il tile fa parte della sezione skill (label via [labelForSkill]),
  /// false se TS (label via [labelForSavingThrow]).
  final bool          isSkill;

  /// Valore finale: customValue override → altrimenti
  /// mod + (proficient ? prof : 0) + (expertise ? prof : 0).
  /// Null se ability/profBonus non disponibili e nessun override.
  int? _finalValue() {
    if (row.customValue != null) return row.customValue;
    if (abilityMod == null) return null;
    var v = abilityMod!;
    if (row.proficient && profBonus != null) {
      v += profBonus!;
      if (row.expertise) v += profBonus!;
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
            // Proficient
            Checkbox(
              value: row.proficient,
              onChanged: (b) => onProficientChanged(b ?? false),
            ),
            // Expertise (disabilitato se non proficient)
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

class _CombatTab extends StatelessWidget {
  const _CombatTab({required this.state});
  final _EditorBodyState state;

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
          _row([
            _DerivedIntField(
              controller: state._armorClass,
              label: l10n.editorCombatArmorClassLabel,
              kind: _Kind.intMin0,
              listenables: [state._dex],
              hint: () {
                final m = abilityMod(tryParseInt(state._dex.text));
                return m == null ? null : l10n.editorCombatHintAcAuto(10 + m, dexShort);
              },
            ),
            _DerivedIntField(
              controller: state._initiative,
              label: l10n.sheetCombatInitiative,
              kind: _Kind.intAny,
              listenables: [state._dex],
              hint: () {
                final m = abilityMod(tryParseInt(state._dex.text));
                return m == null ? null : l10n.editorCombatHintInitAuto(formatModifier(m), dexShort);
              },
            ),
          ]),
          _row([
            _textField(state._speed, label: l10n.editorCombatSpeedLabel, kind: _Kind.intMin0),
            _DerivedIntField(
              controller: state._proficiencyBonus,
              label: l10n.editorCombatProfBonusLabel,
              kind: _Kind.intMin0,
              listenables: [state._level],
              hint: () {
                final p = profBonusForLevel(tryParseInt(state._level.text));
                return p == null ? null : l10n.editorCombatHintProfAuto(formatModifier(p));
              },
            ),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatHpSectionTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _HpQuickControls(state: state, mode: _HpDisplayMode.expanded),
          const SizedBox(height: 12),
          _row([
            _textField(state._hpMax,     label: l10n.editorCombatHpMaxLabel,     kind: _Kind.intMin0),
            _textField(state._hpCurrent, label: l10n.editorCombatHpCurrentLabel, kind: _Kind.intAny),
          ]),
          _row([
            _textField(state._hpTemp,    label: l10n.editorHpTempLabel, kind: _Kind.intMin0),
            const SizedBox.shrink(),
          ]),
          const SizedBox(height: 24),
          Text(l10n.sheetCombatHitDice, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _row([
            _textField(state._hitDiceTotal, label: l10n.editorCombatHitDiceTotalLabel, kind: _Kind.intMin0),
            _textField(state._hitDiceUsed,  label: l10n.editorCombatHitDiceUsedLabel,  kind: _Kind.intMin0),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatDeathSavesSectionTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _row([
            _textField(state._deathSavesSuccesses, label: l10n.editorCombatDeathSavesSuccLabel, kind: _Kind.intRanged, min: 0, max: 3),
            _textField(state._deathSavesFailures,  label: l10n.editorCombatDeathSavesFailLabel, kind: _Kind.intRanged, min: 0, max: 3),
          ]),
          const SizedBox(height: 24),
          Text(l10n.editorCombatConditionsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorCombatConditionsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _ConditionsSection(state: state),
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
                  onPressed: () => _confirmRest(context, state, isLong: false),
                  icon: const Icon(Icons.local_cafe_outlined),
                  label: Text(l10n.editorRestShort),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _confirmRest(context, state, isLong: true),
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

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in conditionsCatalog)
          _ConditionChip(
            entry: c,
            active: state._conditions.contains(c.key),
            onToggle: (on) => state.toggleCondition(c.key, on),
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
      onDeleted: () => _showConditionInfo(context, entry),
    );
  }
}

Future<void> _showConditionInfo(BuildContext context, ConditionEntry e) {
  final l10n = AppL10n.of(context);
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          Text(labelForCondition(e.key, l10n)),
        ],
      ),
      content: Text(descriptionForCondition(e.key, l10n)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    ),
  );
}

Future<void> _confirmRest(
  BuildContext context,
  _EditorBodyState state, {
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
    state.longRest();
  } else {
    state.shortRest();
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snack)),
    );
  }
}

class _SpellcastingTab extends StatelessWidget {
  const _SpellcastingTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.sheetSectionSpells, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _row([
            _textField(state._spellcastingClass, label: l10n.editorSpellsCasterClassLabel),
            const SizedBox.shrink(),
          ]),
          _row([
            _textField(state._spellSaveDc,      label: l10n.editorSpellsSaveDcLabel, kind: _Kind.intMin0),
            _textField(state._spellAttackBonus, label: l10n.editorSpellsAttackLabel, kind: _Kind.intAny),
          ]),
          const SizedBox(height: 24),
          Text(l10n.sheetSpellsSlotsByLevel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorSpellsSlotsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _SpellSlotsPrefiller(state: state),
          const SizedBox(height: 12),
          for (final lvl in const ['1','2','3','4','5','6','7','8','9'])
            _SlotEditor(lvl: lvl, row: state._spellSlots[lvl]!),
          const SizedBox(height: 24),
          Text(l10n.editorSpellsListTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.editorSpellsListHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < state._spells.length; i++)
            _SpellCard(
              row:                     state._spells[i],
              onRemove:                () => state.removeSpell(i),
              onPreparedChanged:       (v) => state.setSpellPrepared(i, v),
              onAlwaysPreparedChanged: (v) => state.setSpellAlwaysPrepared(i, v),
              onShowDetail:            () => _showSpellDetail(context, state._spells[i]),
              onEditCustom:            () => _editCustomSpell(context, state, i),
              onConvertToCustom:       () => _confirmConvertToCustom(context, state, i),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _pickAndAddCatalogSpell(context, state),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.editorSpellsAddFromCatalog),
              ),
              OutlinedButton.icon(
                onPressed: () => _addCustomSpell(context, state),
                icon: const Icon(Icons.add),
                label: Text(l10n.editorSpellsCustomSpell),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddCatalogSpell(BuildContext context, _EditorBodyState state) async {
    final initialClass = state._spellcastingClass.text.trim().isEmpty
        ? null
        : state._spellcastingClass.text.trim();
    final picked = await showSpellPicker(context, initialClass: initialClass);
    if (picked != null) {
      state.addCatalogSpell(picked);
    }
  }

  Future<void> _addCustomSpell(BuildContext context, _EditorBodyState state) async {
    final data = await showCustomSpellDialog(context);
    if (data != null && data.isNotEmpty) {
      state.addCustomSpell(data);
    }
  }

  Future<void> _editCustomSpell(BuildContext context, _EditorBodyState state, int i) async {
    final data = await showCustomSpellDialog(context, initial: state._spells[i].toEditMap());
    if (data != null) {
      state.replaceCustomSpellData(i, data);
    }
  }

  Future<void> _confirmConvertToCustom(BuildContext context, _EditorBodyState state, int i) async {
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
    if (ok == true) state.convertToCustom(i);
  }

  void _showSpellDetail(BuildContext context, _SpellRow row) {
    // Spell del catalogo: fetcha SEMPRE dal backend per avere le traduzioni
    // (le translations non sono salvate nel _SpellRow, vivono nel catalogo).
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
  const _SpellSlotsPrefiller({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n      = AppL10n.of(context);
    final lvl       = tryParseInt(state._level.text);
    final canApply  = state._spellProgression != SpellProgression.none && lvl != null;
    final preview   = canApply
        ? spellSlotsFor(state._spellProgression, lvl)
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
                initialValue: state._spellProgression,
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
                  if (v != null) state.setSpellProgression(v);
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
            ] else if (state._spellProgression != SpellProgression.none) ...[
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
      state.applySpellSlotsFromTable();
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
  final _SlotRow row;

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
            child: _textField(row.max, label: l10n.editorSpellsSlotMax, kind: _Kind.intMin0),
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
  final _SlotRow row;

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
  final _SpellRow row;
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
              _textField(row.notes, label: l10n.editorSpellsNotesLabel, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SpellAction { detail, edit, customize, delete }

class _EquipTab extends StatelessWidget {
  const _EquipTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editorEquipCoinsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _textField(state._coinCp, label: 'CP', kind: _Kind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: _textField(state._coinSp, label: 'SP', kind: _Kind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: _textField(state._coinEp, label: 'EP', kind: _Kind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: _textField(state._coinGp, label: 'GP', kind: _Kind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: _textField(state._coinPp, label: 'PP', kind: _Kind.intMin0)),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.sheetEquipmentInventory, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var i = 0; i < state._inventory.length; i++)
            _InventoryCard(
              row:      state._inventory[i],
              onRemove: () => state.removeInventory(i),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: state.addInventory,
            icon: const Icon(Icons.add),
            label: Text(l10n.editorEquipAddItem),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.row, required this.onRemove});
  final _InventoryRow row;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _row([
              _textField(row.name,     label: l10n.editorEquipItemName),
              _textField(row.qty,      label: l10n.editorEquipItemQty, kind: _Kind.intMin0),
            ]),
            _row([
              _textField(row.weightLb, label: l10n.editorEquipItemWeight, kind: _Kind.decimalMin0),
              const SizedBox.shrink(),
            ]),
            _textField(row.notes, label: l10n.editorEquipItemNotes, maxLines: 2),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionRemove),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitsTab extends StatelessWidget {
  const _TraitsTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textField(state._personalityTraits, label: l10n.sheetTraitsPersonality, maxLines: 3),
          const SizedBox(height: 12),
          _textField(state._ideals, label: l10n.sheetTraitsIdeals, maxLines: 3),
          const SizedBox(height: 12),
          _textField(state._bonds,  label: l10n.sheetTraitsBonds,  maxLines: 3),
          const SizedBox(height: 12),
          _textField(state._flaws,  label: l10n.sheetTraitsFlaws,  maxLines: 3),
          const SizedBox(height: 24),
          Text(l10n.sheetTraitsLanguages, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _LanguagesChips(
            languages: state._languages,
            onChanged: state.redrawTraits,
          ),
          const SizedBox(height: 24),
          Text(l10n.editorTraitsProficienciesTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _textField(state._armorProf,  label: l10n.sheetTraitsArmor),
          const SizedBox(height: 12),
          _textField(state._weaponProf, label: l10n.sheetTraitsWeapons),
          const SizedBox(height: 12),
          _textField(state._toolProf,   label: l10n.sheetTraitsTools),
          const SizedBox(height: 24),
          Text(l10n.sheetTraitsFeatures, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _textField(state._featuresAndTraits, label: l10n.editorTraitsFeaturesFieldLabel, maxLines: 8),
        ],
      ),
    );
  }
}

class _LanguagesChips extends StatefulWidget {
  const _LanguagesChips({required this.languages, required this.onChanged});
  final List<String> languages;
  final VoidCallback onChanged;

  @override
  State<_LanguagesChips> createState() => _LanguagesChipsState();
}

class _LanguagesChipsState extends State<_LanguagesChips> {
  final _newCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (widget.languages.any((e) => e.toLowerCase() == v.toLowerCase())) {
      _newCtrl.clear();
      return;
    }
    setState(() => widget.languages.add(v));
    widget.onChanged();
    _newCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.languages.length; i++)
              InputChip(
                label: Text(widget.languages[i]),
                onDeleted: () {
                  setState(() => widget.languages.removeAt(i));
                  widget.onChanged();
                },
              ),
            if (widget.languages.isEmpty)
              Text(l10n.editorTraitsLanguagesNone,
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newCtrl,
                decoration: InputDecoration(
                  labelText: l10n.editorTraitsAddLanguageLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: _add,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _add(_newCtrl.text),
              icon: const Icon(Icons.add),
              label: Text(l10n.actionAdd),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.state});
  final _EditorBodyState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textField(state._backstory,              label: l10n.editorNotesBackstoryLabel, maxLines: 8),
          const SizedBox(height: 12),
          _textField(state._alliesAndOrganizations, label: l10n.sheetNotesAllies,          maxLines: 5),
          const SizedBox(height: 12),
          _textField(state._symbol,                 label: l10n.sheetNotesSymbol),
          const SizedBox(height: 12),
          _textField(state._physicalDescription,    label: l10n.sheetNotesPhysical,        maxLines: 5),
          const SizedBox(height: 12),
          _textField(state._notes,                  label: l10n.editorNotesNotesLabel,     maxLines: 8),
        ],
      ),
    );
  }
}

// ===========================================================================
//                              Form field helpers
// ===========================================================================

enum _Kind { text, intAny, intMin0, intRanged, decimalMin0 }

Widget _textField(
  TextEditingController c, {
  required String label,
  _Kind kind = _Kind.text,
  int? min,
  int? max,
  int maxLines = 1,
  String? helperText,
}) {
  final isInt     = kind == _Kind.intAny || kind == _Kind.intMin0 || kind == _Kind.intRanged;
  final isDecimal = kind == _Kind.decimalMin0;
  return Builder(builder: (ctx) {
    final l10n = AppL10n.of(ctx);
    return TextFormField(
      controller: c,
      keyboardType: isInt
          ? TextInputType.numberWithOptions(decimal: false, signed: kind == _Kind.intAny)
          : isDecimal
              ? const TextInputType.numberWithOptions(decimal: true, signed: false)
              : TextInputType.multiline,
      inputFormatters: isInt
          ? [kind == _Kind.intAny
                ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                : FilteringTextInputFormatter.digitsOnly]
          : isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : null,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 2 : 1,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        helperText: helperText,
      ),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return null;
        if (isInt) {
          final n = int.tryParse(t);
          if (n == null) return l10n.editorValidatorEnterNumber;
          if (kind == _Kind.intMin0 && n < 0) return l10n.editorValidatorMinZero;
          if (kind == _Kind.intRanged) {
            if (min != null && n < min) return l10n.editorValidatorMinN(min);
            if (max != null && n > max) return l10n.editorValidatorMaxN(max);
          }
        } else if (isDecimal) {
          final d = double.tryParse(t);
          if (d == null) return l10n.editorValidatorEnterNumber;
          if (d < 0)     return l10n.editorValidatorMinZero;
        }
        return null;
      },
    );
  });
}

Widget _row(List<Widget> children) {
  return LayoutBuilder(builder: (context, c) {
    if (c.maxWidth < 500) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in children)
            if (w is! SizedBox)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: w,
              ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  });
}
