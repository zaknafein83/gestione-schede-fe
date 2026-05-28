/// Risposta a POST /me/stripe/checkout-session.
class CheckoutSession {
  CheckoutSession({required this.sessionId, required this.url});

  final String sessionId;
  final String url;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) => CheckoutSession(
        sessionId: json['sessionId'] as String,
        url:       json['url']       as String,
      );
}
