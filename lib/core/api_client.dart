import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL del backend. In dev/test ascolta su localhost:8090; in prod si
/// passa "/api" (relativo) cosi' nginx fa same-origin proxy verso Quarkus.
/// Build prod tipica:
///   flutter build web --release --dart-define=API_BASE_URL=/api
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8090',
);

/// Guard anti-footgun: se una build release esce col default di sviluppo
/// (localhost/http) significa che manca il --dart-define=API_BASE_URL e l'app
/// sarebbe irraggiungibile o in chiaro. Lo segnaliamo forte in console.
bool get _isDevApiUrl =>
    apiBaseUrl.contains('localhost') || apiBaseUrl.startsWith('http://');

/// Singleton del client HTTP, condiviso tra tutte le feature.
final dioProvider = Provider<Dio>((ref) {
  if (kReleaseMode && _isDevApiUrl) {
    debugPrint(
      'ATTENZIONE: build release con API_BASE_URL="$apiBaseUrl" (default di '
      'sviluppo). Ricostruisci con --dart-define=API_BASE_URL=/api.',
    );
  }
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
    headers: {
      'Accept': 'application/json',
      // Disabilita la cache HTTP del browser per le GET API: passando fra
      // viste della stessa scheda (classico/layout) il browser ritornava
      // response cached al posto di rifetchare.
      'Cache-Control': 'no-cache',
    },
    // Lasciamo che dio NON faccia throw automatico:
    // gestiamo i codici di errore nel parsing per estrarre il problem+json.
    validateStatus: (status) => status != null && status < 500,
  ));
  return dio;
});
