/// Funzioni pure per i calcoli della scheda D&D 5e.
/// Nessuna dipendenza Flutter: facili da testare in isolation.
library;

/// Modificatore di una caratteristica: floor((stat - 10) / 2).
/// Null se la stat non e' valorizzata.
int? abilityMod(int? stat) {
  if (stat == null) return null;
  // Dart truncating division (~/) tronca verso zero, non floor.
  // Per i numeri positivi e' equivalente; per i negativi serve floor.
  final delta = stat - 10;
  return delta >= 0 ? delta ~/ 2 : -((-delta + 1) ~/ 2);
}

/// Bonus competenza in base al livello PHB:
///   1-4  → +2
///   5-8  → +3
///   9-12 → +4
///   13-16→ +5
///   17-20→ +6
/// Null se il livello non e' valorizzato o fuori 1-20.
int? profBonusForLevel(int? level) {
  if (level == null) return null;
  if (level < 1 || level > 20) return null;
  return 2 + ((level - 1) ~/ 4);
}

/// Formatta un modificatore con segno esplicito: 3 → "+3", -1 → "-1", 0 → "+0".
String formatModifier(int mod) => mod >= 0 ? '+$mod' : '$mod';

/// Tenta di parsare un int da un controller; ritorna null se vuoto/invalido.
int? tryParseInt(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  return int.tryParse(t);
}
