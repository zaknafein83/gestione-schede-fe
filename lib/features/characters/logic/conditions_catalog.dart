/// Condizioni PHB 5e (Appendix A). Chiavi in inglese camelCase (compatibili
/// col backend); label e descrizione risolte via i18n.
library;

import '../../../l10n/app_localizations.dart';

class ConditionEntry {
  const ConditionEntry({required this.key});
  final String key;
}

const List<ConditionEntry> conditionsCatalog = [
  ConditionEntry(key: 'blinded'),
  ConditionEntry(key: 'charmed'),
  ConditionEntry(key: 'deafened'),
  ConditionEntry(key: 'frightened'),
  ConditionEntry(key: 'grappled'),
  ConditionEntry(key: 'incapacitated'),
  ConditionEntry(key: 'invisible'),
  ConditionEntry(key: 'paralyzed'),
  ConditionEntry(key: 'petrified'),
  ConditionEntry(key: 'poisoned'),
  ConditionEntry(key: 'prone'),
  ConditionEntry(key: 'restrained'),
  ConditionEntry(key: 'stunned'),
  ConditionEntry(key: 'unconscious'),
  ConditionEntry(key: 'exhaustion'),
];

ConditionEntry? findCondition(String key) {
  for (final c in conditionsCatalog) {
    if (c.key == key) return c;
  }
  return null;
}

String labelForCondition(String key, AppL10n l10n) {
  return switch (key) {
    'blinded'       => l10n.conditionBlinded,
    'charmed'       => l10n.conditionCharmed,
    'deafened'      => l10n.conditionDeafened,
    'frightened'    => l10n.conditionFrightened,
    'grappled'      => l10n.conditionGrappled,
    'incapacitated' => l10n.conditionIncapacitated,
    'invisible'     => l10n.conditionInvisible,
    'paralyzed'     => l10n.conditionParalyzed,
    'petrified'     => l10n.conditionPetrified,
    'poisoned'      => l10n.conditionPoisoned,
    'prone'         => l10n.conditionProne,
    'restrained'    => l10n.conditionRestrained,
    'stunned'       => l10n.conditionStunned,
    'unconscious'   => l10n.conditionUnconscious,
    'exhaustion'    => l10n.conditionExhaustion,
    _               => key,
  };
}

String descriptionForCondition(String key, AppL10n l10n) {
  return switch (key) {
    'blinded'       => l10n.conditionBlindedDesc,
    'charmed'       => l10n.conditionCharmedDesc,
    'deafened'      => l10n.conditionDeafenedDesc,
    'frightened'    => l10n.conditionFrightenedDesc,
    'grappled'      => l10n.conditionGrappledDesc,
    'incapacitated' => l10n.conditionIncapacitatedDesc,
    'invisible'     => l10n.conditionInvisibleDesc,
    'paralyzed'     => l10n.conditionParalyzedDesc,
    'petrified'     => l10n.conditionPetrifiedDesc,
    'poisoned'      => l10n.conditionPoisonedDesc,
    'prone'         => l10n.conditionProneDesc,
    'restrained'    => l10n.conditionRestrainedDesc,
    'stunned'       => l10n.conditionStunnedDesc,
    'unconscious'   => l10n.conditionUnconsciousDesc,
    'exhaustion'    => l10n.conditionExhaustionDesc,
    _               => '',
  };
}
