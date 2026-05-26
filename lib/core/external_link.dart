import 'package:web/web.dart' as web;

/// Apre [url] in una nuova scheda del browser. Solo Flutter Web.
///
/// Usa `noopener,noreferrer` per evitare che la pagina aperta acceda al
/// nostro `window.opener` (best-practice per link a domini esterni).
void openExternalUrl(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
