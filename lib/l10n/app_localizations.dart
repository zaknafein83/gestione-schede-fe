import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'PG 5e'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCharacters.
  ///
  /// In it, this message translates to:
  /// **'Le tue schede'**
  String get navCharacters;

  /// No description provided for @navProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get navProfile;

  /// No description provided for @navSharedSheet.
  ///
  /// In it, this message translates to:
  /// **'Scheda condivisa'**
  String get navSharedSheet;

  /// No description provided for @navCharacterEditor.
  ///
  /// In it, this message translates to:
  /// **'Scheda personaggio'**
  String get navCharacterEditor;

  /// No description provided for @actionSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get actionDelete;

  /// No description provided for @actionDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Duplica'**
  String get actionDuplicate;

  /// No description provided for @actionRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get actionRename;

  /// No description provided for @actionExport.
  ///
  /// In it, this message translates to:
  /// **'Esporta'**
  String get actionExport;

  /// No description provided for @actionImport.
  ///
  /// In it, this message translates to:
  /// **'Importa'**
  String get actionImport;

  /// No description provided for @actionShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get actionShare;

  /// No description provided for @actionLogout.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get actionLogout;

  /// No description provided for @actionClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get actionClose;

  /// No description provided for @actionRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get actionRetry;

  /// No description provided for @actionBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get actionBack;

  /// No description provided for @actionConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get actionConfirm;

  /// No description provided for @actionRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get actionRemove;

  /// No description provided for @actionEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get actionAdd;

  /// No description provided for @actionReload.
  ///
  /// In it, this message translates to:
  /// **'Ricarica'**
  String get actionReload;

  /// No description provided for @actionGoHome.
  ///
  /// In it, this message translates to:
  /// **'Vai alla home'**
  String get actionGoHome;

  /// No description provided for @actionBackHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get actionBackHome;

  /// No description provided for @commonErrorPrefix.
  ///
  /// In it, this message translates to:
  /// **'Errore: {message}'**
  String commonErrorPrefix(Object message);

  /// No description provided for @commonNetworkError.
  ///
  /// In it, this message translates to:
  /// **'Errore di rete: {message}'**
  String commonNetworkError(Object message);

  /// No description provided for @commonRequired.
  ///
  /// In it, this message translates to:
  /// **'Obbligatorio'**
  String get commonRequired;

  /// No description provided for @commonMaxChars.
  ///
  /// In it, this message translates to:
  /// **'Massimo {n} caratteri'**
  String commonMaxChars(Object n);

  /// No description provided for @commonMinChars.
  ///
  /// In it, this message translates to:
  /// **'Almeno {n} caratteri'**
  String commonMinChars(Object n);

  /// No description provided for @commonNotAuthenticated.
  ///
  /// In it, this message translates to:
  /// **'Non sei autenticato.'**
  String get commonNotAuthenticated;

  /// No description provided for @appearance.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @languageSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua dell\'app'**
  String get languageSectionTitle;

  /// No description provided for @languageSectionHint.
  ///
  /// In it, this message translates to:
  /// **'Cambia l\'interfaccia tra italiano e inglese. \"Sistema\" segue le impostazioni del dispositivo.'**
  String get languageSectionHint;

  /// No description provided for @languageIt.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageIt;

  /// No description provided for @languageEn.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @authLoginTitle.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get authRegisterTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authUsernameLabel.
  ///
  /// In it, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome visualizzato'**
  String get authDisplayNameLabel;

  /// No description provided for @authNeedAccount.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account?'**
  String get authNeedAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account?'**
  String get authHaveAccount;

  /// No description provided for @authBtnLogin.
  ///
  /// In it, this message translates to:
  /// **'Entra'**
  String get authBtnLogin;

  /// No description provided for @authBtnRegister.
  ///
  /// In it, this message translates to:
  /// **'Crea account'**
  String get authBtnRegister;

  /// No description provided for @authOrDivider.
  ///
  /// In it, this message translates to:
  /// **'oppure'**
  String get authOrDivider;

  /// No description provided for @loginGoogleNeedsRegister.
  ///
  /// In it, this message translates to:
  /// **'Per accedere con Google la prima volta devi registrarti accettando i Termini.'**
  String get loginGoogleNeedsRegister;

  /// No description provided for @authCheckEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tua email'**
  String get authCheckEmailTitle;

  /// No description provided for @authCheckEmailBody.
  ///
  /// In it, this message translates to:
  /// **'Ti abbiamo inviato un link di verifica a {email}.'**
  String authCheckEmailBody(Object email);

  /// No description provided for @landingWelcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto'**
  String get landingWelcome;

  /// No description provided for @landingTagline.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le tue schede personaggio per giochi di ruolo fantasy 5e.'**
  String get landingTagline;

  /// No description provided for @landingCreateAccount.
  ///
  /// In it, this message translates to:
  /// **'Crea un account'**
  String get landingCreateAccount;

  /// No description provided for @landingSignIn.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get landingSignIn;

  /// No description provided for @landingHeroEyebrow.
  ///
  /// In it, this message translates to:
  /// **'Cronache di un avventuriero 5e'**
  String get landingHeroEyebrow;

  /// No description provided for @landingHeroTitle.
  ///
  /// In it, this message translates to:
  /// **'Forgia il tuo eroe.\nVivi la tua leggenda.'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Custodisci ogni scheda, lancia ogni dado, condividi le gesta del tuo personaggio — un compagno digitale per le tue avventure di ruolo 5e.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingCtaOpenWeb.
  ///
  /// In it, this message translates to:
  /// **'Entra nella tua biblioteca'**
  String get landingCtaOpenWeb;

  /// No description provided for @landingCtaOpenWebSub.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account? Accedi.'**
  String get landingCtaOpenWebSub;

  /// No description provided for @landingCtaAppStore.
  ///
  /// In it, this message translates to:
  /// **'Scarica su App Store'**
  String get landingCtaAppStore;

  /// No description provided for @landingCtaGooglePlay.
  ///
  /// In it, this message translates to:
  /// **'Disponibile su Google Play'**
  String get landingCtaGooglePlay;

  /// No description provided for @landingCtaStorePrefix.
  ///
  /// In it, this message translates to:
  /// **'Presto'**
  String get landingCtaStorePrefix;

  /// No description provided for @landingCtaSpellsPrefix.
  ///
  /// In it, this message translates to:
  /// **'Apri'**
  String get landingCtaSpellsPrefix;

  /// No description provided for @landingCtaSpells.
  ///
  /// In it, this message translates to:
  /// **'Sfoglia il codex degli incantesimi'**
  String get landingCtaSpells;

  /// No description provided for @landingCtaSpellsSub.
  ///
  /// In it, this message translates to:
  /// **'Anteprima del catalogo pubblico (in arrivo)'**
  String get landingCtaSpellsSub;

  /// No description provided for @landingFeaturesTitle.
  ///
  /// In it, this message translates to:
  /// **'Le arti del Cronista'**
  String get landingFeaturesTitle;

  /// No description provided for @landingFeaturesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tutto quello che serve a un avventuriero, raccolto in un solo grimorio.'**
  String get landingFeaturesSubtitle;

  /// No description provided for @landingFeatureSheetTitle.
  ///
  /// In it, this message translates to:
  /// **'Pergamena del PG'**
  String get landingFeatureSheetTitle;

  /// No description provided for @landingFeatureSheetDesc.
  ///
  /// In it, this message translates to:
  /// **'Ogni campo del manuale 5e, otto sezioni dedicate, calcoli automatici. Nessun dettaglio del tuo eroe va perduto.'**
  String get landingFeatureSheetDesc;

  /// No description provided for @landingFeatureDiceTitle.
  ///
  /// In it, this message translates to:
  /// **'Il fato dei dadi'**
  String get landingFeatureDiceTitle;

  /// No description provided for @landingFeatureDiceDesc.
  ///
  /// In it, this message translates to:
  /// **'Dice roller integrato, gestione PF, slot incantesimi, condizioni e riposi a portata di mano.'**
  String get landingFeatureDiceDesc;

  /// No description provided for @landingFeatureShareTitle.
  ///
  /// In it, this message translates to:
  /// **'Saghe condivise'**
  String get landingFeatureShareTitle;

  /// No description provided for @landingFeatureShareDesc.
  ///
  /// In it, this message translates to:
  /// **'Un link in sola lettura per il tuo Dungeon Master e la compagnia. Revocabile in un istante, sempre tuo.'**
  String get landingFeatureShareDesc;

  /// No description provided for @landingFeatureSpellsTitle.
  ///
  /// In it, this message translates to:
  /// **'Codex degli incantesimi'**
  String get landingFeatureSpellsTitle;

  /// No description provided for @landingFeatureSpellsDesc.
  ///
  /// In it, this message translates to:
  /// **'319 incantesimi del SRD 5.1, ricerca rapida, descrizioni complete in italiano e inglese.'**
  String get landingFeatureSpellsDesc;

  /// No description provided for @landingFooterLegal.
  ///
  /// In it, this message translates to:
  /// **'Note legali'**
  String get landingFooterLegal;

  /// No description provided for @landingFooterPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Privacy'**
  String get landingFooterPrivacy;

  /// No description provided for @landingFooterTerms.
  ///
  /// In it, this message translates to:
  /// **'Termini'**
  String get landingFooterTerms;

  /// No description provided for @landingFooterContact.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get landingFooterContact;

  /// No description provided for @landingImageCredit.
  ///
  /// In it, this message translates to:
  /// **'Illustrazione di sfondo: Placidplace via Pixabay.'**
  String get landingImageCredit;

  /// No description provided for @landingMadeBy.
  ///
  /// In it, this message translates to:
  /// **'Realizzato da Zaknafein'**
  String get landingMadeBy;

  /// No description provided for @commonBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get commonBack;

  /// No description provided for @loginAccessTitle.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginAccessTitle;

  /// No description provided for @loginEmailRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In it, this message translates to:
  /// **'Email non valida'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la password'**
  String get loginPasswordRequired;

  /// No description provided for @loginGoRegister.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Registrati'**
  String get loginGoRegister;

  /// No description provided for @loginForgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get loginForgotPassword;

  /// No description provided for @loginNetworkError.
  ///
  /// In it, this message translates to:
  /// **'Errore di rete'**
  String get loginNetworkError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordIntro.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email: se l\'account esiste ed è verificato, ti invieremo un link per impostare una nuova password.'**
  String get forgotPasswordIntro;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In it, this message translates to:
  /// **'Invia link di reset'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In it, this message translates to:
  /// **'Torna al login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordSentTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tua email'**
  String get forgotPasswordSentTitle;

  /// No description provided for @forgotPasswordSentBodyStart.
  ///
  /// In it, this message translates to:
  /// **'Se esiste un account collegato a '**
  String get forgotPasswordSentBodyStart;

  /// No description provided for @forgotPasswordSentBodyEnd.
  ///
  /// In it, this message translates to:
  /// **', riceverai a breve un link per reimpostare la password. Il link è valido per 1 ora.'**
  String get forgotPasswordSentBodyEnd;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Reimposta password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordIntro.
  ///
  /// In it, this message translates to:
  /// **'Scegli una nuova password. Tutti i dispositivi su cui sei loggato verranno disconnessi.'**
  String get resetPasswordIntro;

  /// No description provided for @resetPasswordSubmit.
  ///
  /// In it, this message translates to:
  /// **'Imposta nuova password'**
  String get resetPasswordSubmit;

  /// No description provided for @resetPasswordDoneTitle.
  ///
  /// In it, this message translates to:
  /// **'Password aggiornata!'**
  String get resetPasswordDoneTitle;

  /// No description provided for @resetPasswordDoneBody.
  ///
  /// In it, this message translates to:
  /// **'La tua password è stata reimpostata. Ora puoi accedere con quella nuova.'**
  String get resetPasswordDoneBody;

  /// No description provided for @resetPasswordMissingToken.
  ///
  /// In it, this message translates to:
  /// **'Link non valido: manca il token. Richiedi un nuovo link di reset.'**
  String get resetPasswordMissingToken;

  /// No description provided for @resetPasswordRequestNew.
  ///
  /// In it, this message translates to:
  /// **'Richiedi nuovo link'**
  String get resetPasswordRequestNew;

  /// No description provided for @registerTitle.
  ///
  /// In it, this message translates to:
  /// **'Crea un account'**
  String get registerTitle;

  /// No description provided for @registerEmailRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In it, this message translates to:
  /// **'Email non valida'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una password'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordMin.
  ///
  /// In it, this message translates to:
  /// **'Almeno 10 caratteri'**
  String get registerPasswordMin;

  /// No description provided for @registerPasswordMax.
  ///
  /// In it, this message translates to:
  /// **'Massimo 100 caratteri'**
  String get registerPasswordMax;

  /// No description provided for @registerPasswordUpper.
  ///
  /// In it, this message translates to:
  /// **'Serve almeno una lettera maiuscola'**
  String get registerPasswordUpper;

  /// No description provided for @registerPasswordDigit.
  ///
  /// In it, this message translates to:
  /// **'Serve almeno un numero'**
  String get registerPasswordDigit;

  /// No description provided for @registerPasswordsMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le due password non coincidono'**
  String get registerPasswordsMismatch;

  /// No description provided for @registerUsernameRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci uno username'**
  String get registerUsernameRequired;

  /// No description provided for @registerUsernameMin.
  ///
  /// In it, this message translates to:
  /// **'Almeno 3 caratteri'**
  String get registerUsernameMin;

  /// No description provided for @registerUsernameMax.
  ///
  /// In it, this message translates to:
  /// **'Massimo 30 caratteri'**
  String get registerUsernameMax;

  /// No description provided for @registerUsernameChars.
  ///
  /// In it, this message translates to:
  /// **'Solo lettere, numeri e underscore'**
  String get registerUsernameChars;

  /// No description provided for @registerUsernameHelper.
  ///
  /// In it, this message translates to:
  /// **'Solo lettere, numeri e underscore (3-30)'**
  String get registerUsernameHelper;

  /// No description provided for @registerDisplayRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un nome visualizzato'**
  String get registerDisplayRequired;

  /// No description provided for @registerDisplayMax.
  ///
  /// In it, this message translates to:
  /// **'Massimo 60 caratteri'**
  String get registerDisplayMax;

  /// No description provided for @registerPasswordHelper.
  ///
  /// In it, this message translates to:
  /// **'Almeno 10 caratteri, 1 maiuscola, 1 numero'**
  String get registerPasswordHelper;

  /// No description provided for @registerPasswordShow.
  ///
  /// In it, this message translates to:
  /// **'Mostra password'**
  String get registerPasswordShow;

  /// No description provided for @registerPasswordHide.
  ///
  /// In it, this message translates to:
  /// **'Nascondi password'**
  String get registerPasswordHide;

  /// No description provided for @registerConfirmLabel.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get registerConfirmLabel;

  /// No description provided for @checkEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tua email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailHeader.
  ///
  /// In it, this message translates to:
  /// **'Ti abbiamo inviato una email'**
  String get checkEmailHeader;

  /// No description provided for @checkEmailBodyStart.
  ///
  /// In it, this message translates to:
  /// **'Per attivare il tuo account, apri il link che abbiamo mandato a '**
  String get checkEmailBodyStart;

  /// No description provided for @checkEmailBodyEnd.
  ///
  /// In it, this message translates to:
  /// **'. Il link è valido per 24 ore.'**
  String get checkEmailBodyEnd;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Verifica email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailWaiting.
  ///
  /// In it, this message translates to:
  /// **'Sto verificando il tuo indirizzo email…'**
  String get verifyEmailWaiting;

  /// No description provided for @verifyEmailFailed.
  ///
  /// In it, this message translates to:
  /// **'Verifica fallita'**
  String get verifyEmailFailed;

  /// No description provided for @verifyEmailUnexpected.
  ///
  /// In it, this message translates to:
  /// **'Errore inatteso: {error}'**
  String verifyEmailUnexpected(Object error);

  /// No description provided for @verifyEmailOk.
  ///
  /// In it, this message translates to:
  /// **'Email verificata!'**
  String get verifyEmailOk;

  /// No description provided for @verifyEmailOkBody.
  ///
  /// In it, this message translates to:
  /// **'Il tuo account è ora attivo. Puoi accedere dalla home.'**
  String get verifyEmailOkBody;

  /// No description provided for @homeGreeting.
  ///
  /// In it, this message translates to:
  /// **'Ciao, {name}!'**
  String homeGreeting(Object name);

  /// No description provided for @profileTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo profilo'**
  String get profileTitle;

  /// No description provided for @profileAvatarChange.
  ///
  /// In it, this message translates to:
  /// **'Cambia avatar'**
  String get profileAvatarChange;

  /// No description provided for @profileAvatarRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get profileAvatarRemove;

  /// No description provided for @profileEmailHelper.
  ///
  /// In it, this message translates to:
  /// **'L\'email non è modificabile'**
  String get profileEmailHelper;

  /// No description provided for @profileUsernameHelper.
  ///
  /// In it, this message translates to:
  /// **'Lo username non è modificabile'**
  String get profileUsernameHelper;

  /// No description provided for @profileBioLabel.
  ///
  /// In it, this message translates to:
  /// **'Bio'**
  String get profileBioLabel;

  /// No description provided for @profileSaveBtn.
  ///
  /// In it, this message translates to:
  /// **'Salva profilo'**
  String get profileSaveBtn;

  /// No description provided for @profileChangePassword.
  ///
  /// In it, this message translates to:
  /// **'Cambia password'**
  String get profileChangePassword;

  /// No description provided for @profileUpdated.
  ///
  /// In it, this message translates to:
  /// **'Profilo aggiornato'**
  String get profileUpdated;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In it, this message translates to:
  /// **'Avatar aggiornato'**
  String get profileAvatarUpdated;

  /// No description provided for @profilePasswordChangedLogout.
  ///
  /// In it, this message translates to:
  /// **'Password cambiata. Accedi di nuovo.'**
  String get profilePasswordChangedLogout;

  /// No description provided for @changePwdTitle.
  ///
  /// In it, this message translates to:
  /// **'Cambia password'**
  String get changePwdTitle;

  /// No description provided for @changePwdCurrentLabel.
  ///
  /// In it, this message translates to:
  /// **'Password attuale'**
  String get changePwdCurrentLabel;

  /// No description provided for @changePwdNewLabel.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get changePwdNewLabel;

  /// No description provided for @changePwdNewHelper.
  ///
  /// In it, this message translates to:
  /// **'Almeno 10 caratteri, 1 maiuscola, 1 numero'**
  String get changePwdNewHelper;

  /// No description provided for @changePwdConfirmLabel.
  ///
  /// In it, this message translates to:
  /// **'Conferma nuova password'**
  String get changePwdConfirmLabel;

  /// No description provided for @changePwdRequired.
  ///
  /// In it, this message translates to:
  /// **'Obbligatoria'**
  String get changePwdRequired;

  /// No description provided for @changePwdNewRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una nuova password'**
  String get changePwdNewRequired;

  /// No description provided for @changePwdMustDiffer.
  ///
  /// In it, this message translates to:
  /// **'Deve essere diversa da quella attuale'**
  String get changePwdMustDiffer;

  /// No description provided for @changePwdSubmit.
  ///
  /// In it, this message translates to:
  /// **'Cambia'**
  String get changePwdSubmit;

  /// No description provided for @changePwdLogoutWarning.
  ///
  /// In it, this message translates to:
  /// **'Dopo il cambio password verrai disconnesso e dovrai accedere di nuovo.'**
  String get changePwdLogoutWarning;

  /// No description provided for @dangerZoneTitle.
  ///
  /// In it, this message translates to:
  /// **'Zona pericolosa'**
  String get dangerZoneTitle;

  /// No description provided for @deleteAccountHint.
  ///
  /// In it, this message translates to:
  /// **'La cancellazione è definitiva: vengono rimossi profilo, tutte le schede, condivisioni, cronologia tiri.'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountButton.
  ///
  /// In it, this message translates to:
  /// **'Elimina il mio account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare l\'account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In it, this message translates to:
  /// **'Questa azione è IRREVERSIBILE.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountBullets.
  ///
  /// In it, this message translates to:
  /// **'Verranno cancellati: il tuo profilo (email, username, avatar), tutte le schede personaggio con relativi ritratti, tutti i link di condivisione (chi ha il link non vedrà più nulla), la cronologia dei tiri di dado. L\'username e l\'email torneranno disponibili per altre registrazioni.'**
  String get deleteAccountBullets;

  /// No description provided for @deleteAccountTypeUsername.
  ///
  /// In it, this message translates to:
  /// **'Digita il tuo username ({username}) per confermare'**
  String deleteAccountTypeUsername(Object username);

  /// No description provided for @deleteAccountUsernameMismatch.
  ///
  /// In it, this message translates to:
  /// **'L\'username non coincide'**
  String get deleteAccountUsernameMismatch;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Password attuale'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountConfirmBtn.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente'**
  String get deleteAccountConfirmBtn;

  /// No description provided for @deleteAccountDoneSnack.
  ///
  /// In it, this message translates to:
  /// **'Account eliminato. Arrivederci.'**
  String get deleteAccountDoneSnack;

  /// No description provided for @charactersEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna scheda ancora.'**
  String get charactersEmpty;

  /// No description provided for @charactersEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca \"+ Nuova scheda\" per crearne una.'**
  String get charactersEmptyHint;

  /// No description provided for @charactersNewBtn.
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda'**
  String get charactersNewBtn;

  /// No description provided for @charactersNoName.
  ///
  /// In it, this message translates to:
  /// **'(senza nome)'**
  String get charactersNoName;

  /// No description provided for @charactersImportTooltip.
  ///
  /// In it, this message translates to:
  /// **'Importa…'**
  String get charactersImportTooltip;

  /// No description provided for @charactersImportJson.
  ///
  /// In it, this message translates to:
  /// **'Importa JSON proprietario'**
  String get charactersImportJson;

  /// No description provided for @charactersImportFoundry.
  ///
  /// In it, this message translates to:
  /// **'Importa FoundryVTT (dnd5e)'**
  String get charactersImportFoundry;

  /// No description provided for @charactersActionsTooltip.
  ///
  /// In it, this message translates to:
  /// **'Azioni'**
  String get charactersActionsTooltip;

  /// No description provided for @charactersActionRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get charactersActionRename;

  /// No description provided for @charactersActionDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Duplica'**
  String get charactersActionDuplicate;

  /// No description provided for @charactersActionExportJson.
  ///
  /// In it, this message translates to:
  /// **'Esporta JSON'**
  String get charactersActionExportJson;

  /// No description provided for @charactersActionExportFoundry.
  ///
  /// In it, this message translates to:
  /// **'Esporta Foundry'**
  String get charactersActionExportFoundry;

  /// No description provided for @charactersActionExportPdf.
  ///
  /// In it, this message translates to:
  /// **'Esporta PDF'**
  String get charactersActionExportPdf;

  /// No description provided for @charactersActionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get charactersActionDelete;

  /// No description provided for @charactersRenameDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Rinomina scheda'**
  String get charactersRenameDialogTitle;

  /// No description provided for @charactersRenameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nuovo nome'**
  String get charactersRenameLabel;

  /// No description provided for @charactersDeleteDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la scheda?'**
  String get charactersDeleteDialogTitle;

  /// No description provided for @charactersDeleteDialogBody.
  ///
  /// In it, this message translates to:
  /// **'Questa azione non si può annullare.\nScheda: {name}'**
  String charactersDeleteDialogBody(Object name);

  /// No description provided for @charactersLevelLabel.
  ///
  /// In it, this message translates to:
  /// **'Livello {n}'**
  String charactersLevelLabel(Object n);

  /// No description provided for @charactersSnackRenamed.
  ///
  /// In it, this message translates to:
  /// **'Scheda rinominata'**
  String get charactersSnackRenamed;

  /// No description provided for @charactersSnackDuplicated.
  ///
  /// In it, this message translates to:
  /// **'Scheda duplicata'**
  String get charactersSnackDuplicated;

  /// No description provided for @charactersSnackDeleted.
  ///
  /// In it, this message translates to:
  /// **'Scheda eliminata'**
  String get charactersSnackDeleted;

  /// No description provided for @charactersSnackExported.
  ///
  /// In it, this message translates to:
  /// **'Esportata: {filename}'**
  String charactersSnackExported(Object filename);

  /// No description provided for @charactersSnackExportedFoundry.
  ///
  /// In it, this message translates to:
  /// **'Esportata per Foundry (best-effort): {filename}'**
  String charactersSnackExportedFoundry(Object filename);

  /// No description provided for @charactersSnackExportedPdf.
  ///
  /// In it, this message translates to:
  /// **'Esportato PDF: {filename}'**
  String charactersSnackExportedPdf(Object filename);

  /// No description provided for @charactersSnackImportedJson.
  ///
  /// In it, this message translates to:
  /// **'Scheda importata'**
  String get charactersSnackImportedJson;

  /// No description provided for @charactersSnackImportedFoundry.
  ///
  /// In it, this message translates to:
  /// **'Scheda importata da Foundry (best-effort, controlla i dati)'**
  String get charactersSnackImportedFoundry;

  /// No description provided for @charactersErrorCreate.
  ///
  /// In it, this message translates to:
  /// **'Errore creazione: {message}'**
  String charactersErrorCreate(Object message);

  /// No description provided for @charactersErrorImport.
  ///
  /// In it, this message translates to:
  /// **'Errore import: {message}'**
  String charactersErrorImport(Object message);

  /// No description provided for @charactersErrorJsonInvalid.
  ///
  /// In it, this message translates to:
  /// **'JSON non valido: {message}'**
  String charactersErrorJsonInvalid(Object message);

  /// No description provided for @charactersErrorJsonNotObject.
  ///
  /// In it, this message translates to:
  /// **'Il file non contiene un oggetto JSON'**
  String get charactersErrorJsonNotObject;

  /// No description provided for @editorTabAnagrafica.
  ///
  /// In it, this message translates to:
  /// **'Anagrafica'**
  String get editorTabAnagrafica;

  /// No description provided for @editorTabStats.
  ///
  /// In it, this message translates to:
  /// **'Stats'**
  String get editorTabStats;

  /// No description provided for @editorTabAbilities.
  ///
  /// In it, this message translates to:
  /// **'Abilità'**
  String get editorTabAbilities;

  /// No description provided for @editorTabCombat.
  ///
  /// In it, this message translates to:
  /// **'Combat'**
  String get editorTabCombat;

  /// No description provided for @editorTabSpells.
  ///
  /// In it, this message translates to:
  /// **'Incantesimi'**
  String get editorTabSpells;

  /// No description provided for @editorTabEquip.
  ///
  /// In it, this message translates to:
  /// **'Equip'**
  String get editorTabEquip;

  /// No description provided for @editorTabTraits.
  ///
  /// In it, this message translates to:
  /// **'Tratti'**
  String get editorTabTraits;

  /// No description provided for @editorTabNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get editorTabNotes;

  /// No description provided for @autosaveIdle.
  ///
  /// In it, this message translates to:
  /// **'Modifiche salvate automaticamente'**
  String get autosaveIdle;

  /// No description provided for @autosaveSaving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get autosaveSaving;

  /// No description provided for @autosaveSavedAt.
  ///
  /// In it, this message translates to:
  /// **'Salvato alle {time}'**
  String autosaveSavedAt(Object time);

  /// No description provided for @autosaveError.
  ///
  /// In it, this message translates to:
  /// **'Errore: {message}'**
  String autosaveError(Object message);

  /// No description provided for @adminTitle.
  ///
  /// In it, this message translates to:
  /// **'Pannello admin'**
  String get adminTitle;

  /// No description provided for @adminSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca per email, username o nome'**
  String get adminSearchHint;

  /// No description provided for @adminColEmail.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get adminColEmail;

  /// No description provided for @adminColUsername.
  ///
  /// In it, this message translates to:
  /// **'Username'**
  String get adminColUsername;

  /// No description provided for @adminColDisplay.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get adminColDisplay;

  /// No description provided for @adminColTier.
  ///
  /// In it, this message translates to:
  /// **'Piano'**
  String get adminColTier;

  /// No description provided for @adminColRoles.
  ///
  /// In it, this message translates to:
  /// **'Ruoli'**
  String get adminColRoles;

  /// No description provided for @adminColCreated.
  ///
  /// In it, this message translates to:
  /// **'Registrato'**
  String get adminColCreated;

  /// No description provided for @adminColActions.
  ///
  /// In it, this message translates to:
  /// **'Azioni'**
  String get adminColActions;

  /// No description provided for @adminTierFree.
  ///
  /// In it, this message translates to:
  /// **'Free'**
  String get adminTierFree;

  /// No description provided for @adminTierPremium.
  ///
  /// In it, this message translates to:
  /// **'Premium'**
  String get adminTierPremium;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In it, this message translates to:
  /// **'ADMIN'**
  String get adminRoleAdmin;

  /// No description provided for @adminActionGrant.
  ///
  /// In it, this message translates to:
  /// **'Regala Premium'**
  String get adminActionGrant;

  /// No description provided for @adminActionRevoke.
  ///
  /// In it, this message translates to:
  /// **'Revoca Premium'**
  String get adminActionRevoke;

  /// No description provided for @adminActionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina account'**
  String get adminActionDelete;

  /// No description provided for @adminDeleteConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Conferma eliminazione'**
  String get adminDeleteConfirmTitle;

  /// No description provided for @adminDeleteConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Eliminerai definitivamente l\'account {email} con tutti i suoi dati. Procedo?'**
  String adminDeleteConfirmBody(Object email);

  /// No description provided for @adminDeleteConfirmYes.
  ///
  /// In it, this message translates to:
  /// **'Sì, elimina'**
  String get adminDeleteConfirmYes;

  /// No description provided for @adminDeleteConfirmNo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get adminDeleteConfirmNo;

  /// No description provided for @adminSnackGranted.
  ///
  /// In it, this message translates to:
  /// **'Premium concesso a {email}'**
  String adminSnackGranted(Object email);

  /// No description provided for @adminSnackRevoked.
  ///
  /// In it, this message translates to:
  /// **'Premium revocato a {email}'**
  String adminSnackRevoked(Object email);

  /// No description provided for @adminSnackDeleted.
  ///
  /// In it, this message translates to:
  /// **'Account {email} eliminato'**
  String adminSnackDeleted(Object email);

  /// No description provided for @adminError.
  ///
  /// In it, this message translates to:
  /// **'Errore: {message}'**
  String adminError(Object message);

  /// No description provided for @adminPaginationOf.
  ///
  /// In it, this message translates to:
  /// **'{from}–{to} di {total}'**
  String adminPaginationOf(Object from, Object to, Object total);

  /// No description provided for @adminEmptyList.
  ///
  /// In it, this message translates to:
  /// **'Nessun utente trovato'**
  String get adminEmptyList;

  /// No description provided for @adminMenuLink.
  ///
  /// In it, this message translates to:
  /// **'Pannello admin'**
  String get adminMenuLink;

  /// No description provided for @paywallTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano gratuito al limite'**
  String get paywallTitle;

  /// No description provided for @paywallBody.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il numero massimo di schede del piano gratuito. Premium toglie il limite e le pubblicità sull\'app mobile per sempre.'**
  String get paywallBody;

  /// No description provided for @paywallPriceHint.
  ///
  /// In it, this message translates to:
  /// **'Pagamento sicuro Stripe. Lifetime: paghi una volta, è tuo per sempre.'**
  String get paywallPriceHint;

  /// No description provided for @paywallPriceHintComingSoon.
  ///
  /// In it, this message translates to:
  /// **'Pagamenti presto disponibili — il bottone diventerà attivo a breve.'**
  String get paywallPriceHintComingSoon;

  /// No description provided for @paywallBuy.
  ///
  /// In it, this message translates to:
  /// **'Acquista 4,99€'**
  String get paywallBuy;

  /// No description provided for @paywallClose.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get paywallClose;

  /// No description provided for @billingAlreadyPremium.
  ///
  /// In it, this message translates to:
  /// **'Sei già Premium!'**
  String get billingAlreadyPremium;

  /// No description provided for @billingSuccessTitle.
  ///
  /// In it, this message translates to:
  /// **'Pagamento ricevuto'**
  String get billingSuccessTitle;

  /// No description provided for @billingSuccessWaiting.
  ///
  /// In it, this message translates to:
  /// **'Stiamo confermando il tuo pagamento…'**
  String get billingSuccessWaiting;

  /// No description provided for @billingSuccessPollAttempt.
  ///
  /// In it, this message translates to:
  /// **'Attendi qualche secondo'**
  String get billingSuccessPollAttempt;

  /// No description provided for @billingSuccessConfirmedTitle.
  ///
  /// In it, this message translates to:
  /// **'Sei Premium!'**
  String get billingSuccessConfirmedTitle;

  /// No description provided for @billingSuccessConfirmedBody.
  ///
  /// In it, this message translates to:
  /// **'Ora puoi creare schede senza limiti.'**
  String get billingSuccessConfirmedBody;

  /// No description provided for @billingSuccessCtaCharacters.
  ///
  /// In it, this message translates to:
  /// **'Vai alle schede'**
  String get billingSuccessCtaCharacters;

  /// No description provided for @billingSuccessPendingTitle.
  ///
  /// In it, this message translates to:
  /// **'Pagamento in elaborazione'**
  String get billingSuccessPendingTitle;

  /// No description provided for @billingSuccessPendingBody.
  ///
  /// In it, this message translates to:
  /// **'Il pagamento sta arrivando ai nostri server. Ricontrolla tra qualche minuto: l\'acquisto è andato a buon fine, il tuo account verrà aggiornato a breve.'**
  String get billingSuccessPendingBody;

  /// No description provided for @billingSuccessCtaHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get billingSuccessCtaHome;

  /// No description provided for @billingCancelTitle.
  ///
  /// In it, this message translates to:
  /// **'Pagamento annullato'**
  String get billingCancelTitle;

  /// No description provided for @billingCancelHeading.
  ///
  /// In it, this message translates to:
  /// **'Non hai completato il pagamento'**
  String get billingCancelHeading;

  /// No description provided for @billingCancelBody.
  ///
  /// In it, this message translates to:
  /// **'Niente è stato addebitato. Puoi riprovare in qualsiasi momento dal paywall.'**
  String get billingCancelBody;

  /// No description provided for @billingCancelCtaHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get billingCancelCtaHome;

  /// No description provided for @aboutSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get aboutSectionTitle;

  /// No description provided for @aboutPlanFree.
  ///
  /// In it, this message translates to:
  /// **'Piano attuale: Gratuito (1 scheda)'**
  String get aboutPlanFree;

  /// No description provided for @aboutPlanPremium.
  ///
  /// In it, this message translates to:
  /// **'Piano attuale: Premium'**
  String get aboutPlanPremium;

  /// No description provided for @aboutPremiumComing.
  ///
  /// In it, this message translates to:
  /// **'Premium 4,99€ una tantum sarà disponibile presto: rimuove il limite delle schede e le pubblicità sull\'app mobile.'**
  String get aboutPremiumComing;

  /// No description provided for @aboutSrdCredit.
  ///
  /// In it, this message translates to:
  /// **'I dati degli incantesimi derivano dal D&D 5.1 SRD (CC BY 4.0) di Wizards of the Coast. Questa app non è affiliata né approvata da Wizards of the Coast.'**
  String get aboutSrdCredit;

  /// No description provided for @sheetSectionAbilities.
  ///
  /// In it, this message translates to:
  /// **'Caratteristiche'**
  String get sheetSectionAbilities;

  /// No description provided for @sheetSectionSavesSkills.
  ///
  /// In it, this message translates to:
  /// **'Tiri salvezza & abilità'**
  String get sheetSectionSavesSkills;

  /// No description provided for @sheetSectionCombat.
  ///
  /// In it, this message translates to:
  /// **'Combattimento'**
  String get sheetSectionCombat;

  /// No description provided for @sheetSectionSpells.
  ///
  /// In it, this message translates to:
  /// **'Incantesimi'**
  String get sheetSectionSpells;

  /// No description provided for @sheetSectionEquipment.
  ///
  /// In it, this message translates to:
  /// **'Equipaggiamento'**
  String get sheetSectionEquipment;

  /// No description provided for @sheetSectionTraits.
  ///
  /// In it, this message translates to:
  /// **'Tratti'**
  String get sheetSectionTraits;

  /// No description provided for @sheetSectionNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get sheetSectionNotes;

  /// No description provided for @sheetHeaderBackground.
  ///
  /// In it, this message translates to:
  /// **'Background'**
  String get sheetHeaderBackground;

  /// No description provided for @sheetHeaderAlignment.
  ///
  /// In it, this message translates to:
  /// **'Allineamento'**
  String get sheetHeaderAlignment;

  /// No description provided for @sheetHpLabel.
  ///
  /// In it, this message translates to:
  /// **'HP'**
  String get sheetHpLabel;

  /// No description provided for @sheetAbilityStr.
  ///
  /// In it, this message translates to:
  /// **'Forza'**
  String get sheetAbilityStr;

  /// No description provided for @sheetAbilityDex.
  ///
  /// In it, this message translates to:
  /// **'Destrezza'**
  String get sheetAbilityDex;

  /// No description provided for @sheetAbilityCon.
  ///
  /// In it, this message translates to:
  /// **'Costituzione'**
  String get sheetAbilityCon;

  /// No description provided for @sheetAbilityInt.
  ///
  /// In it, this message translates to:
  /// **'Intelligenza'**
  String get sheetAbilityInt;

  /// No description provided for @sheetAbilityWis.
  ///
  /// In it, this message translates to:
  /// **'Saggezza'**
  String get sheetAbilityWis;

  /// No description provided for @sheetAbilityCha.
  ///
  /// In it, this message translates to:
  /// **'Carisma'**
  String get sheetAbilityCha;

  /// No description provided for @sheetSavingThrowsLabel.
  ///
  /// In it, this message translates to:
  /// **'Tiri salvezza'**
  String get sheetSavingThrowsLabel;

  /// No description provided for @sheetSkillsLabel.
  ///
  /// In it, this message translates to:
  /// **'Abilità'**
  String get sheetSkillsLabel;

  /// No description provided for @sheetCombatAc.
  ///
  /// In it, this message translates to:
  /// **'Classe Armatura'**
  String get sheetCombatAc;

  /// No description provided for @sheetCombatInitiative.
  ///
  /// In it, this message translates to:
  /// **'Iniziativa'**
  String get sheetCombatInitiative;

  /// No description provided for @sheetCombatSpeed.
  ///
  /// In it, this message translates to:
  /// **'Velocità'**
  String get sheetCombatSpeed;

  /// No description provided for @sheetCombatProfBonus.
  ///
  /// In it, this message translates to:
  /// **'Bonus comp.'**
  String get sheetCombatProfBonus;

  /// No description provided for @sheetCombatHitDice.
  ///
  /// In it, this message translates to:
  /// **'Dadi vita'**
  String get sheetCombatHitDice;

  /// No description provided for @sheetCombatDeathSaves.
  ///
  /// In it, this message translates to:
  /// **'TS morte'**
  String get sheetCombatDeathSaves;

  /// No description provided for @sheetCombatDeathSavesValue.
  ///
  /// In it, this message translates to:
  /// **'OK {s} / KO {f}'**
  String sheetCombatDeathSavesValue(Object s, Object f);

  /// No description provided for @sheetSpellsClass.
  ///
  /// In it, this message translates to:
  /// **'Classe'**
  String get sheetSpellsClass;

  /// No description provided for @sheetSpellsSaveDc.
  ///
  /// In it, this message translates to:
  /// **'CD TS'**
  String get sheetSpellsSaveDc;

  /// No description provided for @sheetSpellsAttackBonus.
  ///
  /// In it, this message translates to:
  /// **'Bonus attacco'**
  String get sheetSpellsAttackBonus;

  /// No description provided for @sheetSpellsSlotsByLevel.
  ///
  /// In it, this message translates to:
  /// **'Slot per livello'**
  String get sheetSpellsSlotsByLevel;

  /// No description provided for @sheetSpellsKnown.
  ///
  /// In it, this message translates to:
  /// **'Incantesimi conosciuti'**
  String get sheetSpellsKnown;

  /// No description provided for @sheetSpellCantrip.
  ///
  /// In it, this message translates to:
  /// **'trucchetto'**
  String get sheetSpellCantrip;

  /// No description provided for @sheetSpellLevelShort.
  ///
  /// In it, this message translates to:
  /// **'Liv {n}'**
  String sheetSpellLevelShort(Object n);

  /// No description provided for @sheetSpellAlwaysPrepared.
  ///
  /// In it, this message translates to:
  /// **'Sempre preparato'**
  String get sheetSpellAlwaysPrepared;

  /// No description provided for @sheetSpellPrepared.
  ///
  /// In it, this message translates to:
  /// **'Preparato'**
  String get sheetSpellPrepared;

  /// No description provided for @sheetEquipmentInventory.
  ///
  /// In it, this message translates to:
  /// **'Inventario'**
  String get sheetEquipmentInventory;

  /// No description provided for @sheetTraitsPersonality.
  ///
  /// In it, this message translates to:
  /// **'Tratti caratteriali'**
  String get sheetTraitsPersonality;

  /// No description provided for @sheetTraitsIdeals.
  ///
  /// In it, this message translates to:
  /// **'Ideali'**
  String get sheetTraitsIdeals;

  /// No description provided for @sheetTraitsBonds.
  ///
  /// In it, this message translates to:
  /// **'Legami'**
  String get sheetTraitsBonds;

  /// No description provided for @sheetTraitsFlaws.
  ///
  /// In it, this message translates to:
  /// **'Difetti'**
  String get sheetTraitsFlaws;

  /// No description provided for @sheetTraitsLanguages.
  ///
  /// In it, this message translates to:
  /// **'Lingue'**
  String get sheetTraitsLanguages;

  /// No description provided for @sheetTraitsArmor.
  ///
  /// In it, this message translates to:
  /// **'Armature'**
  String get sheetTraitsArmor;

  /// No description provided for @sheetTraitsWeapons.
  ///
  /// In it, this message translates to:
  /// **'Armi'**
  String get sheetTraitsWeapons;

  /// No description provided for @sheetTraitsTools.
  ///
  /// In it, this message translates to:
  /// **'Strumenti'**
  String get sheetTraitsTools;

  /// No description provided for @sheetTraitsFeatures.
  ///
  /// In it, this message translates to:
  /// **'Privilegi & tratti'**
  String get sheetTraitsFeatures;

  /// No description provided for @sheetNotesBackstory.
  ///
  /// In it, this message translates to:
  /// **'Background'**
  String get sheetNotesBackstory;

  /// No description provided for @sheetNotesAllies.
  ///
  /// In it, this message translates to:
  /// **'Alleati & organizzazioni'**
  String get sheetNotesAllies;

  /// No description provided for @sheetNotesSymbol.
  ///
  /// In it, this message translates to:
  /// **'Simbolo'**
  String get sheetNotesSymbol;

  /// No description provided for @sheetNotesPhysical.
  ///
  /// In it, this message translates to:
  /// **'Aspetto fisico'**
  String get sheetNotesPhysical;

  /// No description provided for @sheetNotesNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get sheetNotesNotes;

  /// No description provided for @sharedInvalidLink.
  ///
  /// In it, this message translates to:
  /// **'Link non valido o revocato.'**
  String get sharedInvalidLink;

  /// No description provided for @shareDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Condividi scheda'**
  String get shareDialogTitle;

  /// No description provided for @shareDialogIntro.
  ///
  /// In it, this message translates to:
  /// **'Genera un link pubblico read-only per mostrare la scheda al DM. Chiunque conosca il link può vederla (no login). Puoi revocarlo in ogni momento.'**
  String get shareDialogIntro;

  /// No description provided for @shareDialogPublicLink.
  ///
  /// In it, this message translates to:
  /// **'Link pubblico:'**
  String get shareDialogPublicLink;

  /// No description provided for @shareDialogCopyHint.
  ///
  /// In it, this message translates to:
  /// **'Copia questo link ora — non sarà più visualizzabile dopo aver chiuso il dialog.'**
  String get shareDialogCopyHint;

  /// No description provided for @shareDialogCopiedSnack.
  ///
  /// In it, this message translates to:
  /// **'Link copiato'**
  String get shareDialogCopiedSnack;

  /// No description provided for @shareDialogCopy.
  ///
  /// In it, this message translates to:
  /// **'Copia'**
  String get shareDialogCopy;

  /// No description provided for @shareDialogRevoke.
  ///
  /// In it, this message translates to:
  /// **'Revoca'**
  String get shareDialogRevoke;

  /// No description provided for @shareDialogActive.
  ///
  /// In it, this message translates to:
  /// **'Link attivo'**
  String get shareDialogActive;

  /// No description provided for @shareDialogGeneratedAt.
  ///
  /// In it, this message translates to:
  /// **'Generato il {date}.'**
  String shareDialogGeneratedAt(Object date);

  /// No description provided for @shareDialogLostHint.
  ///
  /// In it, this message translates to:
  /// **'Il link in chiaro non è recuperabile. Se l\'hai perso, rigenera un nuovo link (il vecchio viene revocato automaticamente).'**
  String get shareDialogLostHint;

  /// No description provided for @shareDialogRegenerate.
  ///
  /// In it, this message translates to:
  /// **'Rigenera link'**
  String get shareDialogRegenerate;

  /// No description provided for @shareDialogGenerate.
  ///
  /// In it, this message translates to:
  /// **'Genera link di condivisione'**
  String get shareDialogGenerate;

  /// No description provided for @customSpellDialogTitleNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo incantesimo custom'**
  String get customSpellDialogTitleNew;

  /// No description provided for @customSpellDialogTitleEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica incantesimo'**
  String get customSpellDialogTitleEdit;

  /// No description provided for @customSpellFieldName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get customSpellFieldName;

  /// No description provided for @customSpellFieldLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello'**
  String get customSpellFieldLevel;

  /// No description provided for @customSpellFieldLevelHelper.
  ///
  /// In it, this message translates to:
  /// **'0 = trucchetto'**
  String get customSpellFieldLevelHelper;

  /// No description provided for @customSpellFieldSchool.
  ///
  /// In it, this message translates to:
  /// **'Scuola'**
  String get customSpellFieldSchool;

  /// No description provided for @customSpellFieldCastingTime.
  ///
  /// In it, this message translates to:
  /// **'Casting time'**
  String get customSpellFieldCastingTime;

  /// No description provided for @customSpellHintCastingTime.
  ///
  /// In it, this message translates to:
  /// **'es. 1 action'**
  String get customSpellHintCastingTime;

  /// No description provided for @customSpellFieldRange.
  ///
  /// In it, this message translates to:
  /// **'Range'**
  String get customSpellFieldRange;

  /// No description provided for @customSpellHintRange.
  ///
  /// In it, this message translates to:
  /// **'es. 60 feet'**
  String get customSpellHintRange;

  /// No description provided for @customSpellFieldDuration.
  ///
  /// In it, this message translates to:
  /// **'Duration'**
  String get customSpellFieldDuration;

  /// No description provided for @customSpellHintDuration.
  ///
  /// In it, this message translates to:
  /// **'es. Instantaneous, 1 minute'**
  String get customSpellHintDuration;

  /// No description provided for @customSpellComponents.
  ///
  /// In it, this message translates to:
  /// **'Componenti'**
  String get customSpellComponents;

  /// No description provided for @customSpellMaterials.
  ///
  /// In it, this message translates to:
  /// **'Materiali'**
  String get customSpellMaterials;

  /// No description provided for @customSpellMaterialsHint.
  ///
  /// In it, this message translates to:
  /// **'es. una piuma di phoenix'**
  String get customSpellMaterialsHint;

  /// No description provided for @customSpellConcentration.
  ///
  /// In it, this message translates to:
  /// **'Concentration'**
  String get customSpellConcentration;

  /// No description provided for @customSpellRitual.
  ///
  /// In it, this message translates to:
  /// **'Ritual'**
  String get customSpellRitual;

  /// No description provided for @customSpellClasses.
  ///
  /// In it, this message translates to:
  /// **'Classi'**
  String get customSpellClasses;

  /// No description provided for @customSpellDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get customSpellDescription;

  /// No description provided for @customSpellHigherLevels.
  ///
  /// In it, this message translates to:
  /// **'At Higher Levels'**
  String get customSpellHigherLevels;

  /// No description provided for @abilityShortStr.
  ///
  /// In it, this message translates to:
  /// **'FOR'**
  String get abilityShortStr;

  /// No description provided for @abilityShortDex.
  ///
  /// In it, this message translates to:
  /// **'DES'**
  String get abilityShortDex;

  /// No description provided for @abilityShortCon.
  ///
  /// In it, this message translates to:
  /// **'COS'**
  String get abilityShortCon;

  /// No description provided for @abilityShortInt.
  ///
  /// In it, this message translates to:
  /// **'INT'**
  String get abilityShortInt;

  /// No description provided for @abilityShortWis.
  ///
  /// In it, this message translates to:
  /// **'SAG'**
  String get abilityShortWis;

  /// No description provided for @abilityShortCha.
  ///
  /// In it, this message translates to:
  /// **'CAR'**
  String get abilityShortCha;

  /// No description provided for @skillAcrobatics.
  ///
  /// In it, this message translates to:
  /// **'Acrobazia'**
  String get skillAcrobatics;

  /// No description provided for @skillAnimalHandling.
  ///
  /// In it, this message translates to:
  /// **'Addestrare animali'**
  String get skillAnimalHandling;

  /// No description provided for @skillArcana.
  ///
  /// In it, this message translates to:
  /// **'Arcano'**
  String get skillArcana;

  /// No description provided for @skillAthletics.
  ///
  /// In it, this message translates to:
  /// **'Atletica'**
  String get skillAthletics;

  /// No description provided for @skillDeception.
  ///
  /// In it, this message translates to:
  /// **'Inganno'**
  String get skillDeception;

  /// No description provided for @skillHistory.
  ///
  /// In it, this message translates to:
  /// **'Storia'**
  String get skillHistory;

  /// No description provided for @skillInsight.
  ///
  /// In it, this message translates to:
  /// **'Intuizione'**
  String get skillInsight;

  /// No description provided for @skillIntimidation.
  ///
  /// In it, this message translates to:
  /// **'Intimidire'**
  String get skillIntimidation;

  /// No description provided for @skillInvestigation.
  ///
  /// In it, this message translates to:
  /// **'Indagare'**
  String get skillInvestigation;

  /// No description provided for @skillMedicine.
  ///
  /// In it, this message translates to:
  /// **'Medicina'**
  String get skillMedicine;

  /// No description provided for @skillNature.
  ///
  /// In it, this message translates to:
  /// **'Natura'**
  String get skillNature;

  /// No description provided for @skillPerception.
  ///
  /// In it, this message translates to:
  /// **'Percezione'**
  String get skillPerception;

  /// No description provided for @skillPerformance.
  ///
  /// In it, this message translates to:
  /// **'Intrattenere'**
  String get skillPerformance;

  /// No description provided for @skillPersuasion.
  ///
  /// In it, this message translates to:
  /// **'Persuasione'**
  String get skillPersuasion;

  /// No description provided for @skillReligion.
  ///
  /// In it, this message translates to:
  /// **'Religione'**
  String get skillReligion;

  /// No description provided for @skillSleightOfHand.
  ///
  /// In it, this message translates to:
  /// **'Rapidità di mano'**
  String get skillSleightOfHand;

  /// No description provided for @skillStealth.
  ///
  /// In it, this message translates to:
  /// **'Furtività'**
  String get skillStealth;

  /// No description provided for @skillSurvival.
  ///
  /// In it, this message translates to:
  /// **'Sopravvivenza'**
  String get skillSurvival;

  /// No description provided for @conditionBlinded.
  ///
  /// In it, this message translates to:
  /// **'Accecato'**
  String get conditionBlinded;

  /// No description provided for @conditionBlindedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura accecata non può vedere e fallisce automaticamente qualsiasi prova di caratteristica che richieda la vista. I tiri per colpire contro di essa hanno vantaggio, i suoi tiri per colpire hanno svantaggio.'**
  String get conditionBlindedDesc;

  /// No description provided for @conditionCharmed.
  ///
  /// In it, this message translates to:
  /// **'Affascinato'**
  String get conditionCharmed;

  /// No description provided for @conditionCharmedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura affascinata non può attaccare l\'incantatore né bersagliarlo con abilità o effetti magici dannosi. L\'incantatore ha vantaggio sulle prove di caratteristica sociali contro di essa.'**
  String get conditionCharmedDesc;

  /// No description provided for @conditionDeafened.
  ///
  /// In it, this message translates to:
  /// **'Assordato'**
  String get conditionDeafened;

  /// No description provided for @conditionDeafenedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura assordata non può udire e fallisce automaticamente qualsiasi prova di caratteristica che richieda l\'udito.'**
  String get conditionDeafenedDesc;

  /// No description provided for @conditionFrightened.
  ///
  /// In it, this message translates to:
  /// **'Spaventato'**
  String get conditionFrightened;

  /// No description provided for @conditionFrightenedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura spaventata ha svantaggio a prove di caratteristica e tiri per colpire mentre la fonte della paura è nella sua linea di vista. Non può volontariamente avvicinarsi alla fonte della paura.'**
  String get conditionFrightenedDesc;

  /// No description provided for @conditionGrappled.
  ///
  /// In it, this message translates to:
  /// **'Afferrato'**
  String get conditionGrappled;

  /// No description provided for @conditionGrappledDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura afferrata ha velocità 0 e non può beneficiare di alcun bonus alla velocità. La condizione termina se chi afferra è incapacitato o se la creatura viene spostata fuori dalla portata.'**
  String get conditionGrappledDesc;

  /// No description provided for @conditionIncapacitated.
  ///
  /// In it, this message translates to:
  /// **'Incapacitato'**
  String get conditionIncapacitated;

  /// No description provided for @conditionIncapacitatedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura incapacitata non può eseguire azioni né reazioni.'**
  String get conditionIncapacitatedDesc;

  /// No description provided for @conditionInvisible.
  ///
  /// In it, this message translates to:
  /// **'Invisibile'**
  String get conditionInvisible;

  /// No description provided for @conditionInvisibleDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura invisibile è impossibile da vedere senza l\'aiuto di magia o senso speciale. Per nascondersi è considerata pesantemente nascosta. I tiri per colpire contro di essa hanno svantaggio, i suoi tiri per colpire hanno vantaggio.'**
  String get conditionInvisibleDesc;

  /// No description provided for @conditionParalyzed.
  ///
  /// In it, this message translates to:
  /// **'Paralizzato'**
  String get conditionParalyzed;

  /// No description provided for @conditionParalyzedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura paralizzata è incapacitata, non può muoversi né parlare. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio. Qualsiasi colpo entro 1,5 m è un colpo critico.'**
  String get conditionParalyzedDesc;

  /// No description provided for @conditionPetrified.
  ///
  /// In it, this message translates to:
  /// **'Pietrificato'**
  String get conditionPetrified;

  /// No description provided for @conditionPetrifiedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura pietrificata è trasformata in solida sostanza inanimata. È incapacitata, peso x10, non invecchia. I tiri per colpire contro di essa hanno vantaggio. Resistenza a tutti i danni, immune a veleno e malattia.'**
  String get conditionPetrifiedDesc;

  /// No description provided for @conditionPoisoned.
  ///
  /// In it, this message translates to:
  /// **'Avvelenato'**
  String get conditionPoisoned;

  /// No description provided for @conditionPoisonedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura avvelenata ha svantaggio a tiri per colpire e prove di caratteristica.'**
  String get conditionPoisonedDesc;

  /// No description provided for @conditionProne.
  ///
  /// In it, this message translates to:
  /// **'Prono'**
  String get conditionProne;

  /// No description provided for @conditionProneDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura prona può solo strisciare. Ha svantaggio ai tiri per colpire. I tiri per colpire contro di essa hanno vantaggio se l\'attaccante è entro 1,5 m, svantaggio altrimenti.'**
  String get conditionProneDesc;

  /// No description provided for @conditionRestrained.
  ///
  /// In it, this message translates to:
  /// **'Trattenuto'**
  String get conditionRestrained;

  /// No description provided for @conditionRestrainedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura trattenuta ha velocità 0 e non può beneficiare di alcun bonus alla velocità. I tiri per colpire contro di essa hanno vantaggio, i suoi tiri per colpire hanno svantaggio. Svantaggio ai TS di Destrezza.'**
  String get conditionRestrainedDesc;

  /// No description provided for @conditionStunned.
  ///
  /// In it, this message translates to:
  /// **'Stordito'**
  String get conditionStunned;

  /// No description provided for @conditionStunnedDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura stordita è incapacitata, non può muoversi e può solo parlare a fatica. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio.'**
  String get conditionStunnedDesc;

  /// No description provided for @conditionUnconscious.
  ///
  /// In it, this message translates to:
  /// **'Privo di sensi'**
  String get conditionUnconscious;

  /// No description provided for @conditionUnconsciousDesc.
  ///
  /// In it, this message translates to:
  /// **'Una creatura priva di sensi è incapacitata, non può muoversi né parlare, e ignora l\'ambiente. Lascia cadere ciò che tiene e cade prona. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio. Qualsiasi colpo entro 1,5 m è un colpo critico.'**
  String get conditionUnconsciousDesc;

  /// No description provided for @conditionExhaustion.
  ///
  /// In it, this message translates to:
  /// **'Esausto'**
  String get conditionExhaustion;

  /// No description provided for @conditionExhaustionDesc.
  ///
  /// In it, this message translates to:
  /// **'L\'esaurimento ha 6 livelli con effetti cumulativi. Livello 1: svantaggio alle prove di caratteristica. Livello 2: velocità dimezzata. Livello 3: svantaggio ai tiri per colpire e TS. Livello 4: HP massimi dimezzati. Livello 5: velocità 0. Livello 6: morte.'**
  String get conditionExhaustionDesc;

  /// No description provided for @diceTitle.
  ///
  /// In it, this message translates to:
  /// **'Dice roller'**
  String get diceTitle;

  /// No description provided for @diceFormulaLabel.
  ///
  /// In it, this message translates to:
  /// **'Formula (es. 1d20+5, 3d6+1d4)'**
  String get diceFormulaLabel;

  /// No description provided for @diceAdvantage.
  ///
  /// In it, this message translates to:
  /// **'Vantaggio'**
  String get diceAdvantage;

  /// No description provided for @diceDisadvantage.
  ///
  /// In it, this message translates to:
  /// **'Svantaggio'**
  String get diceDisadvantage;

  /// No description provided for @diceRollButton.
  ///
  /// In it, this message translates to:
  /// **'Tira'**
  String get diceRollButton;

  /// No description provided for @diceHistory.
  ///
  /// In it, this message translates to:
  /// **'Cronologia'**
  String get diceHistory;

  /// No description provided for @diceClear.
  ///
  /// In it, this message translates to:
  /// **'Pulisci'**
  String get diceClear;

  /// No description provided for @diceNoRollsYet.
  ///
  /// In it, this message translates to:
  /// **'— nessun tiro ancora —'**
  String get diceNoRollsYet;

  /// No description provided for @diceNoOtherRolls.
  ///
  /// In it, this message translates to:
  /// **'— nessun altro tiro —'**
  String get diceNoOtherRolls;

  /// No description provided for @spellCatalogTitle.
  ///
  /// In it, this message translates to:
  /// **'Codex degli incantesimi'**
  String get spellCatalogTitle;

  /// No description provided for @spellCatalogResultsCount.
  String spellCatalogResultsCount(int shown, int total);

  /// No description provided for @spellPickerTitle.
  ///
  /// In it, this message translates to:
  /// **'Catalogo SRD'**
  String get spellPickerTitle;

  /// No description provided for @spellPickerSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca per nome (es. \"fire\")'**
  String get spellPickerSearchHint;

  /// No description provided for @spellFilterLevelHint.
  ///
  /// In it, this message translates to:
  /// **'Livello'**
  String get spellFilterLevelHint;

  /// No description provided for @spellFilterLevelAll.
  ///
  /// In it, this message translates to:
  /// **'Livello: tutti'**
  String get spellFilterLevelAll;

  /// No description provided for @spellFilterCantrips.
  ///
  /// In it, this message translates to:
  /// **'Trucchetti'**
  String get spellFilterCantrips;

  /// No description provided for @spellFilterLevelN.
  ///
  /// In it, this message translates to:
  /// **'Liv. {n}'**
  String spellFilterLevelN(Object n);

  /// No description provided for @spellFilterSchoolHint.
  ///
  /// In it, this message translates to:
  /// **'Scuola'**
  String get spellFilterSchoolHint;

  /// No description provided for @spellFilterSchoolAll.
  ///
  /// In it, this message translates to:
  /// **'Scuola: tutte'**
  String get spellFilterSchoolAll;

  /// No description provided for @spellFilterClassHint.
  ///
  /// In it, this message translates to:
  /// **'Classe'**
  String get spellFilterClassHint;

  /// No description provided for @spellFilterClassAll.
  ///
  /// In it, this message translates to:
  /// **'Classe: tutte'**
  String get spellFilterClassAll;

  /// No description provided for @spellFilterRitualOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo rituali'**
  String get spellFilterRitualOnly;

  /// No description provided for @spellFilterConcentrationOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo concentrazione'**
  String get spellFilterConcentrationOnly;

  /// No description provided for @spellPickerNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato'**
  String get spellPickerNoResults;

  /// No description provided for @spellPickerDetails.
  ///
  /// In it, this message translates to:
  /// **'Dettagli'**
  String get spellPickerDetails;

  /// No description provided for @spellPickerAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi alla scheda'**
  String get spellPickerAdd;

  /// No description provided for @editorToolbarShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi (link read-only)'**
  String get editorToolbarShare;

  /// No description provided for @editorPortraitChange.
  ///
  /// In it, this message translates to:
  /// **'Cambia ritratto'**
  String get editorPortraitChange;

  /// No description provided for @editorPortraitUpload.
  ///
  /// In it, this message translates to:
  /// **'Carica ritratto'**
  String get editorPortraitUpload;

  /// No description provided for @editorPortraitUpdatedSnack.
  ///
  /// In it, this message translates to:
  /// **'Ritratto aggiornato'**
  String get editorPortraitUpdatedSnack;

  /// No description provided for @editorPortraitRemovedSnack.
  ///
  /// In it, this message translates to:
  /// **'Ritratto rimosso'**
  String get editorPortraitRemovedSnack;

  /// No description provided for @autosaveFormInvalid.
  ///
  /// In it, this message translates to:
  /// **'Form non valido — non salvato'**
  String get autosaveFormInvalid;

  /// No description provided for @editorExitDirtyTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifiche non salvate'**
  String get editorExitDirtyTitle;

  /// No description provided for @editorExitDirtyBody.
  ///
  /// In it, this message translates to:
  /// **'Hai modifiche non salvate (alcuni campi non sono validi e non sono stati salvati). Uscire scartandole?'**
  String get editorExitDirtyBody;

  /// No description provided for @editorExitDirtyDiscard.
  ///
  /// In it, this message translates to:
  /// **'Esci e scarta'**
  String get editorExitDirtyDiscard;

  /// No description provided for @editorLayoutTitle.
  ///
  /// In it, this message translates to:
  /// **'Dashboard personalizzata'**
  String get editorLayoutTitle;

  /// No description provided for @editorLayoutOpenButton.
  ///
  /// In it, this message translates to:
  /// **'Modifica layout'**
  String get editorLayoutOpenButton;

  /// No description provided for @editorLayoutEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun widget. Aggiungine uno per iniziare a costruire la tua dashboard.'**
  String get editorLayoutEmpty;

  /// No description provided for @editorLayoutAddWidget.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi widget'**
  String get editorLayoutAddWidget;

  /// No description provided for @editorLayoutReset.
  ///
  /// In it, this message translates to:
  /// **'Ripristina default'**
  String get editorLayoutReset;

  /// No description provided for @editorLayoutSavedSnack.
  ///
  /// In it, this message translates to:
  /// **'Layout salvato'**
  String get editorLayoutSavedSnack;

  /// No description provided for @editorLayoutResetConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristinare il layout?'**
  String get editorLayoutResetConfirmTitle;

  /// No description provided for @editorLayoutResetConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Il tuo layout custom verrà eliminato e tornerai alla vista classica a tab.'**
  String get editorLayoutResetConfirmBody;

  /// No description provided for @editorLayoutResetConfirmYes.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get editorLayoutResetConfirmYes;

  /// No description provided for @editorLayoutRemoveWidget.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi widget'**
  String get editorLayoutRemoveWidget;

  /// No description provided for @editorLayoutBringForward.
  ///
  /// In it, this message translates to:
  /// **'Porta avanti'**
  String get editorLayoutBringForward;

  /// No description provided for @editorLayoutSendBackward.
  ///
  /// In it, this message translates to:
  /// **'Porta indietro'**
  String get editorLayoutSendBackward;

  /// No description provided for @editorLayoutWidgetHpTracker.
  ///
  /// In it, this message translates to:
  /// **'Tracker PF'**
  String get editorLayoutWidgetHpTracker;

  /// No description provided for @editorLayoutWidgetConditions.
  ///
  /// In it, this message translates to:
  /// **'Condizioni'**
  String get editorLayoutWidgetConditions;

  /// No description provided for @editorLayoutWidgetPortrait.
  ///
  /// In it, this message translates to:
  /// **'Ritratto'**
  String get editorLayoutWidgetPortrait;

  /// No description provided for @homeCustomDashboardBadge.
  ///
  /// In it, this message translates to:
  /// **'NUOVO'**
  String get homeCustomDashboardBadge;

  /// No description provided for @homeCustomDashboardTitle.
  ///
  /// In it, this message translates to:
  /// **'Dashboard personalizzata'**
  String get homeCustomDashboardTitle;

  /// No description provided for @homeCustomDashboardSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Costruisci la tua scheda con widget drag & drop — scegli cosa mostrare e dove.'**
  String get homeCustomDashboardSubtitle;

  /// No description provided for @homeCustomDashboardOpen.
  ///
  /// In it, this message translates to:
  /// **'Vai alle schede'**
  String get homeCustomDashboardOpen;

  /// No description provided for @charactersCardOpenClassic.
  ///
  /// In it, this message translates to:
  /// **'Vista classica'**
  String get charactersCardOpenClassic;

  /// No description provided for @charactersCardOpenLayout.
  ///
  /// In it, this message translates to:
  /// **'Layout personalizzato'**
  String get charactersCardOpenLayout;

  /// No description provided for @landingDashboardSpotlightBadge.
  ///
  /// In it, this message translates to:
  /// **'NUOVO'**
  String get landingDashboardSpotlightBadge;

  /// No description provided for @landingDashboardSpotlightTitle.
  ///
  /// In it, this message translates to:
  /// **'L\'atelier del Cronista'**
  String get landingDashboardSpotlightTitle;

  /// No description provided for @landingDashboardSpotlightDesc.
  ///
  /// In it, this message translates to:
  /// **'Costruisci la scheda come vuoi tu: trascina, ridimensiona e disponi i blocchi della pergamena del tuo eroe. Rendila davvero tua.'**
  String get landingDashboardSpotlightDesc;

  /// No description provided for @editorAnagraficaName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get editorAnagraficaName;

  /// No description provided for @editorAnagraficaLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello'**
  String get editorAnagraficaLevel;

  /// No description provided for @editorAnagraficaRace.
  ///
  /// In it, this message translates to:
  /// **'Razza'**
  String get editorAnagraficaRace;

  /// No description provided for @editorAnagraficaSubrace.
  ///
  /// In it, this message translates to:
  /// **'Sotto-razza'**
  String get editorAnagraficaSubrace;

  /// No description provided for @editorAnagraficaClass.
  ///
  /// In it, this message translates to:
  /// **'Classe'**
  String get editorAnagraficaClass;

  /// No description provided for @editorAnagraficaSubclass.
  ///
  /// In it, this message translates to:
  /// **'Sotto-classe'**
  String get editorAnagraficaSubclass;

  /// No description provided for @editorAnagraficaExperience.
  ///
  /// In it, this message translates to:
  /// **'Esperienza (XP)'**
  String get editorAnagraficaExperience;

  /// No description provided for @editorAnagraficaInspiration.
  ///
  /// In it, this message translates to:
  /// **'Ispirazione'**
  String get editorAnagraficaInspiration;

  /// No description provided for @editorStatsTitle.
  ///
  /// In it, this message translates to:
  /// **'Punteggi caratteristica'**
  String get editorStatsTitle;

  /// No description provided for @editorStatsHint.
  ///
  /// In it, this message translates to:
  /// **'Valori 1-30. Il modificatore (sotto al campo) si aggiorna automaticamente.'**
  String get editorStatsHint;

  /// No description provided for @editorAbilityTooltipNeedsValue.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la statistica per tirare'**
  String get editorAbilityTooltipNeedsValue;

  /// No description provided for @editorAbilityTooltipRoll.
  ///
  /// In it, this message translates to:
  /// **'Tira {formula} ({ability})'**
  String editorAbilityTooltipRoll(Object formula, Object ability);

  /// No description provided for @editorColComp.
  ///
  /// In it, this message translates to:
  /// **'Comp.'**
  String get editorColComp;

  /// No description provided for @editorColExpert.
  ///
  /// In it, this message translates to:
  /// **'Maest.'**
  String get editorColExpert;

  /// No description provided for @editorColTotal.
  ///
  /// In it, this message translates to:
  /// **'Tot.'**
  String get editorColTotal;

  /// No description provided for @editorFlagOverrideTag.
  ///
  /// In it, this message translates to:
  /// **'override'**
  String get editorFlagOverrideTag;

  /// No description provided for @editorProfBonusOverrideTooltip.
  ///
  /// In it, this message translates to:
  /// **'Override manuale (Combat)'**
  String get editorProfBonusOverrideTooltip;

  /// No description provided for @editorProfBonusAutoTooltip.
  ///
  /// In it, this message translates to:
  /// **'Calcolato dal livello'**
  String get editorProfBonusAutoTooltip;

  /// No description provided for @editorProfBonusChipLabel.
  ///
  /// In it, this message translates to:
  /// **'Comp {value}'**
  String editorProfBonusChipLabel(Object value);

  /// No description provided for @editorCombatDefenseMovement.
  ///
  /// In it, this message translates to:
  /// **'Difesa & movimento'**
  String get editorCombatDefenseMovement;

  /// No description provided for @editorCombatArmorClassLabel.
  ///
  /// In it, this message translates to:
  /// **'Classe Armatura (CA)'**
  String get editorCombatArmorClassLabel;

  /// No description provided for @editorCombatHintAcAuto.
  ///
  /// In it, this message translates to:
  /// **'auto: {value} (10 + {ability})'**
  String editorCombatHintAcAuto(Object value, Object ability);

  /// No description provided for @editorCombatHintInitAuto.
  ///
  /// In it, this message translates to:
  /// **'auto: {value} (mod {ability})'**
  String editorCombatHintInitAuto(Object value, Object ability);

  /// No description provided for @editorCombatSpeedLabel.
  ///
  /// In it, this message translates to:
  /// **'Velocità (ft)'**
  String get editorCombatSpeedLabel;

  /// No description provided for @editorCombatProfBonusLabel.
  ///
  /// In it, this message translates to:
  /// **'Bonus competenza'**
  String get editorCombatProfBonusLabel;

  /// No description provided for @editorCombatHintProfAuto.
  ///
  /// In it, this message translates to:
  /// **'auto: {value} (dal livello)'**
  String editorCombatHintProfAuto(Object value);

  /// No description provided for @editorCombatHpSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Punti ferita'**
  String get editorCombatHpSectionTitle;

  /// No description provided for @editorCombatHpMaxLabel.
  ///
  /// In it, this message translates to:
  /// **'PF max'**
  String get editorCombatHpMaxLabel;

  /// No description provided for @editorCombatHpCurrentLabel.
  ///
  /// In it, this message translates to:
  /// **'PF attuali'**
  String get editorCombatHpCurrentLabel;

  /// No description provided for @editorCombatHitDiceTotalLabel.
  ///
  /// In it, this message translates to:
  /// **'Totali'**
  String get editorCombatHitDiceTotalLabel;

  /// No description provided for @editorCombatHitDiceUsedLabel.
  ///
  /// In it, this message translates to:
  /// **'Usati'**
  String get editorCombatHitDiceUsedLabel;

  /// No description provided for @editorCombatDeathSavesSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Tiri salvezza contro morte'**
  String get editorCombatDeathSavesSectionTitle;

  /// No description provided for @editorCombatDeathSavesSuccLabel.
  ///
  /// In it, this message translates to:
  /// **'Successi (0-3)'**
  String get editorCombatDeathSavesSuccLabel;

  /// No description provided for @editorCombatDeathSavesFailLabel.
  ///
  /// In it, this message translates to:
  /// **'Fallimenti (0-3)'**
  String get editorCombatDeathSavesFailLabel;

  /// No description provided for @editorCombatConditionsTitle.
  ///
  /// In it, this message translates to:
  /// **'Condizioni'**
  String get editorCombatConditionsTitle;

  /// No description provided for @editorCombatConditionsHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca il chip per attivare/disattivare. Tocca l\'icona ⓘ per la descrizione PHB.'**
  String get editorCombatConditionsHint;

  /// No description provided for @editorCombatRestsTitle.
  ///
  /// In it, this message translates to:
  /// **'Riposi'**
  String get editorCombatRestsTitle;

  /// No description provided for @editorCombatRestsHint.
  ///
  /// In it, this message translates to:
  /// **'Riposo breve: reset TS morte (e slot warlock se progressione warlock). Riposo lungo: HP=max, temp=0, slot pieni, dadi vita recuperati per metà.'**
  String get editorCombatRestsHint;

  /// No description provided for @editorSpellsCasterClassLabel.
  ///
  /// In it, this message translates to:
  /// **'Classe incantatrice'**
  String get editorSpellsCasterClassLabel;

  /// No description provided for @editorSpellsSaveDcLabel.
  ///
  /// In it, this message translates to:
  /// **'CD tiro salvezza'**
  String get editorSpellsSaveDcLabel;

  /// No description provided for @editorSpellsAttackLabel.
  ///
  /// In it, this message translates to:
  /// **'Bonus attacco'**
  String get editorSpellsAttackLabel;

  /// No description provided for @editorSpellsSlotsHint.
  ///
  /// In it, this message translates to:
  /// **'Lascia vuoti i livelli che non hai (non vengono inviati). Puoi precompilare dalla tabella PHB.'**
  String get editorSpellsSlotsHint;

  /// No description provided for @editorSpellsListTitle.
  ///
  /// In it, this message translates to:
  /// **'Lista incantesimi'**
  String get editorSpellsListTitle;

  /// No description provided for @editorSpellsListHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi dal catalogo SRD (319 spell) o crea una custom homebrew.'**
  String get editorSpellsListHint;

  /// No description provided for @editorSpellsAddFromCatalog.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi dal catalogo'**
  String get editorSpellsAddFromCatalog;

  /// No description provided for @editorSpellsCustomSpell.
  ///
  /// In it, this message translates to:
  /// **'Custom spell'**
  String get editorSpellsCustomSpell;

  /// No description provided for @editorSpellsConvertTitle.
  ///
  /// In it, this message translates to:
  /// **'Personalizza incantesimo'**
  String get editorSpellsConvertTitle;

  /// No description provided for @editorSpellsConvertBody.
  ///
  /// In it, this message translates to:
  /// **'Verrà copiato dal catalogo e diventerà una custom modificabile. La connessione al catalogo SRD viene persa.'**
  String get editorSpellsConvertBody;

  /// No description provided for @editorSpellsConvertConfirm.
  ///
  /// In it, this message translates to:
  /// **'Personalizza'**
  String get editorSpellsConvertConfirm;

  /// No description provided for @editorSpellsProgressionLabel.
  ///
  /// In it, this message translates to:
  /// **'Progressione (PHB)'**
  String get editorSpellsProgressionLabel;

  /// No description provided for @editorSpellsFillFromPhb.
  ///
  /// In it, this message translates to:
  /// **'Compila da PHB'**
  String get editorSpellsFillFromPhb;

  /// No description provided for @editorSpellsPrefillerPreview.
  ///
  /// In it, this message translates to:
  /// **'Anteprima a livello {level}: {slots}'**
  String editorSpellsPrefillerPreview(Object level, Object slots);

  /// No description provided for @editorSpellsNoSlotsAtLevel.
  ///
  /// In it, this message translates to:
  /// **'nessuno slot a questo livello'**
  String get editorSpellsNoSlotsAtLevel;

  /// No description provided for @editorSpellsSetLevelFirst.
  ///
  /// In it, this message translates to:
  /// **'Imposta prima il livello del personaggio nella tab Anagrafica.'**
  String get editorSpellsSetLevelFirst;

  /// No description provided for @editorSpellsFillConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Compilare gli slot?'**
  String get editorSpellsFillConfirmTitle;

  /// No description provided for @editorSpellsFillConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'I valori \"Max\" verranno sovrascritti dalla tabella PHB. Il numero corrente verrà allineato al nuovo max.'**
  String get editorSpellsFillConfirmBody;

  /// No description provided for @editorSpellsFillConfirmYes.
  ///
  /// In it, this message translates to:
  /// **'Compila'**
  String get editorSpellsFillConfirmYes;

  /// No description provided for @editorSpellsFillSnack.
  ///
  /// In it, this message translates to:
  /// **'Slot precompilati'**
  String get editorSpellsFillSnack;

  /// No description provided for @editorSpellsSlotLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello {n}'**
  String editorSpellsSlotLevel(Object n);

  /// No description provided for @editorSpellsSlotMax.
  ///
  /// In it, this message translates to:
  /// **'Max'**
  String get editorSpellsSlotMax;

  /// No description provided for @editorSpellsNoSlotsLine.
  ///
  /// In it, this message translates to:
  /// **'— nessuno slot —'**
  String get editorSpellsNoSlotsLine;

  /// No description provided for @editorSpellsConsumeSlot.
  ///
  /// In it, this message translates to:
  /// **'Consuma slot'**
  String get editorSpellsConsumeSlot;

  /// No description provided for @editorSpellsRestoreSlot.
  ///
  /// In it, this message translates to:
  /// **'Ripristina slot'**
  String get editorSpellsRestoreSlot;

  /// No description provided for @editorSpellsLevelChipCantrip.
  ///
  /// In it, this message translates to:
  /// **'Trucc.'**
  String get editorSpellsLevelChipCantrip;

  /// No description provided for @editorSpellsLevelChipLvl.
  ///
  /// In it, this message translates to:
  /// **'L{n}'**
  String editorSpellsLevelChipLvl(Object n);

  /// No description provided for @editorSpellsFromCatalog.
  ///
  /// In it, this message translates to:
  /// **'Dal catalogo ({source})'**
  String editorSpellsFromCatalog(Object source);

  /// No description provided for @editorSpellsCustomHomebrewTooltip.
  ///
  /// In it, this message translates to:
  /// **'Custom homebrew'**
  String get editorSpellsCustomHomebrewTooltip;

  /// No description provided for @editorSpellsActionsTooltip.
  ///
  /// In it, this message translates to:
  /// **'Azioni'**
  String get editorSpellsActionsTooltip;

  /// No description provided for @editorSpellsAlwaysPreparedShort.
  ///
  /// In it, this message translates to:
  /// **'Sempre prep.'**
  String get editorSpellsAlwaysPreparedShort;

  /// No description provided for @editorSpellsNotesLabel.
  ///
  /// In it, this message translates to:
  /// **'Note (per la scheda)'**
  String get editorSpellsNotesLabel;

  /// No description provided for @editorSpellProgressionNone.
  ///
  /// In it, this message translates to:
  /// **'Nessuna'**
  String get editorSpellProgressionNone;

  /// No description provided for @editorSpellProgressionFull.
  ///
  /// In it, this message translates to:
  /// **'Incantatore pieno (Mago, Chierico, …)'**
  String get editorSpellProgressionFull;

  /// No description provided for @editorSpellProgressionHalf.
  ///
  /// In it, this message translates to:
  /// **'Mezzo incantatore (Paladino, Ranger)'**
  String get editorSpellProgressionHalf;

  /// No description provided for @editorSpellProgressionThird.
  ///
  /// In it, this message translates to:
  /// **'Terzo incantatore (Trickster, Eldritch)'**
  String get editorSpellProgressionThird;

  /// No description provided for @editorSpellProgressionWarlock.
  ///
  /// In it, this message translates to:
  /// **'Warlock (Pact Magic)'**
  String get editorSpellProgressionWarlock;

  /// No description provided for @editorEquipCoinsTitle.
  ///
  /// In it, this message translates to:
  /// **'Monete'**
  String get editorEquipCoinsTitle;

  /// No description provided for @editorEquipAddItem.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi oggetto'**
  String get editorEquipAddItem;

  /// No description provided for @editorEquipItemName.
  ///
  /// In it, this message translates to:
  /// **'Oggetto'**
  String get editorEquipItemName;

  /// No description provided for @editorEquipItemQty.
  ///
  /// In it, this message translates to:
  /// **'Quantità'**
  String get editorEquipItemQty;

  /// No description provided for @editorEquipItemWeight.
  ///
  /// In it, this message translates to:
  /// **'Peso (lb)'**
  String get editorEquipItemWeight;

  /// No description provided for @editorEquipItemNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get editorEquipItemNotes;

  /// No description provided for @editorTraitsProficienciesTitle.
  ///
  /// In it, this message translates to:
  /// **'Competenze'**
  String get editorTraitsProficienciesTitle;

  /// No description provided for @editorTraitsFeaturesFieldLabel.
  ///
  /// In it, this message translates to:
  /// **'Privilegi/tratti'**
  String get editorTraitsFeaturesFieldLabel;

  /// No description provided for @editorTraitsLanguagesNone.
  ///
  /// In it, this message translates to:
  /// **'— nessuna —'**
  String get editorTraitsLanguagesNone;

  /// No description provided for @editorTraitsAddLanguageLabel.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi lingua'**
  String get editorTraitsAddLanguageLabel;

  /// No description provided for @editorNotesBackstoryLabel.
  ///
  /// In it, this message translates to:
  /// **'Background storia'**
  String get editorNotesBackstoryLabel;

  /// No description provided for @editorNotesNotesLabel.
  ///
  /// In it, this message translates to:
  /// **'Note libere'**
  String get editorNotesNotesLabel;

  /// No description provided for @editorNotAuthError.
  ///
  /// In it, this message translates to:
  /// **'Utente non autenticato'**
  String get editorNotAuthError;

  /// No description provided for @editorValidatorEnterNumber.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un numero'**
  String get editorValidatorEnterNumber;

  /// No description provided for @editorValidatorMinZero.
  ///
  /// In it, this message translates to:
  /// **'Deve essere ≥ 0'**
  String get editorValidatorMinZero;

  /// No description provided for @editorValidatorMinN.
  ///
  /// In it, this message translates to:
  /// **'Min {n}'**
  String editorValidatorMinN(Object n);

  /// No description provided for @editorValidatorMaxN.
  ///
  /// In it, this message translates to:
  /// **'Max {n}'**
  String editorValidatorMaxN(Object n);

  /// No description provided for @editorHpDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica HP'**
  String get editorHpDialogTitle;

  /// No description provided for @editorHpQuantityLabel.
  ///
  /// In it, this message translates to:
  /// **'Quantità'**
  String get editorHpQuantityLabel;

  /// No description provided for @editorHpQuantityHint.
  ///
  /// In it, this message translates to:
  /// **'es. 8'**
  String get editorHpQuantityHint;

  /// No description provided for @editorHpHeal.
  ///
  /// In it, this message translates to:
  /// **'Cura'**
  String get editorHpHeal;

  /// No description provided for @editorHpDamage.
  ///
  /// In it, this message translates to:
  /// **'Danno'**
  String get editorHpDamage;

  /// No description provided for @editorHpTempLabel.
  ///
  /// In it, this message translates to:
  /// **'PF temporanei'**
  String get editorHpTempLabel;

  /// No description provided for @editorHpTempHelper.
  ///
  /// In it, this message translates to:
  /// **'Non si stackano: vale il valore più alto'**
  String get editorHpTempHelper;

  /// No description provided for @editorHpTempApply.
  ///
  /// In it, this message translates to:
  /// **'Applica PF temporanei'**
  String get editorHpTempApply;

  /// No description provided for @editorRestLong.
  ///
  /// In it, this message translates to:
  /// **'Riposo lungo'**
  String get editorRestLong;

  /// No description provided for @editorRestShort.
  ///
  /// In it, this message translates to:
  /// **'Riposo breve'**
  String get editorRestShort;

  /// No description provided for @editorRestLongBody.
  ///
  /// In it, this message translates to:
  /// **'Verranno applicate: HP a max, PF temp a 0, slot incantesimi pieni, dadi vita recuperati per metà, tiri salvezza contro morte azzerati.'**
  String get editorRestLongBody;

  /// No description provided for @editorRestShortBody.
  ///
  /// In it, this message translates to:
  /// **'Verranno azzerati i tiri salvezza contro morte. Se la progressione è warlock, gli slot tornano pieni.'**
  String get editorRestShortBody;

  /// No description provided for @editorRestLongConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Riposo lungo?'**
  String get editorRestLongConfirmTitle;

  /// No description provided for @editorRestShortConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Riposo breve?'**
  String get editorRestShortConfirmTitle;

  /// No description provided for @editorRestLongApplied.
  ///
  /// In it, this message translates to:
  /// **'Riposo lungo applicato'**
  String get editorRestLongApplied;

  /// No description provided for @editorRestShortApplied.
  ///
  /// In it, this message translates to:
  /// **'Riposo breve applicato'**
  String get editorRestShortApplied;

  /// No description provided for @comingSoonTitle.
  ///
  /// In it, this message translates to:
  /// **'Lavori in corso'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonStayTuned.
  ///
  /// In it, this message translates to:
  /// **'Stiamo lavorando per renderla disponibile a breve. Torna a trovarci.'**
  String get comingSoonStayTuned;

  /// No description provided for @comingSoonIos.
  ///
  /// In it, this message translates to:
  /// **'L\'app per iPhone e iPad arriverà presto sull\'App Store.'**
  String get comingSoonIos;

  /// No description provided for @comingSoonAndroid.
  ///
  /// In it, this message translates to:
  /// **'L\'app per Android arriverà presto sul Google Play Store.'**
  String get comingSoonAndroid;

  /// No description provided for @comingSoonSpells.
  ///
  /// In it, this message translates to:
  /// **'Il catalogo pubblico degli incantesimi sarà presto consultabile senza account.'**
  String get comingSoonSpells;

  /// No description provided for @comingSoonGeneric.
  ///
  /// In it, this message translates to:
  /// **'Questa sezione è in lavorazione.'**
  String get comingSoonGeneric;

  /// No description provided for @comingSoonBack.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get comingSoonBack;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In it, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In it, this message translates to:
  /// **'Termini di Servizio'**
  String get legalTermsTitle;

  /// No description provided for @legalCookiesTitle.
  ///
  /// In it, this message translates to:
  /// **'Politica sui Cookie'**
  String get legalCookiesTitle;

  /// No description provided for @legalContactTitle.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get legalContactTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalOnlyItalianNotice.
  ///
  /// In it, this message translates to:
  /// **'I testi legali sono pubblicati in italiano. La versione in lingua italiana è quella ufficiale.'**
  String get legalOnlyItalianNotice;

  /// No description provided for @legalBackToHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get legalBackToHome;

  /// No description provided for @registerAcceptPart1.
  ///
  /// In it, this message translates to:
  /// **'Ho letto e accetto la '**
  String get registerAcceptPart1;

  /// No description provided for @registerAcceptPart2.
  ///
  /// In it, this message translates to:
  /// **' e i '**
  String get registerAcceptPart2;

  /// No description provided for @registerAcceptPart3.
  ///
  /// In it, this message translates to:
  /// **'.'**
  String get registerAcceptPart3;

  /// No description provided for @registerPrivacyLink.
  ///
  /// In it, this message translates to:
  /// **'Privacy Policy'**
  String get registerPrivacyLink;

  /// No description provided for @registerTermsLink.
  ///
  /// In it, this message translates to:
  /// **'Termini di Servizio'**
  String get registerTermsLink;

  /// No description provided for @registerAcceptRequired.
  ///
  /// In it, this message translates to:
  /// **'Devi accettare la Privacy Policy e i Termini di Servizio per registrarti'**
  String get registerAcceptRequired;

  /// No description provided for @registerAgeDeclaration.
  ///
  /// In it, this message translates to:
  /// **'Dichiaro di avere almeno 14 anni'**
  String get registerAgeDeclaration;

  /// No description provided for @registerAgeRequired.
  ///
  /// In it, this message translates to:
  /// **'Devi confermare di avere almeno 14 anni per registrarti'**
  String get registerAgeRequired;

  /// No description provided for @profilePrivacySectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Privacy e dati'**
  String get profilePrivacySectionTitle;

  /// No description provided for @profilePrivacyHint.
  ///
  /// In it, this message translates to:
  /// **'Scarica una copia completa dei tuoi dati personali in formato JSON, oppure consulta la nostra Privacy Policy.'**
  String get profilePrivacyHint;

  /// No description provided for @profileExportButton.
  ///
  /// In it, this message translates to:
  /// **'Esporta i miei dati'**
  String get profileExportButton;

  /// No description provided for @profileExportInProgress.
  ///
  /// In it, this message translates to:
  /// **'Preparazione export in corso…'**
  String get profileExportInProgress;

  /// No description provided for @profileExportDone.
  ///
  /// In it, this message translates to:
  /// **'Esportazione completata.'**
  String get profileExportDone;

  /// No description provided for @profileExportFailed.
  ///
  /// In it, this message translates to:
  /// **'Esportazione fallita: {error}'**
  String profileExportFailed(String error);

  /// No description provided for @profileLegalPrivacyLink.
  ///
  /// In it, this message translates to:
  /// **'Privacy Policy'**
  String get profileLegalPrivacyLink;

  /// No description provided for @profileLegalTermsLink.
  ///
  /// In it, this message translates to:
  /// **'Termini di Servizio'**
  String get profileLegalTermsLink;

  /// No description provided for @profileLegalCookiesLink.
  ///
  /// In it, this message translates to:
  /// **'Cookie'**
  String get profileLegalCookiesLink;

  /// No description provided for @profileLegalContactLink.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get profileLegalContactLink;

  /// No description provided for @deletionInfoTitle.
  ///
  /// In it, this message translates to:
  /// **'Come cancellare il tuo account'**
  String get deletionInfoTitle;

  /// No description provided for @deletionInfoIntro.
  ///
  /// In it, this message translates to:
  /// **'Puoi cancellare il tuo account e tutti i dati associati in qualsiasi momento. La cancellazione è immediata e irreversibile.'**
  String get deletionInfoIntro;

  /// No description provided for @deletionInfoStepsTitle.
  ///
  /// In it, this message translates to:
  /// **'Procedura standard'**
  String get deletionInfoStepsTitle;

  /// No description provided for @deletionInfoStep1.
  ///
  /// In it, this message translates to:
  /// **'Accedi al tuo account.'**
  String get deletionInfoStep1;

  /// No description provided for @deletionInfoStep2.
  ///
  /// In it, this message translates to:
  /// **'Vai su Profilo → sezione \"Danger zone\" in fondo alla pagina.'**
  String get deletionInfoStep2;

  /// No description provided for @deletionInfoStep3.
  ///
  /// In it, this message translates to:
  /// **'Premi \"Cancella account\".'**
  String get deletionInfoStep3;

  /// No description provided for @deletionInfoStep4.
  ///
  /// In it, this message translates to:
  /// **'Digita il tuo username e la password per conferma, poi premi il bottone rosso.'**
  String get deletionInfoStep4;

  /// No description provided for @deletionInfoWhatRemovedTitle.
  ///
  /// In it, this message translates to:
  /// **'Cosa viene cancellato'**
  String get deletionInfoWhatRemovedTitle;

  /// No description provided for @deletionInfoWhatRemoved.
  ///
  /// In it, this message translates to:
  /// **'Tutti i seguenti dati vengono rimossi in modo definitivo, senza possibilità di recupero:'**
  String get deletionInfoWhatRemoved;

  /// No description provided for @deletionInfoBullet1.
  ///
  /// In it, this message translates to:
  /// **'Account, email, password (hash), foto del profilo.'**
  String get deletionInfoBullet1;

  /// No description provided for @deletionInfoBullet2.
  ///
  /// In it, this message translates to:
  /// **'Tutte le tue schede personaggio e le immagini dei ritratti.'**
  String get deletionInfoBullet2;

  /// No description provided for @deletionInfoBullet3.
  ///
  /// In it, this message translates to:
  /// **'Cronologia dei tiri di dado.'**
  String get deletionInfoBullet3;

  /// No description provided for @deletionInfoBullet4.
  ///
  /// In it, this message translates to:
  /// **'Tutti i link di condivisione attivi delle tue schede.'**
  String get deletionInfoBullet4;

  /// No description provided for @deletionInfoBullet5.
  ///
  /// In it, this message translates to:
  /// **'Tutte le sessioni attive su qualsiasi dispositivo.'**
  String get deletionInfoBullet5;

  /// No description provided for @deletionInfoCannotLoginTitle.
  ///
  /// In it, this message translates to:
  /// **'Non riesci ad accedere?'**
  String get deletionInfoCannotLoginTitle;

  /// No description provided for @deletionInfoCannotLogin.
  ///
  /// In it, this message translates to:
  /// **'Se hai perso le credenziali e non riesci a fare il reset password, scrivici una email all\'indirizzo qui sotto specificando l\'indirizzo email del tuo account. Ti aiuteremo a procedere con la cancellazione dopo aver verificato la tua identità.'**
  String get deletionInfoCannotLogin;

  /// No description provided for @deletionInfoEmail.
  ///
  /// In it, this message translates to:
  /// **'franksisca@gmail.com'**
  String get deletionInfoEmail;

  /// No description provided for @deletionInfoLoginBtn.
  ///
  /// In it, this message translates to:
  /// **'Accedi e cancella'**
  String get deletionInfoLoginBtn;

  /// No description provided for @deletionInfoBackHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get deletionInfoBackHome;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'it':
      return AppL10nIt();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
