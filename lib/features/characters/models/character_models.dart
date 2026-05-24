/// Vista ridotta restituita da GET /characters (lista delle schede).
class CharacterSummary {
  CharacterSummary({
    required this.id,
    required this.name,
    required this.race,
    required this.className,
    required this.level,
    required this.portraitFileId,
    required this.updatedAt,
  });

  final String      id;
  final String?     name;
  final String?     race;
  final String?     className;
  final int?        level;
  final String?     portraitFileId;
  final DateTime?   updatedAt;

  factory CharacterSummary.fromJson(Map<String, dynamic> json) => CharacterSummary(
        id:             json['id']             as String,
        name:           json['name']           as String?,
        race:           json['race']           as String?,
        className:      json['className']      as String?,
        level:          (json['level']         as num?)?.toInt(),
        portraitFileId: json['portraitFileId'] as String?,
        updatedAt:      json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
      );
}

/// Vista completa di una scheda. Al MVP-1 modelliamo solo i campi che ci
/// servono presto (anagrafica/portrait/timestamps); il resto resta nel
/// JSON grezzo finche' non ci serve.
///
/// In F4.4 amplieremo con stats, combat, skills, ecc.
class CharacterDto {
  CharacterDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.race,
    required this.className,
    required this.level,
    required this.portraitFileId,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String      id;
  final String      ownerId;
  final String?     name;
  final String?     race;
  final String?     className;
  final int?        level;
  final String?     portraitFileId;
  final DateTime?   createdAt;
  final DateTime?   updatedAt;
  /// JSON grezzo completo della response — utile finche' non modelliamo
  /// tutti i campi (incantesimi, attacchi, ecc.).
  final Map<String, dynamic> raw;

  factory CharacterDto.fromJson(Map<String, dynamic> json) => CharacterDto(
        id:             json['id']             as String,
        ownerId:        json['ownerId']        as String,
        name:           json['name']           as String?,
        race:           json['race']           as String?,
        className:      json['className']      as String?,
        level:          (json['level']         as num?)?.toInt(),
        portraitFileId: json['portraitFileId'] as String?,
        createdAt:      json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt:      json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
        raw:            Map<String, dynamic>.from(json),
      );
}
