/// Modelli per il catalogo di incantesimi (SRD) e per le entry sulle schede.
///
/// Il backend espone:
///   - `SpellSummary` (lista paginata): id/name/level/school/ritual/concentration/classes
///   - `SpellDetail`  (dettaglio):       come summary + tutti i campi PHB
///
/// Sulle schede personaggio, le entry vengono restituite gia' espanse
/// (snapshot fields popolati dal catalogo quando spellId e' valorizzato).
library;

class SpellComponents {
  SpellComponents({
    this.verbal = false,
    this.somatic = false,
    this.material = false,
    this.materialDescription,
  });

  final bool    verbal;
  final bool    somatic;
  final bool    material;
  final String? materialDescription;

  factory SpellComponents.fromJson(Map<String, dynamic>? j) {
    if (j == null) return SpellComponents();
    return SpellComponents(
      verbal:              (j['verbal']   as bool?) ?? false,
      somatic:             (j['somatic']  as bool?) ?? false,
      material:            (j['material'] as bool?) ?? false,
      materialDescription: j['materialDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'verbal':                  verbal,
        'somatic':                 somatic,
        'material':                material,
        if (materialDescription != null) 'materialDescription': materialDescription,
      };

  /// Stringa compatta per UI: "V, S, M (a pinch of dust)". Se passato
  /// [materialOverride], lo usa al posto di materialDescription.
  String short({String? materialOverride}) {
    final parts = <String>[];
    if (verbal)   parts.add('V');
    if (somatic)  parts.add('S');
    if (material) parts.add('M');
    if (parts.isEmpty) return '—';
    final base = parts.join(', ');
    final mat = materialOverride ?? materialDescription;
    if (material && (mat?.isNotEmpty ?? false)) {
      return '$base ($mat)';
    }
    return base;
  }
}

/// Traduzione di un singolo incantesimo in una lingua specifica.
/// Tutti i campi sono opzionali: se null, fallback al canonical EN.
class SpellTranslation {
  SpellTranslation({
    this.name,
    this.description,
    this.atHigherLevels,
    this.school,
    this.castingTime,
    this.range,
    this.duration,
    this.materialDescription,
  });

  final String? name;
  final String? description;
  final String? atHigherLevels;
  final String? school;
  final String? castingTime;
  final String? range;
  final String? duration;
  final String? materialDescription;

  factory SpellTranslation.fromJson(Map<String, dynamic> j) => SpellTranslation(
        name:                j['name']                as String?,
        description:         j['description']         as String?,
        atHigherLevels:      j['atHigherLevels']      as String?,
        school:              j['school']              as String?,
        castingTime:         j['castingTime']         as String?,
        range:               j['range']               as String?,
        duration:            j['duration']            as String?,
        materialDescription: j['materialDescription'] as String?,
      );
}

/// Vista ridotta restituita da GET /spells.
class SpellSummary {
  SpellSummary({
    required this.id,
    required this.name,
    required this.level,
    required this.school,
    required this.ritual,
    required this.concentration,
    required this.classes,
    required this.source,
    this.translatedNames = const {},
  });

  final String              id;
  final String              name;
  final int                 level;       // 0 = trucchetto
  final String?             school;
  final bool                ritual;
  final bool                concentration;
  final List<String>        classes;
  final String?             source;
  /// Nomi tradotti per lingua (es. {'it': 'Palla di Fuoco'}).
  final Map<String, String> translatedNames;

  /// Restituisce il nome nella lingua [lang] se disponibile, altrimenti EN.
  String displayName(String lang) =>
      (lang != 'en' && (translatedNames[lang]?.isNotEmpty ?? false))
          ? translatedNames[lang]!
          : name;

  factory SpellSummary.fromJson(Map<String, dynamic> j) => SpellSummary(
        id:            j['id']     as String,
        name:          j['name']   as String,
        level:         (j['level'] as num?)?.toInt() ?? 0,
        school:        j['school'] as String?,
        ritual:        (j['ritual'] as bool?) ?? false,
        concentration: (j['concentration'] as bool?) ?? false,
        classes:       (j['classes'] as List<dynamic>?)?.cast<String>() ?? const [],
        source:        j['source'] as String?,
        translatedNames: ((j['translatedNames'] as Map?) ?? const {})
            .cast<String, String>(),
      );
}

/// Vista completa di un singolo spell del catalogo.
class SpellDetail {
  SpellDetail({
    required this.id,
    required this.name,
    required this.level,
    this.school,
    this.castingTime,
    this.range,
    SpellComponents? components,
    this.duration,
    this.concentration = false,
    this.ritual = false,
    this.classes = const [],
    this.description,
    this.atHigherLevels,
    this.source,
    this.translations = const {},
  }) : components = components ?? SpellComponents();

  final String                        id;
  final String                        name;
  final int                           level;
  final String?                       school;
  final String?                       castingTime;
  final String?                       range;
  final SpellComponents               components;
  final String?                       duration;
  final bool                          concentration;
  final bool                          ritual;
  final List<String>                  classes;
  final String?                       description;
  final String?                       atHigherLevels;
  final String?                       source;
  /// Mappa lingua → SpellTranslation. Vuota se solo EN.
  final Map<String, SpellTranslation> translations;

  /// Lingue disponibili (esclusa 'en' che è il canonical).
  List<String> get availableLanguages => translations.keys.toList();

  /// Vista nella lingua [lang], applicando i fallback campo-per-campo.
  /// Se [lang] == 'en' o assente, ritorna il canonical EN.
  SpellLocalizedView view(String lang) {
    final tr = (lang == 'en') ? null : translations[lang];
    String? coalesce(String? trVal, String? enVal) =>
        (trVal != null && trVal.isNotEmpty) ? trVal : enVal;
    return SpellLocalizedView(
      name:                coalesce(tr?.name, name)               ?? name,
      level:               level,
      school:              coalesce(tr?.school,         school),
      castingTime:         coalesce(tr?.castingTime,    castingTime),
      range:               coalesce(tr?.range,          range),
      duration:            coalesce(tr?.duration,       duration),
      description:         coalesce(tr?.description,    description),
      atHigherLevels:      coalesce(tr?.atHigherLevels, atHigherLevels),
      materialDescription: coalesce(tr?.materialDescription,
                                    components.materialDescription),
      components:          components,
      concentration:       concentration,
      ritual:              ritual,
      classes:             classes,
      source:              source,
    );
  }

  factory SpellDetail.fromJson(Map<String, dynamic> j) {
    final raw = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {};
    final translations = <String, SpellTranslation>{
      for (final e in raw.entries)
        e.key: SpellTranslation.fromJson((e.value as Map).cast<String, dynamic>()),
    };
    return SpellDetail(
      id:             j['id']     as String,
      name:           j['name']   as String,
      level:          (j['level'] as num?)?.toInt() ?? 0,
      school:         j['school'] as String?,
      castingTime:    j['castingTime'] as String?,
      range:          j['range'] as String?,
      components:     SpellComponents.fromJson(j['components'] as Map<String, dynamic>?),
      duration:       j['duration'] as String?,
      concentration:  (j['concentration'] as bool?) ?? false,
      ritual:         (j['ritual'] as bool?) ?? false,
      classes:        (j['classes'] as List<dynamic>?)?.cast<String>() ?? const [],
      description:    j['description'] as String?,
      atHigherLevels: j['atHigherLevels'] as String?,
      source:         j['source'] as String?,
      translations:   translations,
    );
  }
}

/// Snapshot localizzato pronto da renderizzare nel dialog dettagli.
class SpellLocalizedView {
  SpellLocalizedView({
    required this.name,
    required this.level,
    required this.components,
    required this.concentration,
    required this.ritual,
    required this.classes,
    this.school,
    this.castingTime,
    this.range,
    this.duration,
    this.description,
    this.atHigherLevels,
    this.materialDescription,
    this.source,
  });

  final String          name;
  final int             level;
  final String?         school;
  final String?         castingTime;
  final String?         range;
  final SpellComponents components;
  final String?         materialDescription;
  final String?         duration;
  final bool            concentration;
  final bool            ritual;
  final List<String>    classes;
  final String?         description;
  final String?         atHigherLevels;
  final String?         source;
}

/// Helper per il livello come stringa: "Trucchetto" o "Liv. N".
String formatSpellLevel(int level) {
  if (level <= 0) return 'Trucchetto';
  return 'Liv. $level';
}

/// Le 8 scuole PHB, in EN come restituite dal catalogo SRD.
const spellSchools = <String>[
  'Abjuration',
  'Conjuration',
  'Divination',
  'Enchantment',
  'Evocation',
  'Illusion',
  'Necromancy',
  'Transmutation',
];

/// Classi spellcaster PHB (SRD).
const spellcasterClasses = <String>[
  'Bard',
  'Cleric',
  'Druid',
  'Paladin',
  'Ranger',
  'Sorcerer',
  'Warlock',
  'Wizard',
];
