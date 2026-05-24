import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/admin_models.dart';

class AdminApi {
  AdminApi(this._dio);
  final Dio _dio;

  Future<AdminUserPage> listUsers(
    String accessToken, {
    String? q,
    int page = 0,
    int pageSize = 20,
  }) async {
    final res = await _dio.get(
      '/admin/users',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'pageSize': pageSize,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return AdminUserPage.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<AdminUser> grantPremium(String accessToken, String userId) async {
    final res = await _dio.post(
      '/admin/users/$userId/grant-premium',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return AdminUser.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<AdminUser> revokePremium(String accessToken, String userId) async {
    final res = await _dio.post(
      '/admin/users/$userId/revoke-premium',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return AdminUser.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }

  Future<void> deleteUser(String accessToken, String userId) async {
    final res = await _dio.delete(
      '/admin/users/$userId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode != 204) {
      throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
    }
  }
}

final adminApiProvider = Provider<AdminApi>((ref) => AdminApi(ref.watch(dioProvider)));
