/// Risposta a POST /me/billing/checkout: URL della pagina di checkout Paddle
/// (checkout.html con uid/email server-side) su cui redirigere l'utente.
class CheckoutResponse {
  CheckoutResponse({required this.url});

  final String url;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) => CheckoutResponse(
        url: json['url'] as String,
      );
}
