import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dndsheets_frontend/features/share/logic/foundry_mapper.dart';

/// Test sul mapper Foundry usando un export reale di dnd5e v5+ (file
/// `fvtt-Actor-myrios-...json` esportato dal client Foundry).
void main() {
  late Map<String, dynamic> myrios;

  setUpAll(() {
    final raw = File('test/fixtures/foundry_dnd5e_v5_myrios.json').readAsStringSync();
    myrios = jsonDecode(raw) as Map<String, dynamic>;
  });

  group('fromFoundry (dnd5e v5 export)', () {
    test('estrae anagrafica dai riferimenti negli items', () {
      final ours = fromFoundry(myrios);
      expect(ours['name'],       'Myrios');
      expect(ours['race'],       'Umano Variante');
      expect(ours['background'], 'Ciarlatano');
      expect(ours['className'],  'Bardo');
      expect(ours['subclass'],   'Collegio Bardico: Collegio della Sapienza');
      expect(ours['level'],      3, reason: 'livello dalla class.system.levels');
      expect(ours['experience'], 1750);
      expect(ours['spellcastingClass'], 'Bardo');
    });

    test('mappa abilities e proficienze TS', () {
      final ours = fromFoundry(myrios);
      expect(ours['str'],   10);
      expect(ours['dex'],   14);
      expect(ours['con'],   11);
      expect(ours['intel'], 11);
      expect(ours['wis'],   11);
      expect(ours['cha'],   16);
      final ts = ours['savingThrows'] as Map<String, dynamic>;
      expect((ts['dex'] as Map)['proficient'], true);
      expect((ts['cha'] as Map)['proficient'], true);
      expect((ts['str'] as Map)['proficient'], false);
    });

    test('hp.max null nel sorgente → fallback su hp.value', () {
      final ours = fromFoundry(myrios);
      expect(ours['hpCurrent'], 18);
      expect(ours['hpMax'],     18, reason: 'in dnd5e v5 max e\' calcolato → fallback su current');
    });

    test('skills con value=2 diventano expertise', () {
      final ours = fromFoundry(myrios);
      final sk = ours['skills'] as Map<String, dynamic>;
      // investigation value=2 nell\'export → expertise
      expect((sk['investigation'] as Map)['proficient'], true);
      expect((sk['investigation'] as Map)['expertise'],  true);
    });

    test('spell slots: niente max nel sorgente → max=value se >0', () {
      final ours = fromFoundry(myrios);
      final slots = ours['spellSlots'] as Map<String, dynamic>;
      expect(slots['1'], {'max': 4, 'current': 4});
      expect(slots['2'], {'max': 2, 'current': 2});
      expect(slots.containsKey('3'), false, reason: 'value=0 → escluso');
    });

    test('items: spell con components da properties[] e school trs', () {
      final ours = fromFoundry(myrios);
      final spells = (ours['spells'] as List).cast<Map<String, dynamic>>();
      final prestidigitazione = spells.firstWhere((s) => s['name'] == 'Prestidigitazione');
      expect(prestidigitazione['level'],  0);
      expect(prestidigitazione['school'], 'Transmutation');
      expect((prestidigitazione['components'] as Map)['verbal'],   true);
      expect((prestidigitazione['components'] as Map)['somatic'],  true);
      expect((prestidigitazione['components'] as Map)['material'], false);

      final identificare = spells.firstWhere((s) => s['name'] == 'Identificare');
      expect(identificare['ritual'], true);
      expect(identificare['level'],  1);
      expect(identificare['school'], 'Divination');

      final nube = spells.firstWhere((s) => s['name'] == 'Nube di Nebbia');
      expect(nube['concentration'], true);
    });

    test('preparation: method=spell + prepared=1 → prepared=true', () {
      final ours = fromFoundry(myrios);
      final spells = (ours['spells'] as List).cast<Map<String, dynamic>>();
      final s = spells.firstWhere((x) => x['name'] == 'Comando');
      expect(s['prepared'],       true);
      expect(s['alwaysPrepared'], false);
    });

    test('inventory: contiene equipment+consumable+weapon+tool, kg→lb', () {
      final ours = fromFoundry(myrios);
      final inv = (ours['inventory'] as List).cast<Map<String, dynamic>>();
      final names = inv.map((e) => e['name'] as String).toSet();
      expect(names, contains('Armatura di Cuoio'));
      expect(names, contains('Randello'));
      expect(names, contains('Frecce'));
      expect(names, contains('Trucchi per il Camuffamento'));

      final armor = inv.firstWhere((e) => e['name'] == 'Armatura di Cuoio');
      // 5 kg → ~11.02 lb
      expect((armor['weightLb'] as num).toDouble(), closeTo(11.02, 0.05));
      expect(armor['qty'], 1);

      // Container parent appare nelle note
      final frecce = inv.firstWhere((e) => e['name'] == 'Frecce');
      expect(frecce['qty'], 13);
      expect(frecce['notes'], contains('Faretra'));
    });

    test('features: feat items concatenati in featuresAndTraits', () {
      final ours = fromFoundry(myrios);
      final f = ours['featuresAndTraits'] as String;
      expect(f, contains('Ispirazione Bardica'));
      expect(f, contains('Canto di Riposo'));
      expect(f, contains('Parole Taglienti'));
    });

    test('valuta: passa flat', () {
      final ours = fromFoundry(myrios);
      final coins = ours['coins'] as Map<String, dynamic>;
      expect(coins['gp'], 238);
      expect(coins['sp'], 10);
      expect(coins['cp'], 6);
    });

    test('lingue: built-in + custom separato da ;', () {
      final ours = fromFoundry(myrios);
      final langs = (ours['languages'] as List).cast<String>();
      expect(langs, contains('Comune'));
      expect(langs, contains('Greco'));
      expect(langs, contains('Egizio'));
    });

    test('proficienze: liste built-in decodificate + concatenazione', () {
      final ours = fromFoundry(myrios);
      expect(ours['armorProficiencies'],  contains('Armature leggere'));
      expect(ours['weaponProficiencies'], contains('Armi semplici'));
      // tools dalla sezione system.tools (lyre/flute/horn/disg/navg/painter)
      expect(ours['toolProficiencies'], isNotEmpty);
    });

    test('non include id-string crudi al posto del nome', () {
      final ours = fromFoundry(myrios);
      // gli id sono stringhe alfanumeriche di 16 char come "Jghv0H7b7n9IOlKI"
      expect(ours['race'],       isNot(matches(RegExp(r'^[A-Za-z0-9]{16}$'))));
      expect(ours['background'], isNot(matches(RegExp(r'^[A-Za-z0-9]{16}$'))));
      expect(ours['className'],  isNot(matches(RegExp(r'^[A-Za-z0-9]{16}$'))));
    });
  });

  group('toFoundry', () {
    test('round-trip: import → export → import preserva i campi core', () {
      final firstPass  = fromFoundry(myrios);
      final reExported = toFoundry(firstPass);
      final secondPass = fromFoundry(reExported);

      expect(secondPass['name'],       firstPass['name']);
      expect(secondPass['level'],      firstPass['level']);
      expect(secondPass['str'],        firstPass['str']);
      expect(secondPass['cha'],        firstPass['cha']);
      expect(secondPass['hpCurrent'],  firstPass['hpCurrent']);
      expect(secondPass['coins'],      firstPass['coins']);
    });

    test('export usa school code "trs" e properties[] per spell', () {
      final ours = {
        'name':  'Test',
        'level': 1,
        'spells': [{
          'name':  'Test Spell',
          'level': 1,
          'school': 'Transmutation',
          'components': {'verbal': true, 'somatic': true, 'material': false},
          'concentration': true,
          'ritual':        false,
        }],
      };
      final f = toFoundry(ours);
      final spellItem = (f['items'] as List).firstWhere((it) => it['type'] == 'spell') as Map<String, dynamic>;
      final sys = spellItem['system'] as Map<String, dynamic>;
      expect(sys['school'], 'trs');
      final props = (sys['properties'] as List).cast<String>();
      expect(props, containsAll(['vocal', 'somatic', 'concentration']));
      expect(props, isNot(contains('material')));
    });

    test('export usa method/prepared int (no preparation object)', () {
      final ours = {
        'name': 'X',
        'spells': [
          {'name': 'A', 'prepared': true,  'alwaysPrepared': false},
          {'name': 'B', 'prepared': false, 'alwaysPrepared': true},
        ],
      };
      final items = (toFoundry(ours)['items'] as List).cast<Map<String, dynamic>>();
      final a = items.firstWhere((e) => e['name'] == 'A');
      final b = items.firstWhere((e) => e['name'] == 'B');
      expect((a['system'] as Map)['method'],   'spell');
      expect((a['system'] as Map)['prepared'], 1);
      expect((b['system'] as Map)['method'],   'atwill');
      expect((b['system'] as Map)['prepared'], 2);
    });
  });
}
