/// Parser e roller di formule di dadi stile D&D 5e.
///
/// Notazione supportata:
///   NdM         numero di dadi (N>=1) a M facce (M>=2). Es: `1d20`, `3d6`.
///   +N | -N     bonus o malus piatto (intero). Es: `+5`, `-1`.
///   spazi       ignorati.
///   advantage   se attivo, il primo 1d20 viene tirato come 2d20 keep-highest.
///   disadvantage idem ma keep-lowest.
///
/// Esempi validi:
///   `1d20+5`     `3d6+1d4-1`     `2d8+3`     `1d20`     `5`
library;

import 'dart:math';

/// Eccezione lanciata dal parser quando la formula non e' valida.
class DiceParseException implements Exception {
  DiceParseException(this.message);
  final String message;
  @override
  String toString() => 'DiceParseException: $message';
}

/// Un singolo "termine" della formula: dadi o costante.
///   - per i dadi: `dieCount > 0` e `dieSize > 0`, `rolls` contiene gli esiti dei dadi.
///     Per advantage/disadvantage `extraRolls` contiene gli scarti.
///   - per le costanti: `dieCount == 0`, `constant != 0`.
///
/// `sign` e' +1 o -1, ed e' gia' applicato alla `value`.
class DiceTerm {
  DiceTerm({
    required this.sign,
    required this.dieCount,
    required this.dieSize,
    required this.constant,
    required this.rolls,
    required this.extraRolls,
    required this.value,
  });

  final int        sign;
  final int        dieCount;
  final int        dieSize;
  final int        constant;
  final List<int>  rolls;       // valori che contano nel totale
  final List<int>  extraRolls;  // valori scartati (advantage/disadvantage)
  final int        value;       // contributo del termine al totale, gia' con segno

  bool get isDie => dieCount > 0;

  /// Etichetta breve del termine ("3d6", "1d20", "+5").
  String label() {
    if (isDie) {
      final base = '${dieCount}d$dieSize';
      return sign < 0 ? '-$base' : base;
    }
    final n = constant * sign;
    return n >= 0 ? '+$n' : '$n';
  }
}

class DiceRoll {
  DiceRoll({
    required this.formula,
    required this.terms,
    required this.total,
    required this.advantage,
    required this.disadvantage,
    required this.timestamp,
  });

  final String         formula;
  final List<DiceTerm> terms;
  final int            total;
  final bool           advantage;
  final bool           disadvantage;
  final DateTime       timestamp;

  /// Descrizione testuale del breakdown: "3d6 [4,2,6] - 1d4 [3] + 5 = 14".
  String breakdown() {
    final buf = StringBuffer();
    for (var i = 0; i < terms.length; i++) {
      final t = terms[i];
      if (i == 0) {
        // Mostra il primo termine con segno solo se negativo
        if (t.sign < 0) buf.write('-');
      } else {
        buf.write(t.sign < 0 ? ' - ' : ' + ');
      }
      if (t.isDie) {
        buf.write('${t.dieCount}d${t.dieSize} ${t.rolls}');
        if (t.extraRolls.isNotEmpty) {
          buf.write(' (scartati ${t.extraRolls})');
        }
      } else {
        buf.write(t.constant);
      }
    }
    buf.write(' = $total');
    return buf.toString();
  }
}

/// Parsa una formula come `1d20+5` in una lista di term non valutati (no rolls).
List<({int sign, int dieCount, int dieSize, int constant})> _tokenize(String input) {
  final s = input.replaceAll(' ', '');
  if (s.isEmpty) {
    throw DiceParseException('Formula vuota');
  }
  // Spezza su + e -, conservando il separatore
  final pattern = RegExp(r'([+-]?)([^+-]+)');
  final tokens  = pattern.allMatches(s).toList();
  if (tokens.isEmpty) {
    throw DiceParseException('Formula non valida: "$input"');
  }
  // Verifica che la formula sia coperta interamente
  final reconstructed = tokens.map((m) => m.group(0)).join();
  if (reconstructed != s) {
    throw DiceParseException('Caratteri non validi: "$input"');
  }

  final result = <({int sign, int dieCount, int dieSize, int constant})>[];
  for (final m in tokens) {
    final signStr = m.group(1)!;
    final body    = m.group(2)!;
    final sign    = signStr == '-' ? -1 : 1;

    final dieMatch = RegExp(r'^(\d+)d(\d+)$').firstMatch(body);
    if (dieMatch != null) {
      final n = int.parse(dieMatch.group(1)!);
      final m = int.parse(dieMatch.group(2)!);
      if (n < 1) throw DiceParseException('Numero dadi deve essere >= 1: "$body"');
      if (m < 2) throw DiceParseException('Facce dado devono essere >= 2: "$body"');
      if (n > 100 || m > 1000) {
        throw DiceParseException('Valori troppo grandi: "$body"');
      }
      result.add((sign: sign, dieCount: n, dieSize: m, constant: 0));
      continue;
    }

    final constMatch = RegExp(r'^(\d+)$').firstMatch(body);
    if (constMatch != null) {
      result.add((sign: sign, dieCount: 0, dieSize: 0, constant: int.parse(constMatch.group(1)!)));
      continue;
    }

    throw DiceParseException('Termine non riconosciuto: "$body"');
  }
  return result;
}

/// Esegue il tiro. `advantage` e `disadvantage` si applicano SOLO al primo
/// `1d20` della formula (se presente). Sono mutuamente esclusivi.
DiceRoll rollFormula(
  String formula, {
  bool advantage    = false,
  bool disadvantage = false,
  Random? rng,
}) {
  if (advantage && disadvantage) {
    throw DiceParseException('Advantage e Disadvantage non possono essere entrambi attivi');
  }
  final tokens = _tokenize(formula);
  final r      = rng ?? Random();
  final terms  = <DiceTerm>[];
  bool firstD20Applied = false;

  for (final tk in tokens) {
    if (tk.dieCount > 0) {
      final isFirst1d20 = !firstD20Applied && tk.dieCount == 1 && tk.dieSize == 20;
      final applyAdv    = isFirst1d20 && advantage;
      final applyDis    = isFirst1d20 && disadvantage;
      if (isFirst1d20) firstD20Applied = true;

      List<int> rolls;
      List<int> extras;
      if (applyAdv || applyDis) {
        final a = r.nextInt(tk.dieSize) + 1;
        final b = r.nextInt(tk.dieSize) + 1;
        final pick = applyAdv ? (a >= b ? a : b) : (a <= b ? a : b);
        final discard = pick == a ? b : a;
        rolls  = [pick];
        extras = [discard];
      } else {
        rolls  = [for (var i = 0; i < tk.dieCount; i++) r.nextInt(tk.dieSize) + 1];
        extras = const [];
      }
      final sum   = rolls.fold<int>(0, (a, b) => a + b);
      final value = sum * tk.sign;
      terms.add(DiceTerm(
        sign: tk.sign,
        dieCount: tk.dieCount,
        dieSize:  tk.dieSize,
        constant: 0,
        rolls:    rolls,
        extraRolls: extras,
        value: value,
      ));
    } else {
      final value = tk.constant * tk.sign;
      terms.add(DiceTerm(
        sign: tk.sign,
        dieCount: 0,
        dieSize:  0,
        constant: tk.constant,
        rolls:    const [],
        extraRolls: const [],
        value: value,
      ));
    }
  }

  final total = terms.fold<int>(0, (acc, t) => acc + t.value);
  return DiceRoll(
    formula:      formula,
    terms:        terms,
    total:        total,
    advantage:    advantage,
    disadvantage: disadvantage,
    timestamp:    DateTime.now(),
  );
}
