/// Configurazione lato client per il login con Google.
///
/// Il Client ID Web e' pubblico per natura (viaggia nel browser, va
/// nell'`<iframe>` ufficiale di Google), quindi non e' un segreto. Lo
/// teniamo come default hardcoded ma sovrascrivibile via `--dart-define`
/// al build (es. per dev/staging con un client ID diverso).
///
/// Per disabilitare il bottone Google ovunque (es. su un build ad hoc),
/// passare `--dart-define=GOOGLE_CLIENT_ID=` (stringa vuota).
const String kGoogleClientIdWeb = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '509756405072-kdsdqqrraqkbc0leknupefo2s9orsrad.apps.googleusercontent.com',
);

bool get isGoogleAuthEnabled => kGoogleClientIdWeb.isNotEmpty;
