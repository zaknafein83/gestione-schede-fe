import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/layout_models.dart';

/// Client REST per `/characters/{id}/layout`.
class CharacterLayoutApi {
  CharacterLayoutApi(this._dio);
  final Dio _dio;

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  /// Ritorna il layout custom o quello default (con `isDefault=true`).
  Future<CharacterLayout> get(String accessToken, String characterId) async {
    final res = await _dio.get(
      '/characters/$characterId/layout',
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return CharacterLayout.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// Salva il layout. Solo utenti PREMIUM possono chiamare (FREE → 402).
  Future<CharacterLayout> put(
    String accessToken,
    String characterId, {
    required List<LayoutWidget> widgets,
    int version = 1,
  }) async {
    final payload = {
      'version': version,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
    final res = await _dio.put(
      '/characters/$characterId/layout',
      data: payload,
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return CharacterLayout.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// Reset a default (idempotente).
  Future<void> delete(String accessToken, String characterId) async {
    final res = await _dio.delete(
      '/characters/$characterId/layout',
      options: _auth(accessToken),
    );
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }
}

final characterLayoutApiProvider =
    Provider<CharacterLayoutApi>((ref) => CharacterLayoutApi(ref.watch(dioProvider)));
