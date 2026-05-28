import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/api_error.dart';
import '../models/payment_models.dart';

/// Client per gli endpoint Stripe del backend.
///
/// Note di gestione errori:
///  - 503 STRIPE_NOT_CONFIGURED: il backend non ha le env Stripe popolate.
///    Il chiamante mostra un messaggio "presto disponibile".
///  - 400 ALREADY_PREMIUM: l'utente prova a comprare ma e' gia' Premium.
///  - 502 STRIPE_API_ERROR: Stripe API ha avuto un problema (timeout, ...).
class PaymentApi {
  PaymentApi(this._dio);
  final Dio _dio;

  /// POST /me/stripe/checkout-session — crea una Checkout Session e ritorna
  /// la URL hosted su cui far redirigere l'utente.
  Future<CheckoutSession> createCheckoutSession(String accessToken) async {
    final res = await _dio.post(
      '/me/stripe/checkout-session',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (res.statusCode == 200) {
      return CheckoutSession.fromJson(res.data as Map<String, dynamic>);
    }
    throw ApiError.fromResponseData(res.statusCode ?? 0, res.data);
  }
}

final paymentApiProvider =
    Provider<PaymentApi>((ref) => PaymentApi(ref.watch(dioProvider)));
