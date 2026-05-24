import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_storage.dart';
import '../logic/dice.dart';
import 'dice_rolls_api.dart';

/// Cronologia tiri persistita su backend (TTL 30 giorni). Bootstrap via GET,
/// add fa POST best-effort (errori loggati ma non bloccano l'UI: il tiro
/// resta nella lista locale).
class DiceHistory extends AsyncNotifier<List<DiceRoll>> {
  static const int _maxLocal = 50;

  DiceRollsApi  get _api     => ref.read(diceRollsApiProvider);
  AuthStorage   get _storage => ref.read(authStorageProvider);

  @override
  Future<List<DiceRoll>> build() async {
    final access = await _storage.loadAccess();
    if (access == null) return const [];
    try {
      final dtos = await _api.list(access, limit: _maxLocal);
      return dtos.map((e) => e.toDiceRoll()).toList();
    } catch (_) {
      // Se il backend e' down, partiamo con storia vuota — non blocchiamo l'UI.
      return const [];
    }
  }

  /// Aggiunge il tiro localmente subito, poi tenta il POST in background.
  void add(DiceRoll roll, {String? characterId}) {
    final current = state.asData?.value ?? const <DiceRoll>[];
    final next = [roll, ...current];
    final trimmed = next.length > _maxLocal ? next.sublist(0, _maxLocal) : next;
    state = AsyncData(trimmed);
    _persistAsync(roll, characterId);
  }

  Future<void> _persistAsync(DiceRoll roll, String? characterId) async {
    final access = await _storage.loadAccess();
    if (access == null) return;
    try {
      await _api.create(access, roll: roll, characterId: characterId);
    } catch (_) {
      // best-effort: ignoriamo l'errore (il tiro resta nella storia locale).
    }
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    final access = await _storage.loadAccess();
    if (access == null) return;
    try {
      await _api.clear(access);
    } catch (_) {
      // best-effort
    }
  }
}

final diceHistoryProvider =
    AsyncNotifierProvider<DiceHistory, List<DiceRoll>>(DiceHistory.new);
