import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// IconButton "torna indietro" pensato per le AppBar di schermate raggiunte
/// via go_router. Va passato come `leading:` di AppBar.
///
/// Logica:
///   - se il Navigator può fare pop (atterraggio via `context.push`),
///     fa `Navigator.pop` — comportamento standard;
///   - altrimenti (atterraggio via `context.go` o URL diretto/bookmark),
///     fa `context.go(fallback)` per non lasciare l'utente bloccato.
///
/// È un helper, non un widget, così si scrive `leading: smartBackButton(...)`
/// senza ulteriore decoro.
IconButton smartBackButton(BuildContext context, {required String fallback}) {
  return IconButton(
    icon: const Icon(Icons.arrow_back),
    tooltip: AppL10n.of(context).commonBack,
    onPressed: () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.go(fallback);
      }
    },
  );
}
