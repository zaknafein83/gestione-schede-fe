import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../../core/google_config.dart';

/// Bridge fra Google Identity Services (GIS) e il nostro stato Riverpod.
///
/// GIS espone `google.accounts.id.initialize/prompt/renderButton`. Il flusso:
///   1) [initialize] chiama `initialize` GIS passando una callback che, al
///      successo, riceve il JWT (campo `credential`).
///   2) UI: si renderizza un bottone via [renderButton] dentro un `<div>`
///      HTML embeddato con `HtmlElementView`.
///   3) Quando l'utente clicca, GIS apre il popup OAuth e ritorna il JWT
///      sulla callback, che lo pusha sullo stream [credentials].
///   4) Il controller ascolta lo stream e fa POST /auth/google.
///
/// Tutto web-only: gli `external` JS sono no-op su mobile (verrebbe lanciato
/// `Unsupported operation`). Il widget bottone si attiva solo se
/// [isGoogleAuthEnabled].
class GoogleAuthService {
  GoogleAuthService();

  final _credentialController = StreamController<String>.broadcast();
  bool _initialized = false;

  /// Stream degli ID token (JWT) ricevuti dalla callback GIS.
  Stream<String> get credentials => _credentialController.stream;

  bool get isInitialized => _initialized;

  /// Inizializza GIS. Idempotente. Va chiamata al boot (main.dart) ma e' anche
  /// safe chiamarla ripetutamente — solo la prima volta fa la chiamata JS.
  /// Se lo script GIS non e' ancora caricato attende fino a 5s in polling
  /// (50 tentativi a 100ms).
  Future<void> initialize() async {
    if (_initialized || !isGoogleAuthEnabled) return;
    final ok = await _waitForGisLoaded();
    if (!ok) return;
    final config = _IdConfig(
      client_id: kGoogleClientIdWeb,
      callback: _onCredential.toJS,
      auto_select: false,
      cancel_on_tap_outside: true,
    );
    _googleAccountsId.initialize(config);
    _initialized = true;
  }

  /// Renderizza il bottone ufficiale "Sign in with Google" dentro [element].
  /// Va chiamata DOPO {@link initialize}.
  void renderButton(web.HTMLElement element) {
    if (!_initialized) return;
    final opts = _ButtonOptions(
      theme: 'outline',
      size: 'large',
      type: 'standard',
      shape: 'rectangular',
      text: 'continue_with',
      logo_alignment: 'left',
      width: 280,
    );
    _googleAccountsId.renderButton(element, opts);
  }

  /// Mostra il prompt One-Tap se l'utente non e' loggato. Best-effort.
  void promptOneTap() {
    if (!_initialized) return;
    try { _googleAccountsId.prompt(); } catch (_) {}
  }

  void dispose() {
    _credentialController.close();
  }

  // --- callback GIS ---

  void _onCredential(JSObject response) {
    final credential = response.getProperty<JSString?>('credential'.toJS)?.toDart;
    if (credential != null && credential.isNotEmpty) {
      _credentialController.add(credential);
    }
  }

  Future<bool> _waitForGisLoaded() async {
    // Lo script `accounts.google.com/gsi/client` viene caricato async dall'
    // index.html. Polling breve.
    for (var i = 0; i < 50; i++) {
      final ok = _isGisLoaded();
      if (ok) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  bool _isGisLoaded() {
    // globalContext = window come JSObject (esposto da dart:js_interop).
    final google = globalContext.getProperty<JSObject?>('google'.toJS);
    if (google == null) return false;
    final accounts = google.getProperty<JSObject?>('accounts'.toJS);
    if (accounts == null) return false;
    return accounts.getProperty<JSObject?>('id'.toJS) != null;
  }
}

// ---------------------------------------------------------------------------
//                         JS interop bindings (GIS)
// ---------------------------------------------------------------------------

@JS('google.accounts.id')
external _GoogleAccountsId get _googleAccountsId;

extension type _GoogleAccountsId._(JSObject _) implements JSObject {
  external void initialize(_IdConfig config);
  external void prompt();
  external void renderButton(web.HTMLElement element, _ButtonOptions options);
}

@JS()
@anonymous
extension type _IdConfig._(JSObject _) implements JSObject {
  external factory _IdConfig({
    required String client_id,
    required JSFunction callback,
    bool auto_select,
    bool cancel_on_tap_outside,
  });
}

@JS()
@anonymous
extension type _ButtonOptions._(JSObject _) implements JSObject {
  external factory _ButtonOptions({
    String theme,
    String size,
    String type,
    String shape,
    String text,
    String logo_alignment,
    int width,
  });
}

// ---------------------------------------------------------------------------
//                              Provider Riverpod
// ---------------------------------------------------------------------------

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  final svc = GoogleAuthService();
  ref.onDispose(svc.dispose);
  return svc;
});
