import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Forza il download di [content] (testo UTF-8) come file [filename] nel
/// browser. Funziona solo su Flutter Web.
///
/// Implementazione: crea un Blob, gli associa un URL temporaneo,
/// crea un anchor <a download="..."> e lo clicca programmaticamente.
void downloadTextFile(String filename, String content, {String mime = 'application/octet-stream'}) {
  final parts = JSArray<JSAny>();
  parts.add(content.toJS);

  final blob = web.Blob(parts, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);

  final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href     = url
    ..download = filename
    ..style.display = 'none';

  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  web.URL.revokeObjectURL(url);
}

/// Scarica una stringa JSON formattata come file `.json`.
void downloadJsonFile(String filename, String jsonContent) {
  downloadTextFile(filename, jsonContent, mime: 'application/json;charset=utf-8');
}

/// Scarica un buffer di bytes come file (es. PDF). Solo Web.
void downloadBytesFile(String filename, Uint8List bytes, {String mime = 'application/octet-stream'}) {
  final parts = JSArray<JSAny>();
  parts.add(bytes.toJS);

  final blob = web.Blob(parts, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);

  final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href     = url
    ..download = filename
    ..style.display = 'none';

  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  web.URL.revokeObjectURL(url);
}
