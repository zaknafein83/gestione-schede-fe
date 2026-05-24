import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/spell_models.dart';

/// Client per gli endpoint /spells del backend (catalogo SRD).
class SpellsApi {
  SpellsApi(this._dio);
  final Dio _dio;

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  /// GET /spells — search/list paginato con filtri opzionali.
  Future<List<SpellSummary>> search(
    String accessToken, {
    String? q,
    int?    level,
    String? school,
    String? className,
    int     offset = 0,
    int     limit  = 20,
  }) async {
    final res = await _dio.get(
      '/spells',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'level':  ?level,
        if (school != null && school.isNotEmpty) 'school': school,
        if (className != null && className.isNotEmpty) 'className': className,
        'offset': offset,
        'limit':  limit,
      },
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return (res.data as List<dynamic>)
          .map((e) => SpellSummary.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// GET /spells/count — conteggio totale per i filtri dati.
  Future<int> count(
    String accessToken, {
    String? q,
    int?    level,
    String? school,
    String? className,
  }) async {
    final res = await _dio.get(
      '/spells/count',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'level':  ?level,
        if (school != null && school.isNotEmpty) 'school': school,
        if (className != null && className.isNotEmpty) 'className': className,
      },
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return (res.data as num).toInt();
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// GET /spells/{slug} — dettaglio completo.
  Future<SpellDetail> get(String accessToken, String slug) async {
    final res = await _dio.get('/spells/$slug', options: _auth(accessToken));
    if (res.statusCode == 200) {
      return SpellDetail.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }
}

final spellsApiProvider =
    Provider<SpellsApi>((ref) => SpellsApi(ref.watch(dioProvider)));
