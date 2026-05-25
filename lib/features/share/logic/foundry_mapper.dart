/// Mapper bidirezionale tra il nostro JSON di scheda e il formato attore
/// di FoundryVTT (sistema dnd5e).
///
/// Allineato al **dnd5e v5+** (Foundry VTT v12/v13). Differenze rispetto al
/// vecchio formato v3:
///   - `hp.max`, `ac.flat`, `details.level`, `spells.spellN.max` possono
///     essere null perche' calcolati dal sistema; vengono ricostruiti dai
///     dati disponibili (HP corrente, livelli di classe sugli Item, ecc.).
///   - `details.race / background / originalClass` sono **id di Item**, non
///     nomi. Il nome leggibile va letto dal corrispondente Item in
///     `items[]` (type = race/background/class/subclass).
///   - Spell components vivono in `system.properties[]` come array di
///     stringhe (`vocal`, `somatic`, `material`, `ritual`, `concentration`).
///   - Spell preparation: `system.prepared` (int 0/1/2) + `system.method`
///     (`spell`/`atwill`/`innate`/`ritual`/`pact`).
///   - Spell school usa codici 3-lettere `trs` (transmutation), non `tra`.
///   - Weight items: `weight: {value, units}` con `units` `lb` o `kg`.
///   - Lingue/proficiencies: liste built-in (`value[]`) + `custom` (string
///     separata da `;` o `,`).
///
/// Best-effort. Statistiche complete di armi (damage roll, range, ecc.) NON
/// vengono ricostruite nel nostro formato — gli oggetti diventano voci di
/// inventario semplici. Active Effects, advancement, properties di feat
/// non sono mappati. Il ritratto/avatar non viene incluso nell'export
/// (gestito separatamente via GridFS).
library;

/// Mappa skill our-key → Foundry-key (3 lettere).
const _skillToFoundry = {
  'acrobatics':     'acr',
  'animalHandling': 'ani',
  'arcana':         'arc',
  'athletics':      'ath',
  'deception':      'dec',
  'history':        'his',
  'insight':        'ins',
  'intimidation':   'itm',
  'investigation':  'inv',
  'medicine':       'med',
  'nature':         'nat',
  'perception':     'prc',
  'performance':    'prf',
  'persuasion':     'per',
  'religion':       'rel',
  'sleightOfHand':  'slt',
  'stealth':        'ste',
  'survival':       'sur',
};

/// Mappa lingue our (string libera) → Foundry built-in.
const _languageToFoundry = {
  'comune':       'common',
  'common':       'common',
  'elfico':       'elvish',
  'elvish':       'elvish',
  'nanico':       'dwarvish',
  'dwarvish':     'dwarvish',
  'gigante':      'giant',
  'giant':        'giant',
  'gnomesco':     'gnomish',
  'gnomish':      'gnomish',
  'goblin':       'goblin',
  'halfling':     'halfling',
  'mezzuomo':     'halfling',
  'orchesco':     'orc',
  'orc':          'orc',
  'abissale':     'abyssal',
  'abyssal':      'abyssal',
  'celestiale':   'celestial',
  'celestial':    'celestial',
  'draconico':    'draconic',
  'draconic':     'draconic',
  'infernale':    'infernal',
  'infernal':     'infernal',
  'profondo':     'deep',
  'deep':         'deep',
  'silvano':      'sylvan',
  'sylvan':       'sylvan',
  'sottocomune':  'undercommon',
  'undercommon':  'undercommon',
};

/// Decoder per chiavi proficiency standard (weapon/armor) di dnd5e.
const _weaponProfLabels = {
  'sim':  'Armi semplici',
  'mar':  'Armi da guerra',
  'firearms':     'Armi da fuoco',
  'siege':        'Armi d\'assedio',
};

const _armorProfLabels = {
  'lgt': 'Armature leggere',
  'med': 'Armature medie',
  'hvy': 'Armature pesanti',
  'shl': 'Scudi',
};

/// Conversione kg → lb (per il campo `weightLb` del nostro modello).
const _kgToLb = 2.20462;

// ===========================================================================
//                              TO Foundry
// ===========================================================================

/// Converte la nostra rappresentazione scheda (mappa "raw" di CharacterDto)
/// in un attore Foundry dnd5e v5+. Pronto per "Import Data" su un Actor.
Map<String, dynamic> toFoundry(Map<String, dynamic> ours) {
  // Abilities con TS
  final st = (ours['savingThrows'] as Map<String, dynamic>?) ?? const {};
  Map<String, dynamic> ability(String key, String saveKey) {
    final v = ours[key];
    final saving = st[saveKey] as Map<String, dynamic>?;
    return {
      'value':      _i(v) ?? 10,
      'proficient': (saving?['proficient'] as bool?) == true ? 1 : 0,
      'bonuses':    {'check': '', 'save': ''},
    };
  }

  // Skills
  final sk = (ours['skills'] as Map<String, dynamic>?) ?? const {};
  final skillsOut = <String, dynamic>{};
  _skillToFoundry.forEach((ourKey, fKey) {
    final e   = sk[ourKey] as Map<String, dynamic>?;
    final pro = (e?['proficient'] as bool?) == true;
    final exp = (e?['expertise']  as bool?) == true;
    final value = pro ? (exp ? 2 : 1) : 0;
    skillsOut[fKey] = {
      'value':  value,
      'ability': _skillAbility(ourKey),
      'bonuses': {'check': '', 'passive': ''},
    };
  });

  // Spell slots: nostro {"1":{max,current}} → Foundry {"spell1":{value,max}}
  final slots = (ours['spellSlots'] as Map<String, dynamic>?) ?? const {};
  final foundrySpells = <String, dynamic>{};
  for (var i = 1; i <= 9; i++) {
    final s = slots['$i'] as Map<String, dynamic>?;
    if (s != null) {
      foundrySpells['spell$i'] = {
        'value': _i(s['current']) ?? _i(s['max']) ?? 0,
        'max':   _i(s['max']) ?? 0,
      };
    }
  }

  // Languages
  final langs = (ours['languages'] as List<dynamic>?)?.cast<String>() ?? const <String>[];
  final builtin = <String>{};
  final custom  = <String>[];
  for (final l in langs) {
    final key = _languageToFoundry[l.toLowerCase()];
    if (key != null) {
      builtin.add(key);
    } else {
      custom.add(l);
    }
  }

  // Items: spells e inventory come Foundry Items
  final items = <Map<String, dynamic>>[];
  for (final s in (ours['spells'] as List<dynamic>?) ?? const <dynamic>[]) {
    if (s is! Map<String, dynamic>) continue;
    final name = (s['name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;

    final compsMap = (s['components'] as Map?)?.cast<String, dynamic>() ?? const {};
    final schoolFull = (s['school'] as String?) ?? '';
    final schoolCode = _foundrySchoolCode(schoolFull);
    final descTxt  = (s['description'] as String?) ?? (s['notes'] as String?) ?? '';
    final atHigher = (s['atHigherLevels'] as String?);
    final fullDesc = (atHigher != null && atHigher.trim().isNotEmpty)
        ? '$descTxt\n\nAt Higher Levels: $atHigher'
        : descTxt;

    final isConcentration = (s['concentration'] as bool?) == true;
    final isRitual        = (s['ritual']        as bool?) == true;
    final hasVerbal       = (compsMap['verbal']   as bool?) == true;
    final hasSomatic      = (compsMap['somatic']  as bool?) == true;
    final hasMaterial     = (compsMap['material'] as bool?) == true;

    final properties = <String>[
      if (hasVerbal)       'vocal',
      if (hasSomatic)      'somatic',
      if (hasMaterial)     'material',
      if (isRitual)        'ritual',
      if (isConcentration) 'concentration',
    ];

    final alwaysPrep = (s['alwaysPrepared'] as bool?) == true;
    final isPrep     = (s['prepared']       as bool?) == true || alwaysPrep;

    items.add({
      'name': name,
      'type': 'spell',
      'system': {
        'level':       _i(s['level']) ?? 0,
        'school':      schoolCode,
        'method':      alwaysPrep ? 'atwill' : 'spell',
        'prepared':    alwaysPrep ? 2 : (isPrep ? 1 : 0),
        // dnd5e v5: properties array; manteniamo anche components per retro-compat
        'properties':  properties,
        'components': {
          'vocal':         hasVerbal,
          'somatic':       hasSomatic,
          'material':      hasMaterial,
          'ritual':        isRitual,
          'concentration': isConcentration,
        },
        'materials':   {'value': (compsMap['materialDescription'] as String?) ?? ''},
        'activation':  {
          'type':  _foundryActivation(s['castingTime'] as String?),
          'value': 1,
          'cost':  1,
        },
        'duration':    _foundryDuration(s['duration'] as String?),
        'range':       _foundryRange(s['range'] as String?),
        'description': {'value': fullDesc},
        'source':      (s['source'] as String?) ?? '',
      },
    });
  }

  for (final it in (ours['inventory'] as List<dynamic>?) ?? const <dynamic>[]) {
    if (it is! Map<String, dynamic>) continue;
    final name = (it['name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;
    items.add({
      'name': name,
      'type': 'loot',
      'system': {
        'quantity': _i(it['qty']) ?? 1,
        'weight':   {'value': _d(it['weightLb']) ?? 0, 'units': 'lb'},
        'description': {'value': (it['notes'] as String?) ?? ''},
      },
    });
  }

  return {
    'name': (ours['name'] as String?) ?? 'Senza nome',
    'type': 'character',
    'system': {
      'abilities': {
        'str': ability('str',   'str'),
        'dex': ability('dex',   'dex'),
        'con': ability('con',   'con'),
        'int': ability('intel', 'int'),
        'wis': ability('wis',   'wis'),
        'cha': ability('cha',   'cha'),
      },
      'attributes': {
        'ac':       {'flat': _i(ours['armorClass']), 'calc': 'flat'},
        'hp':       {
          'value': _i(ours['hpCurrent']) ?? 0,
          'max':   _i(ours['hpMax'])     ?? 0,
          'temp':  _i(ours['hpTemp'])    ?? 0,
        },
        'init':     {'bonus': _i(ours['initiative']) ?? 0},
        'movement': {'walk': _i(ours['speed']) ?? 30, 'units': 'ft'},
        'death':    {
          'success': _i(ours['deathSavesSuccesses']) ?? 0,
          'failure': _i(ours['deathSavesFailures'])  ?? 0,
        },
        'prof': _i(ours['proficiencyBonus']),
        'hd':   {
          'value': _i(ours['hitDiceTotal']) != null && _i(ours['hitDiceUsed']) != null
              ? (_i(ours['hitDiceTotal'])! - _i(ours['hitDiceUsed'])!)
              : 0,
          'max': _i(ours['hitDiceTotal']) ?? 0,
        },
        'spellcasting': _foundryCastingAbility(ours['spellcastingClass'] as String?),
        'inspiration':  (ours['inspiration'] as bool?) == true,
      },
      'details': {
        'biography': {'value': (ours['backstory'] as String?) ?? '', 'public': ''},
        'alignment': (ours['alignment']  as String?) ?? '',
        'race':      (ours['race']       as String?) ?? '',
        'background':(ours['background'] as String?) ?? '',
        'originalClass': (ours['className'] as String?) ?? '',
        'level':     _i(ours['level']) ?? 1,
        'xp':        {'value': _i(ours['experience']) ?? 0},
        'ideal':     (ours['ideals']      as String?) ?? '',
        'bond':      (ours['bonds']       as String?) ?? '',
        'flaw':      (ours['flaws']       as String?) ?? '',
        'trait':     (ours['personalityTraits'] as String?) ?? '',
      },
      'traits': {
        'languages':  {'value': builtin.toList(), 'custom': custom.join(';')},
        'weaponProf': {'value': const <String>[], 'custom': (ours['weaponProficiencies'] as String?) ?? ''},
        'armorProf':  {'value': const <String>[], 'custom': (ours['armorProficiencies']  as String?) ?? ''},
        'toolProf':   {'value': const <String>[], 'custom': (ours['toolProficiencies']   as String?) ?? ''},
      },
      'currency': {
        'cp': _i((ours['coins'] as Map?)?['cp']) ?? 0,
        'sp': _i((ours['coins'] as Map?)?['sp']) ?? 0,
        'ep': _i((ours['coins'] as Map?)?['ep']) ?? 0,
        'gp': _i((ours['coins'] as Map?)?['gp']) ?? 0,
        'pp': _i((ours['coins'] as Map?)?['pp']) ?? 0,
      },
      'skills':   skillsOut,
      'spells':   foundrySpells,
    },
    'items': items,
    'flags': {
      'dndsheets': {
        'exportedAt': DateTime.now().toIso8601String(),
      },
    },
  };
}

// ===========================================================================
//                              FROM Foundry
// ===========================================================================

/// Converte un attore Foundry dnd5e v5+ nel nostro formato. Best-effort:
/// gli Item complessi (armi, equip avanzato) vengono ridotti a voci di
/// inventario semplici. I dati anagrafici "tipizzati" (classe/razza/
/// background) vengono risolti seguendo gli id in `details.*` verso i
/// corrispondenti Item nel campo `items`.
Map<String, dynamic> fromFoundry(Map<String, dynamic> f) {
  final system = (f['system'] as Map<String, dynamic>?) ?? const {};
  final ab     = (system['abilities']  as Map<String, dynamic>?) ?? const {};
  final attr   = (system['attributes'] as Map<String, dynamic>?) ?? const {};
  final det    = (system['details']    as Map<String, dynamic>?) ?? const {};
  final tra    = (system['traits']     as Map<String, dynamic>?) ?? const {};
  final cur    = (system['currency']   as Map<String, dynamic>?) ?? const {};
  final sk     = (system['skills']     as Map<String, dynamic>?) ?? const {};
  final sp     = (system['spells']     as Map<String, dynamic>?) ?? const {};
  final items  = (f['items']           as List<dynamic>?) ?? const [];

  // Index degli items per _id per risolvere i riferimenti in details.*
  final itemById = <String, Map<String, dynamic>>{};
  for (final it in items) {
    if (it is Map<String, dynamic>) {
      final id = it['_id'] as String?;
      if (id != null) itemById[id] = it;
    }
  }

  int? abilityValue(String key) =>
      _i((ab[key] as Map<String, dynamic>?)?['value']);

  Map<String, dynamic> savingFrom(String key) {
    final a = ab[key] as Map<String, dynamic>?;
    return {
      'proficient': _i(a?['proficient']) == 1,
      'expertise':  false,
    };
  }

  // Skills
  final ourSkills = <String, dynamic>{};
  _skillToFoundry.forEach((ourKey, fKey) {
    final s = sk[fKey] as Map<String, dynamic>?;
    final v = _i(s?['value']) ?? 0;
    ourSkills[ourKey] = {
      'proficient': v >= 1,
      'expertise':  v >= 2,
    };
  });

  // Spell slots: in dnd5e v5 `max` non e' persistito (e' calcolato).
  // Best-effort: max = value se value > 0; il PG dovra' eventualmente
  // alzare il max a mano se aveva slot consumati al momento dell'export.
  final slotsOut = <String, dynamic>{};
  for (var i = 1; i <= 9; i++) {
    final s = sp['spell$i'] as Map<String, dynamic>?;
    if (s == null) continue;
    final value = _i(s['value']);
    final max   = _i(s['max']) ?? value;
    if (max == null || max <= 0) continue;
    slotsOut['$i'] = {'max': max, 'current': value ?? max};
  }

  // Languages: built-in + custom (";" o "," separator)
  final langs = <String>[];
  final lObj  = tra['languages'] as Map<String, dynamic>?;
  if (lObj != null) {
    for (final v in (lObj['value'] as List<dynamic>?) ?? const []) {
      langs.add(_languageLabel(v.toString()));
    }
    final custom = (lObj['custom'] as String?) ?? '';
    for (final part in custom.split(RegExp(r'[;,]'))) {
      final t = part.trim();
      if (t.isNotEmpty) langs.add(t);
    }
  }

  // Risoluzione id → nome per razza/background/classe/sottoclasse
  String? resolveName(String? idOrName, String? itemType) {
    if (idOrName == null || idOrName.isEmpty) return null;
    final byId = itemById[idOrName];
    if (byId != null) return (byId['name'] as String?)?.trim();
    // fallback: gia' nome leggibile (vecchio formato)
    return idOrName;
  }

  // Trova il primo item di un certo type, opzionalmente preferendo quello
  // referenziato da details.*
  Map<String, dynamic>? findItem(String type, {String? preferId}) {
    if (preferId != null) {
      final byId = itemById[preferId];
      if (byId != null && byId['type'] == type) return byId;
    }
    for (final it in items) {
      if (it is Map<String, dynamic> && it['type'] == type) return it;
    }
    return null;
  }

  final raceItem       = findItem('race',       preferId: det['race']           as String?);
  final backgroundItem = findItem('background', preferId: det['background']     as String?);
  final classItem      = findItem('class',      preferId: det['originalClass']  as String?);
  final subclassItem   = findItem('subclass');

  final raceName     = (raceItem?['name'] as String?) ?? resolveName(det['race']       as String?, 'race');
  final bgName       = (backgroundItem?['name'] as String?) ?? resolveName(det['background'] as String?, 'background');
  final className    = (classItem?['name']    as String?) ?? resolveName(det['originalClass'] as String?, 'class');
  final subclassName = subclassItem?['name']  as String?;

  // Livello: somma dei levels su TUTTI gli item di tipo class (multiclass)
  int? totalClassLevels;
  for (final it in items) {
    if (it is Map<String, dynamic> && it['type'] == 'class') {
      final lvls = _i((it['system'] as Map?)?['levels']);
      if (lvls != null) totalClassLevels = (totalClassLevels ?? 0) + lvls;
    }
  }
  final level = totalClassLevels ?? _i(det['level']);

  // Hit dice: somma di (levels) per classe; spent → hitDiceUsed
  int totalHd = 0, spentHd = 0;
  for (final it in items) {
    if (it is Map<String, dynamic> && it['type'] == 'class') {
      final classSys = (it['system'] as Map<String, dynamic>?) ?? const {};
      final lvls = _i(classSys['levels']) ?? 0;
      final hdMap = classSys['hd'] as Map<String, dynamic>?;
      final spent = _i(hdMap?['spent']) ?? 0;
      totalHd += lvls;
      spentHd += spent;
    }
  }

  // Spellcasting class: classe con progression != "none" e != null
  String? spellcastingClass;
  for (final it in items) {
    if (it is Map<String, dynamic> && it['type'] == 'class') {
      final progr = ((it['system'] as Map?)?['spellcasting'] as Map?)?['progression'] as String?;
      if (progr != null && progr.isNotEmpty && progr != 'none') {
        spellcastingClass = it['name'] as String?;
        break;
      }
    }
  }
  spellcastingClass ??= className;

  // Items: spells, inventory, features
  final spells    = <Map<String, dynamic>>[];
  final inventory = <Map<String, dynamic>>[];
  final featureLines = <String>[];

  for (final it in items) {
    if (it is! Map<String, dynamic>) continue;
    final type = it['type'] as String?;
    final name = (it['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) continue;
    final itSys = (it['system'] as Map<String, dynamic>?) ?? const {};

    switch (type) {
      case 'spell':
        spells.add(_spellFromFoundry(name, itSys));
        break;

      case 'feat':
        final descObj = itSys['description'] as Map<String, dynamic>?;
        final descTxt = (descObj?['value'] as String?) ?? '';
        featureLines.add(descTxt.isNotEmpty ? '$name — $descTxt' : name);
        break;

      case 'loot':
      case 'consumable':
      case 'equipment':
      case 'weapon':
      case 'tool':
      case 'container':
      case 'backpack':
        inventory.add(_inventoryFromFoundry(name, itSys, itemById));
        break;

      // race / class / subclass / background: NON entrano in inventory.
      // I loro dati anagrafici sono gia' stati estratti sopra.
      default:
        break;
    }
  }

  // Backstory
  final bio = (det['biography'] as Map<String, dynamic>?);
  final backstory = (bio?['value'] as String?) ?? '';

  // Proficiencies: label-list built-in + custom string
  String renderProf(Map<String, String> labels, Map? obj) {
    if (obj == null) return '';
    final parts = <String>[];
    for (final v in (obj['value'] as List<dynamic>?) ?? const []) {
      final s = v.toString();
      parts.add(labels[s.toLowerCase()] ?? _capitalize(s));
    }
    final custom = (obj['custom'] as String?)?.trim() ?? '';
    if (custom.isNotEmpty) {
      for (final p in custom.split(RegExp(r'[;,]'))) {
        final t = p.trim();
        if (t.isNotEmpty) parts.add(t);
      }
    }
    return parts.join(', ');
  }

  // Tool proficiencies: leggiamo sia traits.toolProf sia system.tools
  final toolFromTraits = renderProf(const {}, tra['toolProf'] as Map?);
  final toolFromMap    = <String>[];
  final toolsObj = system['tools'] as Map<String, dynamic>?;
  if (toolsObj != null) {
    toolsObj.forEach((k, v) {
      if (v is Map && (_i(v['value']) ?? 0) >= 1) {
        toolFromMap.add(_capitalize(k));
      }
    });
  }
  final toolJoined = [
    if (toolFromTraits.isNotEmpty) toolFromTraits,
    if (toolFromMap.isNotEmpty)    toolFromMap.join(', '),
  ].join(', ');

  // HP: in dnd5e v5 `max` puo' essere null (calcolato). Fallback: value.
  final hpValue = _i((attr['hp'] as Map?)?['value']);
  final hpMax   = _i((attr['hp'] as Map?)?['max']) ?? hpValue;

  // AC: idem; preferiamo `flat` se settato, altrimenti `value` se presente
  final acFlat  = _i((attr['ac'] as Map?)?['flat']);
  final acValue = _i((attr['ac'] as Map?)?['value']);

  return <String, dynamic>{
    'name':       f['name']             as String?,
    'race':       raceName,
    'background': bgName,
    'alignment':  det['alignment']      as String?,
    'className':  className,
    'subclass':   subclassName,
    'level':      level,
    'experience': _i((det['xp'] as Map?)?['value']),
    'inspiration': (attr['inspiration'] as bool?) == true,
    'str':   abilityValue('str'),
    'dex':   abilityValue('dex'),
    'con':   abilityValue('con'),
    'intel': abilityValue('int'),
    'wis':   abilityValue('wis'),
    'cha':   abilityValue('cha'),
    'savingThrows': {
      'str': savingFrom('str'),
      'dex': savingFrom('dex'),
      'con': savingFrom('con'),
      'int': savingFrom('int'),
      'wis': savingFrom('wis'),
      'cha': savingFrom('cha'),
    },
    'skills': ourSkills,
    'armorClass':       acFlat ?? acValue,
    'initiative':       _i((attr['init'] as Map?)?['bonus']),
    'speed':            _i((attr['movement'] as Map?)?['walk']),
    'hpMax':            hpMax,
    'hpCurrent':        hpValue,
    'hpTemp':           _i((attr['hp']  as Map?)?['temp']),
    'proficiencyBonus': _i(attr['prof']),
    'hitDiceTotal':     totalHd > 0 ? totalHd : null,
    'hitDiceUsed':      totalHd > 0 ? spentHd : null,
    'deathSavesSuccesses': _i((attr['death'] as Map?)?['success']),
    'deathSavesFailures':  _i((attr['death'] as Map?)?['failure']),
    'spellcastingClass':  spellcastingClass,
    'spellSlots': slotsOut,
    'spells':     spells,
    'inventory':  inventory,
    'coins': {
      'cp': _i(cur['cp']),
      'sp': _i(cur['sp']),
      'ep': _i(cur['ep']),
      'gp': _i(cur['gp']),
      'pp': _i(cur['pp']),
    },
    'languages': langs,
    'armorProficiencies':  renderProf(_armorProfLabels,  tra['armorProf']  as Map?),
    'weaponProficiencies': renderProf(_weaponProfLabels, tra['weaponProf'] as Map?),
    'toolProficiencies':   toolJoined,
    'personalityTraits':   det['trait'] as String?,
    'ideals':              det['ideal'] as String?,
    'bonds':               det['bond']  as String?,
    'flaws':               det['flaw']  as String?,
    'featuresAndTraits':   featureLines.isEmpty ? null : featureLines.join('\n\n'),
    'backstory': backstory,
  }..removeWhere((_, v) =>
      v == null ||
      (v is String && v.isEmpty) ||
      (v is List && v.isEmpty) ||
      (v is Map && v.isEmpty));
}

// ---------------------------------------------------------------------------
//                       Helpers: spell e inventory items
// ---------------------------------------------------------------------------

Map<String, dynamic> _spellFromFoundry(String name, Map<String, dynamic> sys) {
  // Components: dnd5e v5 usa `properties[]`; v3 usava `components{}`.
  final propsRaw = sys['properties'];
  final props = (propsRaw is List)
      ? propsRaw.map((e) => e.toString().toLowerCase()).toSet()
      : <String>{};
  final compsObj = (sys['components'] as Map?)?.cast<String, dynamic>() ?? const {};

  final hasVerbal   = props.contains('vocal')   || (compsObj['vocal']   as bool?) == true || (compsObj['verbal'] as bool?) == true;
  final hasSomatic  = props.contains('somatic') || (compsObj['somatic'] as bool?) == true;
  final hasMaterial = props.contains('material')|| (compsObj['material'] as bool?) == true;
  final ritual      = props.contains('ritual')  || (compsObj['ritual'] as bool?) == true;
  final concentration = props.contains('concentration')
                      || (compsObj['concentration'] as bool?) == true
                      || ((sys['duration'] as Map?)?['concentration'] as bool?) == true;

  // Preparation: dnd5e v5 ha `system.prepared` (int) + `system.method`.
  // Fallback al vecchio `preparation.mode/prepared`.
  final method = (sys['method'] as String?) ?? ((sys['preparation'] as Map?)?['mode'] as String?);
  final preparedInt = _i(sys['prepared']);
  final preparationPrep = ((sys['preparation'] as Map?)?['prepared'] as bool?) == true;

  final alwaysPrepared = method == 'atwill' || method == 'innate' ||
                         (preparedInt != null && preparedInt >= 2) ||
                         (((sys['preparation'] as Map?)?['mode']) == 'always');
  final prepared = alwaysPrepared ||
                   (preparedInt != null && preparedInt >= 1) ||
                   preparationPrep;

  final mats = (sys['materials'] as Map<String, dynamic>?)?['value'] as String?;
  final descV = ((sys['description'] as Map<String, dynamic>?)?['value'] as String?) ?? '';

  final out = <String, dynamic>{
    'name':          name,
    'level':         _i(sys['level']) ?? 0,
    'school':        _ourSchool(sys['school'] as String?),
    'castingTime':   _foundryActivationLabel(sys['activation'] as Map?),
    'range':         _rangeLabel(sys['range'] as Map?),
    'duration':      _durationLabel(sys['duration'] as Map?),
    'components': {
      'verbal':   hasVerbal,
      'somatic':  hasSomatic,
      'material': hasMaterial,
      if (mats != null && mats.isNotEmpty) 'materialDescription': mats,
    },
    'concentration': concentration,
    'ritual':        ritual,
    'description':   descV,
    'source':        sys['source'] as String?,
    'prepared':      prepared,
    'alwaysPrepared': alwaysPrepared,
  };
  out.removeWhere((_, v) => v == null);
  return out;
}

Map<String, dynamic> _inventoryFromFoundry(
  String name,
  Map<String, dynamic> sys,
  Map<String, Map<String, dynamic>> itemById,
) {
  // Peso: {value, units} con units 'lb' o 'kg'. Convertiamo a libbre.
  double? weightLb;
  final w = sys['weight'];
  if (w is Map) {
    final value = _d(w['value']);
    final units = (w['units'] as String?)?.toLowerCase() ?? 'lb';
    weightLb = value == null ? null : (units == 'kg' ? value * _kgToLb : value);
  } else {
    weightLb = _d(w);
  }

  // Note: descrizione + (eventuale) container parent
  final descObj = sys['description'] as Map<String, dynamic>?;
  var notes = (descObj?['value'] as String?) ?? '';
  final containerId = sys['container'] as String?;
  if (containerId != null && containerId.isNotEmpty) {
    final parent = itemById[containerId];
    final pname  = (parent?['name'] as String?) ?? '';
    if (pname.isNotEmpty) {
      final prefix = 'In: $pname';
      notes = notes.isEmpty ? prefix : '$prefix\n\n$notes';
    }
  }

  return {
    'name':     name,
    'qty':      _i(sys['quantity']) ?? 1,
    'weightLb': weightLb,
    'notes':    notes,
  }..removeWhere((_, v) => v == null);
}

// ===========================================================================
//                              Helpers
// ===========================================================================

int? _i(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v ? 1 : 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return null;
    final n = num.tryParse(t);
    return n?.toInt();
  }
  return null;
}

double? _d(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }
  return null;
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _languageLabel(String foundryKey) {
  // Inverso "best-effort" della mappa di esportazione: per le lingue base
  // restituiamo il nome IT comune.
  const inverse = <String, String>{
    'common':      'Comune',
    'elvish':      'Elfico',
    'dwarvish':    'Nanico',
    'giant':       'Gigante',
    'gnomish':     'Gnomesco',
    'goblin':      'Goblin',
    'halfling':    'Halfling',
    'orc':         'Orchesco',
    'abyssal':     'Abissale',
    'celestial':   'Celestiale',
    'draconic':    'Draconico',
    'infernal':    'Infernale',
    'deep':        'Profondo',
    'sylvan':      'Silvano',
    'undercommon': 'Sottocomune',
    'primordial':  'Primordiale',
    'aquan':       'Acquan',
    'auran':       'Auran',
    'ignan':       'Ignan',
    'terran':      'Terran',
  };
  return inverse[foundryKey.toLowerCase()] ?? _capitalize(foundryKey);
}

// ---------------------------------------------------------------------------
//                          Spell field converters
// ---------------------------------------------------------------------------

/// Mappa il nostro {@code castingTime} (es. "1 action") al tipo Foundry.
String _foundryActivation(String? castingTime) {
  if (castingTime == null) return 'action';
  final t = castingTime.toLowerCase();
  if (t.contains('bonus'))    return 'bonus';
  if (t.contains('reaction')) return 'reaction';
  if (t.contains('minute'))   return 'minute';
  if (t.contains('hour'))     return 'hour';
  return 'action';
}

/// Da `system.activation` {type, value} → label leggibile.
String _foundryActivationLabel(Map? activation) {
  if (activation == null) return '1 action';
  final type  = activation['type']  as String?;
  final value = _i(activation['value']) ?? 1;
  return switch (type) {
    'action'   => '$value action',
    'bonus'    => '$value bonus action',
    'reaction' => '$value reaction',
    'minute'   => '$value minute',
    'hour'     => '$value hour',
    'none'     => 'none',
    null       => '1 action',
    _          => '$value $type',
  };
}

/// Converte la nostra duration in formato Foundry {value, units}.
Map<String, dynamic> _foundryDuration(String? duration) {
  if (duration == null) return {'value': null, 'units': 'inst'};
  final d = duration.toLowerCase();
  if (d.contains('instant')) return {'value': null, 'units': 'inst'};
  final m = RegExp(r'(\d+)\s*(round|minute|hour|day)').firstMatch(d);
  if (m != null) {
    final n = int.parse(m.group(1)!);
    final u = m.group(2)!;
    return {'value': n, 'units': switch (u) {
      'round'  => 'round',
      'minute' => 'minute',
      'hour'   => 'hour',
      'day'    => 'day',
      _        => 'minute',
    }};
  }
  return {'value': null, 'units': 'spec'};
}

String? _durationLabel(Map? d) {
  if (d == null) return null;
  final v = d['value'];
  final u = d['units'];
  if (u == 'inst') return 'Instantaneous';
  if (v == null)   return null;
  final value = _i(v);
  if (value == null) return null;
  final unitLabel = switch (u) {
    'round'  => value == 1 ? 'round' : 'rounds',
    'minute' => value == 1 ? 'minute' : 'minutes',
    'hour'   => value == 1 ? 'hour' : 'hours',
    'day'    => value == 1 ? 'day' : 'days',
    _        => u?.toString() ?? '',
  };
  return '$value $unitLabel'.trim();
}

/// Range "150 feet" → {value: 150, units: 'ft'}
Map<String, dynamic> _foundryRange(String? range) {
  if (range == null) return {'value': null, 'units': 'self'};
  final r = range.toLowerCase();
  if (r.contains('self'))  return {'value': null, 'units': 'self'};
  if (r.contains('touch')) return {'value': null, 'units': 'touch'};
  final m = RegExp(r'(\d+)').firstMatch(r);
  if (m != null) {
    final units = r.contains('mile')  ? 'mi'
                : r.contains('meter') ? 'm'
                : 'ft';
    return {'value': int.parse(m.group(1)!), 'units': units};
  }
  return {'value': null, 'units': 'spec'};
}

String? _rangeLabel(Map? r) {
  if (r == null) return null;
  final v = _i(r['value']);
  final u = r['units'] as String?;
  if (u == 'self')  return 'Self';
  if (u == 'touch') return 'Touch';
  if (v == null)    return null;
  final unitLabel = switch (u) {
    'mi'   => 'miles',
    'm'    => 'meters',
    'ft'   => 'feet',
    null   => '',
    _      => u,
  };
  return '$v $unitLabel'.trim();
}

/// Foundry school 3-lettere → nostra school estesa.
/// Nota: in dnd5e v5 transmutation usa il codice `trs` (non `tra`).
String? _ourSchool(String? short) {
  if (short == null) return null;
  return switch (short.toLowerCase()) {
    'abj' => 'Abjuration',
    'con' => 'Conjuration',
    'div' => 'Divination',
    'enc' => 'Enchantment',
    'evo' => 'Evocation',
    'ill' => 'Illusion',
    'nec' => 'Necromancy',
    'trs' => 'Transmutation',
    'tra' => 'Transmutation', // legacy
    _     => short,
  };
}

/// Nostra school estesa → 3-lettere Foundry v5.
String _foundrySchoolCode(String school) {
  return switch (school.toLowerCase()) {
    'abjuration'    => 'abj',
    'conjuration'   => 'con',
    'divination'    => 'div',
    'enchantment'   => 'enc',
    'evocation'     => 'evo',
    'illusion'      => 'ill',
    'necromancy'    => 'nec',
    'transmutation' => 'trs',
    _ => school.length >= 3 ? school.substring(0, 3).toLowerCase() : school,
  };
}

/// "Bard"/"Sorcerer"/... → ability key per spellcasting (best-effort).
String _foundryCastingAbility(String? className) {
  if (className == null) return '';
  return switch (className.toLowerCase()) {
    'bard' || 'bardo' || 'paladin' || 'paladino' || 'sorcerer' ||
    'stregone' || 'warlock' => 'cha',
    'cleric' || 'chierico' || 'druid' || 'druido' ||
    'ranger' => 'wis',
    'wizard' || 'mago' || 'artificer' || 'artefice' => 'int',
    _ => '',
  };
}

String _skillAbility(String ourKey) {
  return switch (ourKey) {
    'acrobatics'     => 'dex',
    'animalHandling' => 'wis',
    'arcana'         => 'int',
    'athletics'      => 'str',
    'deception'      => 'cha',
    'history'        => 'int',
    'insight'        => 'wis',
    'intimidation'   => 'cha',
    'investigation'  => 'int',
    'medicine'       => 'wis',
    'nature'         => 'int',
    'perception'     => 'wis',
    'performance'    => 'cha',
    'persuasion'     => 'cha',
    'religion'       => 'int',
    'sleightOfHand'  => 'dex',
    'stealth'        => 'dex',
    'survival'       => 'wis',
    _                => 'int',
  };
}
