/// Mapper bidirezionale tra il nostro JSON di scheda e il formato attore
/// di FoundryVTT (sistema dnd5e).
///
/// Strategia: BEST-EFFORT. Mappiamo i campi "core" (anagrafica, abilities,
/// skills, attributi, slot, monete, lingue). Items complessi (armi/spell/
/// classi come Item di Foundry) NON sono mappati: sopravvivono solo nome
/// e quantità/livello dove applicabile.
///
/// Campi NON mappati:
///   - Armi/armature/equip come Foundry Item (perdi statistiche complete)
///   - Spells come Foundry Item (perdiamo school/casting time/etc.)
///   - Class/Race/Background come Foundry Item (li trattiamo come stringhe)
///   - Active Effects e Conditions PHB (in Foundry sono active effects)
///   - Features e tratti raziali/di classe
///   - portrait/avatar (la nostra app lo gestisce via GridFS, non viene
///     incluso nell'export Foundry; vanno reimpostati a mano)
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

/// Mappa lingue our (string libera) → Foundry built-in. Tutto il resto va in custom.
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

// ===========================================================================
//                              TO Foundry
// ===========================================================================

/// Converte la nostra rappresentazione scheda (mappa "raw" di CharacterDto)
/// in un attore Foundry dnd5e. Pronto per essere importato come .json di
/// "Import Data" su un Actor in Foundry.
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

  // Items: spells e inventory diventano placeholder
  final items = <Map<String, dynamic>>[];
  for (final s in (ours['spells'] as List<dynamic>?) ?? const <dynamic>[]) {
    if (s is Map<String, dynamic>) {
      final name = (s['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final comps   = (s['components'] as Map?)?.cast<String, dynamic>() ?? const {};
      final school  = (s['school']         as String?)?.toLowerCase().substring(0, 3);
      final descTxt = (s['description']    as String?) ??
                       (s['notes']         as String?) ?? '';
      final atHigher = (s['atHigherLevels'] as String?);
      final fullDesc = (atHigher != null && atHigher.trim().isNotEmpty)
          ? '$descTxt\n\nAt Higher Levels: $atHigher'
          : descTxt;
      items.add({
        'name': name,
        'type': 'spell',
        'system': {
          'level':       _i(s['level']) ?? 0,
          'school':      school,
          'preparation': {
            'prepared': (s['prepared'] as bool?) == true ||
                        (s['alwaysPrepared'] as bool?) == true,
            'mode': (s['alwaysPrepared'] as bool?) == true ? 'always' : 'prepared',
          },
          'components': {
            'vocal':         (comps['verbal']   as bool?) == true,
            'somatic':       (comps['somatic']  as bool?) == true,
            'material':      (comps['material'] as bool?) == true,
            'ritual':        (s['ritual']        as bool?) == true,
            'concentration': (s['concentration'] as bool?) == true,
          },
          'materials':   {'value': (comps['materialDescription'] as String?) ?? ''},
          'activation':  {'type': _foundryActivation(s['castingTime'] as String?), 'cost': 1},
          'duration':    _foundryDuration(s['duration'] as String?),
          'range':       _foundryRange(s['range'] as String?),
          'description': {'value': fullDesc},
          'source':      (s['source'] as String?) ?? '',
        },
      });
    }
  }
  for (final it in (ours['inventory'] as List<dynamic>?) ?? const <dynamic>[]) {
    if (it is Map<String, dynamic>) {
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
        'spellcasting': '',
      },
      'details': {
        'biography': {'value': (ours['backstory'] as String?) ?? '', 'public': ''},
        'alignment': (ours['alignment']  as String?) ?? '',
        'race':      (ours['race']       as String?) ?? '',
        'background':(ours['background'] as String?) ?? '',
        'originalClass': (ours['className'] as String?) ?? '',
        'level':     _i(ours['level']) ?? 1,
        'xp':        {'value': _i(ours['experience']) ?? 0},
      },
      'traits': {
        'languages': {'value': builtin.toList(), 'custom': custom.join(';')},
        'weaponProf': {'value': [], 'custom': (ours['weaponProficiencies'] as String?) ?? ''},
        'armorProf':  {'value': [], 'custom': (ours['armorProficiencies']  as String?) ?? ''},
        'toolProf':   {'value': [], 'custom': (ours['toolProficiencies']   as String?) ?? ''},
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

/// Converte un attore Foundry dnd5e nel nostro formato. Best-effort: items
/// complessi (armi, equip avanzato) NON vengono ricostruiti; spell e loot
/// items diventano voci semplificate nella nostra lista.
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

  // Spell slots
  final slotsOut = <String, dynamic>{};
  for (var i = 1; i <= 9; i++) {
    final s = sp['spell$i'] as Map<String, dynamic>?;
    if (s == null) continue;
    final mx = _i(s['max']);
    if (mx == null || mx <= 0) continue;
    slotsOut['$i'] = {'max': mx, 'current': _i(s['value']) ?? mx};
  }

  // Languages
  final langs = <String>[];
  final lObj  = tra['languages'] as Map<String, dynamic>?;
  if (lObj != null) {
    for (final v in (lObj['value'] as List<dynamic>?) ?? const []) {
      langs.add(_capitalize(v.toString()));
    }
    final custom = (lObj['custom'] as String?) ?? '';
    for (final part in custom.split(RegExp(r'[;,]'))) {
      final t = part.trim();
      if (t.isNotEmpty) langs.add(t);
    }
  }

  // Items: spells e loot
  final spells = <Map<String, dynamic>>[];
  final inventory = <Map<String, dynamic>>[];
  for (final it in items) {
    if (it is! Map<String, dynamic>) continue;
    final type = it['type'] as String?;
    final name = (it['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) continue;
    final itSys = (it['system'] as Map<String, dynamic>?) ?? const {};

    if (type == 'spell') {
      final prep  = (itSys['preparation'] as Map<String, dynamic>?) ?? const {};
      final comps = (itSys['components']  as Map<String, dynamic>?) ?? const {};
      final mode  = prep['mode'] as String?;
      final descV = ((itSys['description'] as Map<String, dynamic>?)?['value'] as String?) ?? '';
      final mats  = (itSys['materials'] as Map<String, dynamic>?)?['value'] as String?;
      spells.add({
        'name':           name,
        'level':          _i(itSys['level']) ?? 0,
        'school':         _ourSchool(itSys['school'] as String?),
        'castingTime':    _foundryActivationLabel((itSys['activation'] as Map?)?['type'] as String?),
        'range':          _rangeLabel(itSys['range'] as Map?),
        'duration':       _durationLabel(itSys['duration'] as Map?),
        'components': {
          'verbal':              (comps['vocal']   as bool?) == true,
          'somatic':             (comps['somatic'] as bool?) == true,
          'material':            (comps['material'] as bool?) == true,
          if (mats != null && mats.isNotEmpty) 'materialDescription': mats,
        },
        'concentration':  (comps['concentration'] as bool?) == true,
        'ritual':         (comps['ritual']        as bool?) == true,
        'description':    descV,
        'source':         itSys['source'] as String?,
        'prepared':       (prep['prepared'] as bool?) == true,
        'alwaysPrepared': mode == 'always',
        // notes lasciato vuoto: in Foundry "description" e' il testo dell'incantesimo,
        // non note per-personaggio.
      }..removeWhere((_, v) => v == null));
    } else if (type == 'loot' || type == 'consumable' || type == 'equipment' ||
               type == 'weapon' || type == 'tool' || type == 'backpack') {
      final w = (itSys['weight'] is Map)
          ? _d((itSys['weight'] as Map)['value'])
          : _d(itSys['weight']);
      inventory.add({
        'name': name,
        'qty':  _i(itSys['quantity']) ?? 1,
        'weightLb': w,
        'notes':
            ((itSys['description'] as Map<String, dynamic>?)?['value'] as String?) ?? '',
      });
    }
  }

  // Backstory
  final bio = (det['biography'] as Map<String, dynamic>?);
  final backstory = (bio?['value'] as String?) ?? '';

  final hd = attr['hd'] as Map<String, dynamic>?;

  return <String, dynamic>{
    'name':       f['name']                  as String?,
    'race':       det['race']                as String?,
    'background': det['background']          as String?,
    'alignment':  det['alignment']           as String?,
    'className':  det['originalClass']       as String?,
    'level':      _i(det['level']),
    'experience': _i((det['xp']  as Map?)?['value']),
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
    'armorClass':       _i((attr['ac']   as Map?)?['flat']) ?? _i((attr['ac']   as Map?)?['value']),
    'initiative':       _i((attr['init'] as Map?)?['bonus']),
    'speed':            _i((attr['movement'] as Map?)?['walk']),
    'hpMax':            _i((attr['hp']  as Map?)?['max']),
    'hpCurrent':        _i((attr['hp']  as Map?)?['value']),
    'hpTemp':           _i((attr['hp']  as Map?)?['temp']),
    'proficiencyBonus': _i(attr['prof']),
    'hitDiceTotal':     _i(hd?['max']),
    'hitDiceUsed':      (hd != null && _i(hd['max']) != null && _i(hd['value']) != null)
        ? _i(hd['max'])! - _i(hd['value'])!
        : null,
    'deathSavesSuccesses': _i((attr['death'] as Map?)?['success']),
    'deathSavesFailures':  _i((attr['death'] as Map?)?['failure']),
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
    'armorProficiencies':  ((tra['armorProf']  as Map?)?['custom'] as String?) ?? '',
    'weaponProficiencies': ((tra['weaponProf'] as Map?)?['custom'] as String?) ?? '',
    'toolProficiencies':   ((tra['toolProf']   as Map?)?['custom'] as String?) ?? '',
    'backstory': backstory,
  }..removeWhere((_, v) => v == null);
}

// ===========================================================================
//                              Helpers
// ===========================================================================

int? _i(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

double? _d(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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

String _foundryActivationLabel(String? type) {
  return switch (type) {
    'action'   => '1 action',
    'bonus'    => '1 bonus action',
    'reaction' => '1 reaction',
    'minute'   => '1 minute',
    'hour'     => '1 hour',
    _          => null,
  } ?? type ?? '1 action';
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
  return '$v ${u ?? ""}'.trim();
}

/// Range "150 feet" → {value: 150, units: 'ft'}
Map<String, dynamic> _foundryRange(String? range) {
  if (range == null) return {'value': null, 'units': 'self'};
  final r = range.toLowerCase();
  if (r.contains('self'))  return {'value': null, 'units': 'self'};
  if (r.contains('touch')) return {'value': null, 'units': 'touch'};
  final m = RegExp(r'(\d+)').firstMatch(r);
  if (m != null) {
    return {'value': int.parse(m.group(1)!), 'units': r.contains('mile') ? 'mi' : 'ft'};
  }
  return {'value': null, 'units': 'spec'};
}

String? _rangeLabel(Map? r) {
  if (r == null) return null;
  final v = r['value'];
  final u = r['units'];
  if (u == 'self')  return 'Self';
  if (u == 'touch') return 'Touch';
  if (v == null)    return null;
  return '$v ${u == "mi" ? "miles" : "feet"}';
}

/// Foundry school 3-lettere → nostra school estesa.
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
    'tra' => 'Transmutation',
    _     => short,
  };
}

String _skillAbility(String ourKey) {
  // Mappa hardcoded skill → ability key Foundry (3 lettere).
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
