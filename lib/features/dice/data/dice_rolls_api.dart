import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../logic/dice.dart';

/// DTO server-side per un tiro persistito.
class DiceRollDto {
  DiceRollDto({
    required this.id,
    required this.characterId,
    required this.formula,
    required this.total,
    required this.breakdown,
    required this.advantage,
    required this.disadvantage,
    required this.createdAt,
  });

  final String    id;
  final String?   characterId;
  final String    formula;
  final int       total;
  final String    breakdown;
  final bool      advantage;
  final bool      disadvantage;
  final DateTime  createdAt;

  factory DiceRollDto.fromJson(Map<String, dynamic> json) => DiceRollDto(
        id:           json['id']            as String,
        characterId:  json['characterId']   as String?,
        formula:      json['formula']       as String,
        total:        (json['total']        as num).toInt(),
        breakdown:    (json['breakdown']    as String?) ?? '',
        advantage:    (json['advantage']    as bool?) ?? false,
        disadvantage: (json['disadvantage'] as bool?) ?? false,
        createdAt:    DateTime.parse(json['createdAt'] as String),
      );

  /// Converte in DiceRoll "locale" senza terms (basta breakdown stringa).
  DiceRoll toDiceRoll() => DiceRoll(
        formula: formula,
        terms:   const [], // server non rimanda i term — il breakdown e' gia' formattato
        total:   total,
        advantage:    advantage,
        disadvantage: disadvantage,
        timestamp:    createdAt,
      );
}

/// Client REST per /dice-rolls.
class DiceRollsApi {
  DiceRollsApi(this._dio);
  final Dio _dio;

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  Future<List<DiceRollDto>> list(
    String accessToken, {
    String? characterId,
    int limit = 50,
  }) async {
    final qp = <String, dynamic>{'limit': limit};
    if (characterId != null) qp['characterId'] = characterId;
    final res = await _dio.get(
      '/dice-rolls',
      queryParameters: qp,
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => DiceRollDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<DiceRollDto> create(
    String accessToken, {
    required DiceRoll roll,
    String? characterId,
  }) async {
    final payload = {
      'formula':      roll.formula,
      'total':        roll.total,
      'breakdown':    roll.breakdown(),
      'advantage':    roll.advantage,
      'disadvantage': roll.disadvantage,
      'characterId':  ?characterId,
    };
    final res = await _dio.post(
      '/dice-rolls',
      data: payload,
      options: _auth(accessToken),
    );
    if (res.statusCode == 201) {
      return DiceRollDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<void> clear(String accessToken) async {
    final res = await _dio.delete('/dice-rolls', options: _auth(accessToken));
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }
}

final diceRollsApiProvider =
    Provider<DiceRollsApi>((ref) => DiceRollsApi(ref.watch(dioProvider)));
