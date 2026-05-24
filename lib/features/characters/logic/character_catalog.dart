/// Cataloghi PHB 5e per UI: tiri salvezza e abilita' (skill).
/// Le chiavi (`key`, `abilityKey`) sono in inglese stabile per il backend
/// e per il salvataggio nello stato. Le label utente sono risolte via i18n
/// con gli helper sottostanti (`labelForSavingThrow`, `labelForSkill`,
/// `abilityShort`).
library;

import '../../../l10n/app_localizations.dart';

class CatalogEntry {
  const CatalogEntry({
    required this.key,
    required this.abilityKey,
  });

  final String key;
  /// Chiave ability nello state ("str","dex","con","int","wis","cha").
  final String abilityKey;
}

/// 6 tiri salvezza, indicizzati per ability.
const List<CatalogEntry> savingThrowsCatalog = [
  CatalogEntry(key: 'str', abilityKey: 'str'),
  CatalogEntry(key: 'dex', abilityKey: 'dex'),
  CatalogEntry(key: 'con', abilityKey: 'con'),
  CatalogEntry(key: 'int', abilityKey: 'int'),
  CatalogEntry(key: 'wis', abilityKey: 'wis'),
  CatalogEntry(key: 'cha', abilityKey: 'cha'),
];

/// 18 abilita' (skill) PHB 5e.
const List<CatalogEntry> skillsCatalog = [
  CatalogEntry(key: 'acrobatics',      abilityKey: 'dex'),
  CatalogEntry(key: 'animalHandling',  abilityKey: 'wis'),
  CatalogEntry(key: 'arcana',          abilityKey: 'int'),
  CatalogEntry(key: 'athletics',       abilityKey: 'str'),
  CatalogEntry(key: 'deception',       abilityKey: 'cha'),
  CatalogEntry(key: 'history',         abilityKey: 'int'),
  CatalogEntry(key: 'insight',         abilityKey: 'wis'),
  CatalogEntry(key: 'intimidation',    abilityKey: 'cha'),
  CatalogEntry(key: 'investigation',   abilityKey: 'int'),
  CatalogEntry(key: 'medicine',        abilityKey: 'wis'),
  CatalogEntry(key: 'nature',          abilityKey: 'int'),
  CatalogEntry(key: 'perception',      abilityKey: 'wis'),
  CatalogEntry(key: 'performance',     abilityKey: 'cha'),
  CatalogEntry(key: 'persuasion',      abilityKey: 'cha'),
  CatalogEntry(key: 'religion',        abilityKey: 'int'),
  CatalogEntry(key: 'sleightOfHand',   abilityKey: 'dex'),
  CatalogEntry(key: 'stealth',         abilityKey: 'dex'),
  CatalogEntry(key: 'survival',        abilityKey: 'wis'),
];

/// Etichetta lunga di un tiro salvezza ("Forza", "Strength", ...).
/// La key e' l'ability key ("str","dex",...).
String labelForSavingThrow(String key, AppL10n l10n) {
  return switch (key) {
    'str' => l10n.sheetAbilityStr,
    'dex' => l10n.sheetAbilityDex,
    'con' => l10n.sheetAbilityCon,
    'int' => l10n.sheetAbilityInt,
    'wis' => l10n.sheetAbilityWis,
    'cha' => l10n.sheetAbilityCha,
    _     => key,
  };
}

/// Etichetta lunga di una skill (es. "Acrobazia", "Acrobatics").
String labelForSkill(String key, AppL10n l10n) {
  return switch (key) {
    'acrobatics'     => l10n.skillAcrobatics,
    'animalHandling' => l10n.skillAnimalHandling,
    'arcana'         => l10n.skillArcana,
    'athletics'      => l10n.skillAthletics,
    'deception'      => l10n.skillDeception,
    'history'        => l10n.skillHistory,
    'insight'        => l10n.skillInsight,
    'intimidation'   => l10n.skillIntimidation,
    'investigation'  => l10n.skillInvestigation,
    'medicine'       => l10n.skillMedicine,
    'nature'         => l10n.skillNature,
    'perception'     => l10n.skillPerception,
    'performance'    => l10n.skillPerformance,
    'persuasion'     => l10n.skillPersuasion,
    'religion'       => l10n.skillReligion,
    'sleightOfHand'  => l10n.skillSleightOfHand,
    'stealth'        => l10n.skillStealth,
    'survival'       => l10n.skillSurvival,
    _                => key,
  };
}

/// Etichetta breve della ability ("FOR"/"STR","DES"/"DEX",...).
String abilityShort(String abilityKey, AppL10n l10n) {
  return switch (abilityKey) {
    'str' => l10n.abilityShortStr,
    'dex' => l10n.abilityShortDex,
    'con' => l10n.abilityShortCon,
    'int' => l10n.abilityShortInt,
    'wis' => l10n.abilityShortWis,
    'cha' => l10n.abilityShortCha,
    _     => abilityKey.toUpperCase(),
  };
}
