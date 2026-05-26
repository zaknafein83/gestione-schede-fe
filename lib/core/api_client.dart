import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL del backend. In dev/test ascolta su localhost:8090; in prod si
/// passa "/api" (relativo) cosi' nginx fa same-origin proxy verso Quarkus.
/// Build prod tipica:
///   flutter build web --release --dart-define=API_BASE_URL=/api
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8090',
);

/// Singleton del client HTTP, condiviso tra tutte le feature.
final dioProvider = Provider<Dio>((ref) {
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
