import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/auth_models.dart';

/// Client delle API di autenticazione.
class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<UserDto> register(RegisterRequest req) async {
    final res = await _dio.post('/auth/register', data: req.toJson());
    if (res.statusCode == 201) {
      return UserDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<UserDto> verifyEmail(String token) async {
    final res = await _dio.post('/auth/verify-email', data: {'token': token});
    if (res.statusCode == 200) {
      return UserDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<LoginResponse> login(LoginRequest req) async {
    final res = await _dio.post('/auth/login', data: req.toJson());
    if (res.statusCode == 200) {
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<LoginResponse> refresh(String refreshToken) async {
    final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    if (res.statusCode == 200) {
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// Logout: revoca il refresh token lato server. Idempotente: il backend
  /// ritorna 204 anche se il token e' gia' revocato o non esiste.
  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  /// POST /auth/forgot-password — sempre 204 (anti-enumeration: il backend
  /// non rivela se l'email esiste o meno).
  Future<void> forgotPassword(String email) async {
    final res = await _dio.post('/auth/forgot-password', data: {'email': email});
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// POST /auth/reset-password — consuma il token e imposta nuova password.
  /// Tutti i refresh token attivi dell'utente vengono revocati lato server.
  Future<void> resetPassword(String token, String newPassword) async {
    final res = await _dio.post('/auth/reset-password',
        data: {'token': token, 'password': newPassword});
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// GET /me — richiede access token valido nel header Authorization.
  Future<UserDto> me(String accessToken) async {
    final res = await _dio.get(
      '/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return UserDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// PATCH /me — partial update di displayName/bio.
  Future<UserDto> updateMe(String accessToken, UpdateMeRequest req) async {
    final res = await _dio.patch(
      '/me',
      data: req.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return UserDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// POST /me/change-password — 204 se ok. Dopo questa chiamata lato server
  /// tutti i refresh token vengono revocati.
  Future<void> changePassword(String accessToken, ChangePasswordRequest req) async {
    final res = await _dio.post(
      '/me/change-password',
      data: req.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// GET /me/export — scarica il dump completo dei dati personali
  /// dell'utente (GDPR art. 15 + 20). Ritorna la mappa JSON pronta da
  /// serializzare e offrire come download.
  Future<Map<String, dynamic>> exportMyData(String accessToken) async {
    final res = await _dio.get(
      '/me/export',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// POST /me/delete-account — hard delete cascade dell'account.
  /// Richiede la password attuale per conferma. Irreversibile.
  Future<void> deleteAccount(String accessToken, String password) async {
    final res = await _dio.post(
      '/me/delete-account',
      data: {'password': password},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }

  /// POST /me/avatar — multipart upload. Ritorna user aggiornato.
  Future<UserDto> uploadAvatar(
    String accessToken, {
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
      '/me/avatar',
      data: form,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return UserDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  /// DELETE /me/avatar — idempotente.
  Future<void> deleteAvatar(String accessToken) async {
    await _dio.delete(
      '/me/avatar',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  /// GET /me/avatar — scarica i bytes dell'avatar. 404 se assente.
  Future<Uint8List> downloadAvatar(String accessToken) async {
    final res = await _dio.get<List<int>>(
      '/me/avatar',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        responseType: ResponseType.bytes,
      ),
    );
    if (res.statusCode == 200 && res.data != null) {
      return Uint8List.fromList(res.data!);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));
