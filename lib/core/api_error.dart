/// Errore restituito dal backend in formato RFC 7807 (application/problem+json).
class ApiError implements Exception {
  ApiError({
    required this.status,
    required this.code,
    required this.detail,
  });

  final int status;
  final String code;
  final String detail;

  /// Costruisce un [ApiError] da una risposta dio con status >= 400.
  /// Robusto: se il body non e' parsabile usa fallback ragionevoli.
  factory ApiError.fromResponseData(int status, Object? data) {
    if (data is Map<String, dynamic>) {
      return ApiError(
        status: (data['status'] as int?) ?? status,
        code:   (data['code']   as String?) ?? 'UNKNOWN',
        detail: (data['detail'] as String?) ?? 'Errore sconosciuto',
      );
    }
    return ApiError(status: status, code: 'UNKNOWN', detail: data?.toString() ?? 'Errore sconosciuto');
  }

  @override
  String toString() => 'ApiError($status $code: $detail)';
}
