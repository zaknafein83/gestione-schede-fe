import 'package:flutter/material.dart';

import '../../spells/models/spell_models.dart';

/// Stato per-skill / per-saving-throw: proficient + expertise + valore custom.
/// Custom value (al MVP solo nel dato, non in UI) consente di forzare il
/// modificatore senza affidarsi al calcolo.
class FlagRow {
  FlagRow({this.proficient = false, this.expertise = false, this.customValue});

  factory FlagRow.fromMap(Map<String, dynamic>? m) {
    if (m == null) return FlagRow();
    return FlagRow(
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

/// Slot incantesimo per un dato livello: max + correnti disponibili.
class SlotRow {
  SlotRow.fromMap(Map<String, dynamic>? m)
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
class SpellRow {
  SpellRow._({
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

  factory SpellRow.fromMap(Map<String, dynamic> m) => SpellRow._(
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
  factory SpellRow.fromCatalog(SpellSummary s) => SpellRow._(
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
  factory SpellRow.fromCatalogDetail(SpellDetail d) => SpellRow._(
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
  factory SpellRow.newCustom() => SpellRow._();

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

/// Item dell'inventario: nome + quantità + peso (lb) + note.
class InventoryRow {
  InventoryRow.fromMap(Map<String, dynamic> m)
      : name     = TextEditingController(text: (m['name']     as String?) ?? ''),
        qty      = TextEditingController(text: (m['qty']      as num?)?.toString() ?? ''),
        weightLb = TextEditingController(text: (m['weightLb'] as num?)?.toString() ?? ''),
        notes    = TextEditingController(text: (m['notes']    as String?) ?? '');

  InventoryRow.empty()
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
