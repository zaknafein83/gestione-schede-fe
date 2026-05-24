import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../../characters/models/character_models.dart';

/// Vista di un token di condivisione. `token` valorizzato solo nella POST.
class ShareDto {
  ShareDto({
    required this.id,
    required this.characterId,
    required this.createdAt,
    required this.revoked,
    required this.token,
  });

  final String    id;
  final String    characterId;
  final DateTime  createdAt;
  final bool      revoked;
  /// In chiaro, presente solo subito dopo la POST. Per le altre chiamate
  /// e' null — l'utente conserva il link ricevuto.
  final String?   token;

  factory ShareDto.fromJson(Map<String, dynamic> j) => ShareDto(
        id:          j['id']          as String,
        characterId: j['characterId'] as String,
        createdAt:   DateTime.parse(j['createdAt'] as String),
        revoked:     (j['revoked']    as bool?) ?? false,
        token:       j['token']       as String?,
      );
}

class SharesApi {
  SharesApi(this._dio);
  final Dio _dio;

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  Future<ShareDto> create(String accessToken, String characterId) async {
    final res = await _dio.post(
      '/characters/$characterId/shares',
      options: _auth(accessToken),
    );
    if (res.statusCode == 201) {
      return ShareDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<List<ShareDto>> list(String accessToken, String characterId) async {
    final res = await _dio.get(
      '/characters/$characterId/shares',
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return (res.data as List<dynamic>)
          .map((e) => ShareDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<void> revoke(
      String accessToken, String characterId, String shareId) async {
    final res = await _dio.delete(
      '/characters/$characterId/shares/$shareId',
      options: _auth(accessToken),
    );
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// Endpoint pubblico — NO auth.
  Future<CharacterDto> publicView(String token) async {
    final res = await _dio.get('/share/$token');
    if (res.statusCode == 200) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }
}

final sharesApiProvider =
    Provider<SharesApi>((ref) => SharesApi(ref.watch(dioProvider)));
