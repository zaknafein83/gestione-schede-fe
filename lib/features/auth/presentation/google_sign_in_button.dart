import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../../core/google_config.dart';
import '../data/google_auth_service.dart';

/// Renderizza il bottone ufficiale "Continua con Google" usando Google
/// Identity Services. E' un widget Flutter che incapsula un `<div>` HTML in
/// cui GIS inietta il bottone reso, e sottoscrive lo stream dei credential
/// del service per consegnarli al chiamante via [onCredential].
///
/// Web-only: su altre piattaforme/dom assenti costruisce un widget vuoto.
/// Mobile arrivera' in MVP-6 con `google_sign_in` package nativo.
class GoogleSignInButtonWidget extends ConsumerStatefulWidget {
  const GoogleSignInButtonWidget({
    super.key,
    required this.onCredential,
  });

  /// Callback chiamata ogni volta che GIS consegna un ID token JWT.
  /// Tipicamente il caller fa POST /auth/google col token ricevuto.
  final void Function(String idToken) onCredential;

  @override
  ConsumerState<GoogleSignInButtonWidget> createState() =>
      _GoogleSignInButtonWidgetState();
}

class _GoogleSignInButtonWidgetState
    extends ConsumerState<GoogleSignInButtonWidget> {
  static int _seq = 0;
  late final String _viewId = 'google-signin-${_seq++}';
  late final web.HTMLDivElement _div;

  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _div = web.document.createElement('div') as web.HTMLDivElement;
    _div.style
      ..display = 'flex'
      ..justifyContent = 'center'
      ..alignItems = 'center';

    // Registra la factory; il primo build crea il PlatformView agganciandolo.
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int _) => _div);

    // Renderizza il bottone GIS dopo il primo frame, quando il div e' nel DOM.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final svc = ref.read(googleAuthServiceProvider);
      await svc.initialize();
      if (!mounted) return;
      svc.renderButton(_div);
      _sub = svc.credentials.listen((idToken) {
        if (!mounted) return;
        widget.onCredential(idToken);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGoogleAuthEnabled) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      width: 280,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
