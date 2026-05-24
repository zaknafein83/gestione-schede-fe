import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/character_models.dart';

/// Client REST per gli endpoint /characters di backend.
/// Tutti i metodi richiedono un access token valido nel header Authorization.
class CharactersApi {
  CharactersApi(this._dio);
  final Dio _dio;

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  Future<List<CharacterSummary>> list(String accessToken) async {
    final res = await _dio.get('/characters', options: _auth(accessToken));
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => CharacterSummary.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// Crea una scheda con il payload dato (puo' essere vuoto).
  /// Backend ritorna 201 + scheda completa.
  Future<CharacterDto> create(String accessToken, Map<String, dynamic> payload) async {
    final res = await _dio.post('/characters', data: payload, options: _auth(accessToken));
    if (res.statusCode == 201) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<CharacterDto> get(String accessToken, String id) async {
    final res = await _dio.get('/characters/$id', options: _auth(accessToken));
    if (res.statusCode == 200) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<CharacterDto> patch(
    String accessToken,
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.patch('/characters/$id', data: payload, options: _auth(accessToken));
    if (res.statusCode == 200) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<void> delete(String accessToken, String id) async {
    final res = await _dio.delete('/characters/$id', options: _auth(accessToken));
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// POST /characters/{id}/duplicate — crea copia con suffisso al nome.
  Future<CharacterDto> duplicate(String accessToken, String id) async {
    final res = await _dio.post('/characters/$id/duplicate', options: _auth(accessToken));
    if (res.statusCode == 201) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// POST /characters/{id}/portrait — multipart upload.
  Future<CharacterDto> uploadPortrait(
    String accessToken,
    String id, {
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(contentType),
      ),
    });
    final res = await _dio.post(
      '/characters/$id/portrait',
      data: form,
      options: _auth(accessToken),
    );
    if (res.statusCode == 200) {
      return CharacterDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// GET /characters/{id}/portrait — scarica i bytes; null se 404.
  Future<Uint8List?> downloadPortrait(String accessToken, String id) async {
    final res = await _dio.get<List<int>>(
      '/characters/$id/portrait',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        responseType: ResponseType.bytes,
      ),
    );
    if (res.statusCode == 200 && res.data != null) {
      return Uint8List.fromList(res.data!);
    }
    if (res.statusCode == 404) return null;
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<void> deletePortrait(String accessToken, String id) async {
    await _dio.delete('/characters/$id/portrait', options: _auth(accessToken));
  }
}

final charactersApiProvider =
    Provider<CharactersApi>((ref) => CharactersApi(ref.watch(dioProvider)));
