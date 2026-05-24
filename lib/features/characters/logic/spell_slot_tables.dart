/// Tabelle PHB 5e per gli slot incantesimi.
/// Le chiavi del Map ritornato sono "1".."9" (compatibili con il backend
/// che richiede chiavi String). Il valore e' il numero di slot massimo per
/// quel livello al livello del personaggio dato.
library;

import '../../../l10n/app_localizations.dart';

enum SpellProgression {
  none,
  full,    // bardo, chierico, druido, mago, stregone
  half,    // paladino, ranger
  third,   // arcane trickster, eldritch knight
  warlock, // patto magico (slot pochi ma di livello scalante)
}

String spellProgressionLabel(SpellProgression p, AppL10n l10n) {
  return switch (p) {
    SpellProgression.none    => l10n.editorSpellProgressionNone,
    SpellProgression.full    => l10n.editorSpellProgressionFull,
    SpellProgression.half    => l10n.editorSpellProgressionHalf,
    SpellProgression.third   => l10n.editorSpellProgressionThird,
    SpellProgression.warlock => l10n.editorSpellProgressionWarlock,
  };
}

// Tabella PHB pp.113-114. Indice = livello personaggio 1..20.
// Ogni entry e' una lista di 9 elementi con gli slot per i livelli 1..9.
const List<List<int>> _fullCasterTable = [
  /* lv  1 */ [2, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  2 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  3 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv  4 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv  5 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv  6 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv  7 */ [4, 3, 3, 1, 0, 0, 0, 0, 0],
  /* lv  8 */ [4, 3, 3, 2, 0, 0, 0, 0, 0],
  /* lv  9 */ [4, 3, 3, 3, 1, 0, 0, 0, 0],
  /* lv 10 */ [4, 3, 3, 3, 2, 0, 0, 0, 0],
  /* lv 11 */ [4, 3, 3, 3, 2, 1, 0, 0, 0],
  /* lv 12 */ [4, 3, 3, 3, 2, 1, 0, 0, 0],
  /* lv 13 */ [4, 3, 3, 3, 2, 1, 1, 0, 0],
  /* lv 14 */ [4, 3, 3, 3, 2, 1, 1, 0, 0],
  /* lv 15 */ [4, 3, 3, 3, 2, 1, 1, 1, 0],
  /* lv 16 */ [4, 3, 3, 3, 2, 1, 1, 1, 0],
  /* lv 17 */ [4, 3, 3, 3, 2, 1, 1, 1, 1],
  /* lv 18 */ [4, 3, 3, 3, 3, 1, 1, 1, 1],
  /* lv 19 */ [4, 3, 3, 3, 3, 2, 1, 1, 1],
  /* lv 20 */ [4, 3, 3, 3, 3, 2, 2, 1, 1],
];

// Paladino e Ranger (PHB p.84/89): slot fino al 5° livello incantesimo.
const List<List<int>> _halfCasterTable = [
  /* lv  1 */ [0, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  2 */ [2, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  3 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  4 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  5 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv  6 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv  7 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv  8 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv  9 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv 10 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv 11 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv 12 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv 13 */ [4, 3, 3, 1, 0, 0, 0, 0, 0],
  /* lv 14 */ [4, 3, 3, 1, 0, 0, 0, 0, 0],
  /* lv 15 */ [4, 3, 3, 2, 0, 0, 0, 0, 0],
  /* lv 16 */ [4, 3, 3, 2, 0, 0, 0, 0, 0],
  /* lv 17 */ [4, 3, 3, 3, 1, 0, 0, 0, 0],
  /* lv 18 */ [4, 3, 3, 3, 1, 0, 0, 0, 0],
  /* lv 19 */ [4, 3, 3, 3, 2, 0, 0, 0, 0],
  /* lv 20 */ [4, 3, 3, 3, 2, 0, 0, 0, 0],
];

// Sottoclassi a un terzo (PHB p.74/79).
const List<List<int>> _thirdCasterTable = [
  /* lv  1 */ [0, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  2 */ [0, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  3 */ [2, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  4 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  5 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  6 */ [3, 0, 0, 0, 0, 0, 0, 0, 0],
  /* lv  7 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv  8 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv  9 */ [4, 2, 0, 0, 0, 0, 0, 0, 0],
  /* lv 10 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv 11 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv 12 */ [4, 3, 0, 0, 0, 0, 0, 0, 0],
  /* lv 13 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv 14 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv 15 */ [4, 3, 2, 0, 0, 0, 0, 0, 0],
  /* lv 16 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv 17 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv 18 */ [4, 3, 3, 0, 0, 0, 0, 0, 0],
  /* lv 19 */ [4, 3, 3, 1, 0, 0, 0, 0, 0],
  /* lv 20 */ [4, 3, 3, 1, 0, 0, 0, 0, 0],
];

// Warlock — Pact Magic (PHB p.108). N slot tutti dello stesso livello.
// Indici 0..19 (livello 1..20). Tuple (numero slot, livello slot).
const List<({int count, int slotLevel})> _warlockTable = [
  /* lv  1 */ (count: 1, slotLevel: 1),
  /* lv  2 */ (count: 2, slotLevel: 1),
  /* lv  3 */ (count: 2, slotLevel: 2),
  /* lv  4 */ (count: 2, slotLevel: 2),
  /* lv  5 */ (count: 2, slotLevel: 3),
  /* lv  6 */ (count: 2, slotLevel: 3),
  /* lv  7 */ (count: 2, slotLevel: 4),
  /* lv  8 */ (count: 2, slotLevel: 4),
  /* lv  9 */ (count: 2, slotLevel: 5),
  /* lv 10 */ (count: 2, slotLevel: 5),
  /* lv 11 */ (count: 3, slotLevel: 5),
  /* lv 12 */ (count: 3, slotLevel: 5),
  /* lv 13 */ (count: 3, slotLevel: 5),
  /* lv 14 */ (count: 3, slotLevel: 5),
  /* lv 15 */ (count: 3, slotLevel: 5),
  /* lv 16 */ (count: 3, slotLevel: 5),
  /* lv 17 */ (count: 4, slotLevel: 5),
  /* lv 18 */ (count: 4, slotLevel: 5),
  /* lv 19 */ (count: 4, slotLevel: 5),
  /* lv 20 */ (count: 4, slotLevel: 5),
];

/// Ritorna gli slot massimi per ciascun livello (1..9) data la progressione
/// e il livello del personaggio. Mappa con chiavi "1".."9". I livelli con
/// 0 slot vengono comunque inclusi (sara' compito del chiamante decidere
/// se preservare lo stato esistente o azzerare).
Map<String, int> spellSlotsFor(SpellProgression progression, int? characterLevel) {
  if (progression == SpellProgression.none || characterLevel == null) {
    return const {};
  }
  final lv = characterLevel.clamp(1, 20);

  if (progression == SpellProgression.warlock) {
    final e = _warlockTable[lv - 1];
    return {'${e.slotLevel}': e.count};
  }

  final table = switch (progression) {
    SpellProgression.full  => _fullCasterTable,
    SpellProgression.half  => _halfCasterTable,
    SpellProgression.third => _thirdCasterTable,
    _ => const <List<int>>[],
  };
  if (table.isEmpty) return const {};
  final row = table[lv - 1];
  return {
    for (var i = 0; i < row.length; i++)
      if (row[i] > 0) '${i + 1}': row[i],
  };
}
