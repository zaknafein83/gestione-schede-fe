import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/payment_models.dart';

/// Client per gli endpoint di pagamento (Paddle) del backend.
///
/// Note di gestione errori:
///  - 503 PADDLE_NOT_CONFIGURED: il backend non ha le env Paddle popolate.
///    Il chiamante mostra un messaggio "presto disponibile".
///  - 400 ALREADY_PREMIUM: l'utente prova a comprare ma e' gia' Premium.
class PaymentApi {
  PaymentApi(this._dio);
  final Dio _dio;

  /// POST /me/billing/checkout — crea l'URL di checkout (con uid/email
  /// server-side) su cui far redirigere l'utente.
  Future<CheckoutResponse> createCheckout(String accessToken) async {
    final res = await _dio.post(
      '/me/billing/checkout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return CheckoutResponse.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }
}

final paymentApiProvider =
    Provider<PaymentApi>((ref) => PaymentApi(ref.watch(dioProvider)));
