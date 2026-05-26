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
  /// **'Gestisci le tue schede personaggio D&D 5e.'**
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
  String get landingHeroEyebrow;

  /// No description provided for @landingHeroTitle.
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  String get landingHeroSubtitle;

  /// No description provided for @landingCtaOpenWeb.
  String get landingCtaOpenWeb;

  /// No description provided for @landingCtaOpenWebSub.
  String get landingCtaOpenWebSub;

  /// No description provided for @landingCtaAppStore.
  String get landingCtaAppStore;

  /// No description provided for @landingCtaGooglePlay.
  String get landingCtaGooglePlay;

  /// No description provided for @landingCtaStorePrefix.
  String get landingCtaStorePrefix;

  /// No description provided for @landingCtaSpells.
  String get landingCtaSpells;

  /// No description provided for @landingCtaSpellsSub.
  String get landingCtaSpellsSub;

  /// No description provided for @landingFeaturesTitle.
  String get landingFeaturesTitle;

  /// No description provided for @landingFeaturesSubtitle.
  String get landingFeaturesSubtitle;

  /// No description provided for @landingFeatureSheetTitle.
  String get landingFeatureSheetTitle;

  /// No description provided for @landingFeatureSheetDesc.
  String get landingFeatureSheetDesc;

  /// No description provided for @landingFeatureDiceTitle.
  String get landingFeatureDiceTitle;

  /// No description provided for @landingFeatureDiceDesc.
  String get landingFeatureDiceDesc;

  /// No description provided for @landingFeatureShareTitle.
  String get landingFeatureShareTitle;

  /// No description provided for @landingFeatureShareDesc.
  String get landingFeatureShareDesc;

  /// No description provided for @landingFeatureSpellsTitle.
  String get landingFeatureSpellsTitle;

  /// No description provided for @landingFeatureSpellsDesc.
  String get landingFeatureSpellsDesc;

  /// No description provided for @landingFooterLegal.
  String get landingFooterLegal;

  /// No description provided for @landingFooterPrivacy.
  String get landingFooterPrivacy;

  /// No description provided for @landingFooterTerms.
  String get landingFooterTerms;

  /// No description provided for @landingFooterContact.
  String get landingFooterContact;

  /// No description provided for @landingImageCredit.
  String get landingImageCredit;

  /// No description provided for @landingMadeBy.
  String get landingMadeBy;

  /// No description provided for @commonBack.
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
  /// **'Premium 4,99€ una tantum — disponibile presto su mobile e web.'**
  String get paywallPriceHint;

  /// No description provided for @paywallOk.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get paywallOk;

  /// No description provided for @aboutSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get aboutSectionTitle;

  /// No description provided for @aboutPlanFree.
  ///
  /// In it, this message translates to:
  /// **'Piano attuale: Gratuito (fino a 2 schede)'**
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
  String get sheetSectionAbilities;

  /// No description provided for @sheetSectionSavesSkills.
  String get sheetSectionSavesSkills;

  /// No description provided for @sheetSectionCombat.
  String get sheetSectionCombat;

  /// No description provided for @sheetSectionSpells.
  String get sheetSectionSpells;

  /// No description provided for @sheetSectionEquipment.
  String get sheetSectionEquipment;

  /// No description provided for @sheetSectionTraits.
  String get sheetSectionTraits;

  /// No description provided for @sheetSectionNotes.
  String get sheetSectionNotes;

  /// No description provided for @sheetHeaderBackground.
  String get sheetHeaderBackground;

  /// No description provided for @sheetHeaderAlignment.
  String get sheetHeaderAlignment;

  /// No description provided for @sheetHpLabel.
  String get sheetHpLabel;

  /// No description provided for @sheetAbilityStr.
  String get sheetAbilityStr;

  /// No description provided for @sheetAbilityDex.
  String get sheetAbilityDex;

  /// No description provided for @sheetAbilityCon.
  String get sheetAbilityCon;

  /// No description provided for @sheetAbilityInt.
  String get sheetAbilityInt;

  /// No description provided for @sheetAbilityWis.
  String get sheetAbilityWis;

  /// No description provided for @sheetAbilityCha.
  String get sheetAbilityCha;

  /// No description provided for @sheetSavingThrowsLabel.
  String get sheetSavingThrowsLabel;

  /// No description provided for @sheetSkillsLabel.
  String get sheetSkillsLabel;

  /// No description provided for @sheetCombatAc.
  String get sheetCombatAc;

  /// No description provided for @sheetCombatInitiative.
  String get sheetCombatInitiative;

  /// No description provided for @sheetCombatSpeed.
  String get sheetCombatSpeed;

  /// No description provided for @sheetCombatProfBonus.
  String get sheetCombatProfBonus;

  /// No description provided for @sheetCombatHitDice.
  String get sheetCombatHitDice;

  /// No description provided for @sheetCombatDeathSaves.
  String get sheetCombatDeathSaves;

  /// No description provided for @sheetCombatDeathSavesValue.
  String sheetCombatDeathSavesValue(Object s, Object f);

  /// No description provided for @sheetSpellsClass.
  String get sheetSpellsClass;

  /// No description provided for @sheetSpellsSaveDc.
  String get sheetSpellsSaveDc;

  /// No description provided for @sheetSpellsAttackBonus.
  String get sheetSpellsAttackBonus;

  /// No description provided for @sheetSpellsSlotsByLevel.
  String get sheetSpellsSlotsByLevel;

  /// No description provided for @sheetSpellsKnown.
  String get sheetSpellsKnown;

  /// No description provided for @sheetSpellCantrip.
  String get sheetSpellCantrip;

  /// No description provided for @sheetSpellLevelShort.
  String sheetSpellLevelShort(Object n);

  /// No description provided for @sheetSpellAlwaysPrepared.
  String get sheetSpellAlwaysPrepared;

  /// No description provided for @sheetSpellPrepared.
  String get sheetSpellPrepared;

  /// No description provided for @sheetEquipmentInventory.
  String get sheetEquipmentInventory;

  /// No description provided for @sheetTraitsPersonality.
  String get sheetTraitsPersonality;

  /// No description provided for @sheetTraitsIdeals.
  String get sheetTraitsIdeals;

  /// No description provided for @sheetTraitsBonds.
  String get sheetTraitsBonds;

  /// No description provided for @sheetTraitsFlaws.
  String get sheetTraitsFlaws;

  /// No description provided for @sheetTraitsLanguages.
  String get sheetTraitsLanguages;

  /// No description provided for @sheetTraitsArmor.
  String get sheetTraitsArmor;

  /// No description provided for @sheetTraitsWeapons.
  String get sheetTraitsWeapons;

  /// No description provided for @sheetTraitsTools.
  String get sheetTraitsTools;

  /// No description provided for @sheetTraitsFeatures.
  String get sheetTraitsFeatures;

  /// No description provided for @sheetNotesBackstory.
  String get sheetNotesBackstory;

  /// No description provided for @sheetNotesAllies.
  String get sheetNotesAllies;

  /// No description provided for @sheetNotesSymbol.
  String get sheetNotesSymbol;

  /// No description provided for @sheetNotesPhysical.
  String get sheetNotesPhysical;

  /// No description provided for @sheetNotesNotes.
  String get sheetNotesNotes;

  /// No description provided for @sharedInvalidLink.
  String get sharedInvalidLink;

  /// No description provided for @shareDialogTitle.
  String get shareDialogTitle;

  /// No description provided for @shareDialogIntro.
  String get shareDialogIntro;

  /// No description provided for @shareDialogPublicLink.
  String get shareDialogPublicLink;

  /// No description provided for @shareDialogCopyHint.
  String get shareDialogCopyHint;

  /// No description provided for @shareDialogCopiedSnack.
  String get shareDialogCopiedSnack;

  /// No description provided for @shareDialogCopy.
  String get shareDialogCopy;

  /// No description provided for @shareDialogRevoke.
  String get shareDialogRevoke;

  /// No description provided for @shareDialogActive.
  String get shareDialogActive;

  /// No description provided for @shareDialogGeneratedAt.
  String shareDialogGeneratedAt(Object date);

  /// No description provided for @shareDialogLostHint.
  String get shareDialogLostHint;

  /// No description provided for @shareDialogRegenerate.
  String get shareDialogRegenerate;

  /// No description provided for @shareDialogGenerate.
  String get shareDialogGenerate;

  /// No description provided for @customSpellDialogTitleNew.
  String get customSpellDialogTitleNew;

  /// No description provided for @customSpellDialogTitleEdit.
  String get customSpellDialogTitleEdit;

  /// No description provided for @customSpellFieldName.
  String get customSpellFieldName;

  /// No description provided for @customSpellFieldLevel.
  String get customSpellFieldLevel;

  /// No description provided for @customSpellFieldLevelHelper.
  String get customSpellFieldLevelHelper;

  /// No description provided for @customSpellFieldSchool.
  String get customSpellFieldSchool;

  /// No description provided for @customSpellFieldCastingTime.
  String get customSpellFieldCastingTime;

  /// No description provided for @customSpellHintCastingTime.
  String get customSpellHintCastingTime;

  /// No description provided for @customSpellFieldRange.
  String get customSpellFieldRange;

  /// No description provided for @customSpellHintRange.
  String get customSpellHintRange;

  /// No description provided for @customSpellFieldDuration.
  String get customSpellFieldDuration;

  /// No description provided for @customSpellHintDuration.
  String get customSpellHintDuration;

  /// No description provided for @customSpellComponents.
  String get customSpellComponents;

  /// No description provided for @customSpellMaterials.
  String get customSpellMaterials;

  /// No description provided for @customSpellMaterialsHint.
  String get customSpellMaterialsHint;

  /// No description provided for @customSpellConcentration.
  String get customSpellConcentration;

  /// No description provided for @customSpellRitual.
  String get customSpellRitual;

  /// No description provided for @customSpellClasses.
  String get customSpellClasses;

  /// No description provided for @customSpellDescription.
  String get customSpellDescription;

  /// No description provided for @customSpellHigherLevels.
  String get customSpellHigherLevels;

  /// No description provided for @abilityShortStr.
  String get abilityShortStr;

  /// No description provided for @abilityShortDex.
  String get abilityShortDex;

  /// No description provided for @abilityShortCon.
  String get abilityShortCon;

  /// No description provided for @abilityShortInt.
  String get abilityShortInt;

  /// No description provided for @abilityShortWis.
  String get abilityShortWis;

  /// No description provided for @abilityShortCha.
  String get abilityShortCha;

  /// No description provided for @skillAcrobatics.
  String get skillAcrobatics;

  /// No description provided for @skillAnimalHandling.
  String get skillAnimalHandling;

  /// No description provided for @skillArcana.
  String get skillArcana;

  /// No description provided for @skillAthletics.
  String get skillAthletics;

  /// No description provided for @skillDeception.
  String get skillDeception;

  /// No description provided for @skillHistory.
  String get skillHistory;

  /// No description provided for @skillInsight.
  String get skillInsight;

  /// No description provided for @skillIntimidation.
  String get skillIntimidation;

  /// No description provided for @skillInvestigation.
  String get skillInvestigation;

  /// No description provided for @skillMedicine.
  String get skillMedicine;

  /// No description provided for @skillNature.
  String get skillNature;

  /// No description provided for @skillPerception.
  String get skillPerception;

  /// No description provided for @skillPerformance.
  String get skillPerformance;

  /// No description provided for @skillPersuasion.
  String get skillPersuasion;

  /// No description provided for @skillReligion.
  String get skillReligion;

  /// No description provided for @skillSleightOfHand.
  String get skillSleightOfHand;

  /// No description provided for @skillStealth.
  String get skillStealth;

  /// No description provided for @skillSurvival.
  String get skillSurvival;

  /// No description provided for @conditionBlinded.
  String get conditionBlinded;

  /// No description provided for @conditionBlindedDesc.
  String get conditionBlindedDesc;

  /// No description provided for @conditionCharmed.
  String get conditionCharmed;

  /// No description provided for @conditionCharmedDesc.
  String get conditionCharmedDesc;

  /// No description provided for @conditionDeafened.
  String get conditionDeafened;

  /// No description provided for @conditionDeafenedDesc.
  String get conditionDeafenedDesc;

  /// No description provided for @conditionFrightened.
  String get conditionFrightened;

  /// No description provided for @conditionFrightenedDesc.
  String get conditionFrightenedDesc;

  /// No description provided for @conditionGrappled.
  String get conditionGrappled;

  /// No description provided for @conditionGrappledDesc.
  String get conditionGrappledDesc;

  /// No description provided for @conditionIncapacitated.
  String get conditionIncapacitated;

  /// No description provided for @conditionIncapacitatedDesc.
  String get conditionIncapacitatedDesc;

  /// No description provided for @conditionInvisible.
  String get conditionInvisible;

  /// No description provided for @conditionInvisibleDesc.
  String get conditionInvisibleDesc;

  /// No description provided for @conditionParalyzed.
  String get conditionParalyzed;

  /// No description provided for @conditionParalyzedDesc.
  String get conditionParalyzedDesc;

  /// No description provided for @conditionPetrified.
  String get conditionPetrified;

  /// No description provided for @conditionPetrifiedDesc.
  String get conditionPetrifiedDesc;

  /// No description provided for @conditionPoisoned.
  String get conditionPoisoned;

  /// No description provided for @conditionPoisonedDesc.
  String get conditionPoisonedDesc;

  /// No description provided for @conditionProne.
  String get conditionProne;

  /// No description provided for @conditionProneDesc.
  String get conditionProneDesc;

  /// No description provided for @conditionRestrained.
  String get conditionRestrained;

  /// No description provided for @conditionRestrainedDesc.
  String get conditionRestrainedDesc;

  /// No description provided for @conditionStunned.
  String get conditionStunned;

  /// No description provided for @conditionStunnedDesc.
  String get conditionStunnedDesc;

  /// No description provided for @conditionUnconscious.
  String get conditionUnconscious;

  /// No description provided for @conditionUnconsciousDesc.
  String get conditionUnconsciousDesc;

  /// No description provided for @conditionExhaustion.
  String get conditionExhaustion;

  /// No description provided for @conditionExhaustionDesc.
  String get conditionExhaustionDesc;

  /// No description provided for @diceTitle.
  String get diceTitle;

  /// No description provided for @diceFormulaLabel.
  String get diceFormulaLabel;

  /// No description provided for @diceAdvantage.
  String get diceAdvantage;

  /// No description provided for @diceDisadvantage.
  String get diceDisadvantage;

  /// No description provided for @diceRollButton.
  String get diceRollButton;

  /// No description provided for @diceHistory.
  String get diceHistory;

  /// No description provided for @diceClear.
  String get diceClear;

  /// No description provided for @diceNoRollsYet.
  String get diceNoRollsYet;

  /// No description provided for @diceNoOtherRolls.
  String get diceNoOtherRolls;

  /// No description provided for @spellPickerTitle.
  String get spellPickerTitle;

  /// No description provided for @spellPickerSearchHint.
  String get spellPickerSearchHint;

  /// No description provided for @spellFilterLevelHint.
  String get spellFilterLevelHint;

  /// No description provided for @spellFilterLevelAll.
  String get spellFilterLevelAll;

  /// No description provided for @spellFilterCantrips.
  String get spellFilterCantrips;

  /// No description provided for @spellFilterLevelN.
  String spellFilterLevelN(Object n);

  /// No description provided for @spellFilterSchoolHint.
  String get spellFilterSchoolHint;

  /// No description provided for @spellFilterSchoolAll.
  String get spellFilterSchoolAll;

  /// No description provided for @spellFilterClassHint.
  String get spellFilterClassHint;

  /// No description provided for @spellFilterClassAll.
  String get spellFilterClassAll;

  /// No description provided for @spellPickerNoResults.
  String get spellPickerNoResults;

  /// No description provided for @spellPickerDetails.
  String get spellPickerDetails;

  /// No description provided for @spellPickerAdd.
  String get spellPickerAdd;

  /// No description provided for @editorToolbarShare.
  String get editorToolbarShare;

  /// No description provided for @editorPortraitChange.
  String get editorPortraitChange;

  /// No description provided for @editorPortraitUpload.
  String get editorPortraitUpload;

  /// No description provided for @editorPortraitUpdatedSnack.
  String get editorPortraitUpdatedSnack;

  /// No description provided for @editorPortraitRemovedSnack.
  String get editorPortraitRemovedSnack;

  /// No description provided for @autosaveFormInvalid.
  String get autosaveFormInvalid;

  /// No description provided for @editorExitDirtyTitle.
  String get editorExitDirtyTitle;

  /// No description provided for @editorExitDirtyBody.
  String get editorExitDirtyBody;

  /// No description provided for @editorExitDirtyDiscard.
  String get editorExitDirtyDiscard;

  /// No description provided for @editorLayoutTitle.
  String get editorLayoutTitle;

  /// No description provided for @editorLayoutOpenButton.
  String get editorLayoutOpenButton;

  /// No description provided for @editorLayoutEmpty.
  String get editorLayoutEmpty;

  /// No description provided for @editorLayoutAddWidget.
  String get editorLayoutAddWidget;

  /// No description provided for @editorLayoutReset.
  String get editorLayoutReset;

  /// No description provided for @editorLayoutSavedSnack.
  String get editorLayoutSavedSnack;

  /// No description provided for @editorLayoutResetConfirmTitle.
  String get editorLayoutResetConfirmTitle;

  /// No description provided for @editorLayoutResetConfirmBody.
  String get editorLayoutResetConfirmBody;

  /// No description provided for @editorLayoutResetConfirmYes.
  String get editorLayoutResetConfirmYes;

  /// No description provided for @editorLayoutRemoveWidget.
  String get editorLayoutRemoveWidget;

  /// No description provided for @editorLayoutBringForward.
  String get editorLayoutBringForward;

  /// No description provided for @editorLayoutSendBackward.
  String get editorLayoutSendBackward;

  /// No description provided for @editorLayoutWidgetHpTracker.
  String get editorLayoutWidgetHpTracker;

  /// No description provided for @editorLayoutWidgetConditions.
  String get editorLayoutWidgetConditions;

  /// No description provided for @editorLayoutWidgetPortrait.
  String get editorLayoutWidgetPortrait;

  /// No description provided for @editorLayoutPremiumRequired.
  String get editorLayoutPremiumRequired;

  /// No description provided for @editorAnagraficaName.
  String get editorAnagraficaName;

  /// No description provided for @editorAnagraficaLevel.
  String get editorAnagraficaLevel;

  /// No description provided for @editorAnagraficaRace.
  String get editorAnagraficaRace;

  /// No description provided for @editorAnagraficaSubrace.
  String get editorAnagraficaSubrace;

  /// No description provided for @editorAnagraficaClass.
  String get editorAnagraficaClass;

  /// No description provided for @editorAnagraficaSubclass.
  String get editorAnagraficaSubclass;

  /// No description provided for @editorAnagraficaExperience.
  String get editorAnagraficaExperience;

  /// No description provided for @editorAnagraficaInspiration.
  String get editorAnagraficaInspiration;

  /// No description provided for @editorStatsTitle.
  String get editorStatsTitle;

  /// No description provided for @editorStatsHint.
  String get editorStatsHint;

  /// No description provided for @editorAbilityTooltipNeedsValue.
  String get editorAbilityTooltipNeedsValue;

  /// No description provided for @editorAbilityTooltipRoll.
  String editorAbilityTooltipRoll(Object formula, Object ability);

  /// No description provided for @editorColComp.
  String get editorColComp;

  /// No description provided for @editorColExpert.
  String get editorColExpert;

  /// No description provided for @editorColTotal.
  String get editorColTotal;

  /// No description provided for @editorFlagOverrideTag.
  String get editorFlagOverrideTag;

  /// No description provided for @editorProfBonusOverrideTooltip.
  String get editorProfBonusOverrideTooltip;

  /// No description provided for @editorProfBonusAutoTooltip.
  String get editorProfBonusAutoTooltip;

  /// No description provided for @editorProfBonusChipLabel.
  String editorProfBonusChipLabel(Object value);

  /// No description provided for @editorCombatDefenseMovement.
  String get editorCombatDefenseMovement;

  /// No description provided for @editorCombatArmorClassLabel.
  String get editorCombatArmorClassLabel;

  /// No description provided for @editorCombatHintAcAuto.
  String editorCombatHintAcAuto(Object value, Object ability);

  /// No description provided for @editorCombatHintInitAuto.
  String editorCombatHintInitAuto(Object value, Object ability);

  /// No description provided for @editorCombatSpeedLabel.
  String get editorCombatSpeedLabel;

  /// No description provided for @editorCombatProfBonusLabel.
  String get editorCombatProfBonusLabel;

  /// No description provided for @editorCombatHintProfAuto.
  String editorCombatHintProfAuto(Object value);

  /// No description provided for @editorCombatHpSectionTitle.
  String get editorCombatHpSectionTitle;

  /// No description provided for @editorCombatHpMaxLabel.
  String get editorCombatHpMaxLabel;

  /// No description provided for @editorCombatHpCurrentLabel.
  String get editorCombatHpCurrentLabel;

  /// No description provided for @editorCombatHitDiceTotalLabel.
  String get editorCombatHitDiceTotalLabel;

  /// No description provided for @editorCombatHitDiceUsedLabel.
  String get editorCombatHitDiceUsedLabel;

  /// No description provided for @editorCombatDeathSavesSectionTitle.
  String get editorCombatDeathSavesSectionTitle;

  /// No description provided for @editorCombatDeathSavesSuccLabel.
  String get editorCombatDeathSavesSuccLabel;

  /// No description provided for @editorCombatDeathSavesFailLabel.
  String get editorCombatDeathSavesFailLabel;

  /// No description provided for @editorCombatConditionsTitle.
  String get editorCombatConditionsTitle;

  /// No description provided for @editorCombatConditionsHint.
  String get editorCombatConditionsHint;

  /// No description provided for @editorCombatRestsTitle.
  String get editorCombatRestsTitle;

  /// No description provided for @editorCombatRestsHint.
  String get editorCombatRestsHint;

  /// No description provided for @editorHpDialogTitle.
  String get editorHpDialogTitle;

  /// No description provided for @editorHpQuantityLabel.
  String get editorHpQuantityLabel;

  /// No description provided for @editorHpQuantityHint.
  String get editorHpQuantityHint;

  /// No description provided for @editorHpHeal.
  String get editorHpHeal;

  /// No description provided for @editorHpDamage.
  String get editorHpDamage;

  /// No description provided for @editorHpTempLabel.
  String get editorHpTempLabel;

  /// No description provided for @editorHpTempHelper.
  String get editorHpTempHelper;

  /// No description provided for @editorHpTempApply.
  String get editorHpTempApply;

  /// No description provided for @editorRestLong.
  String get editorRestLong;

  /// No description provided for @editorRestShort.
  String get editorRestShort;

  /// No description provided for @editorRestLongBody.
  String get editorRestLongBody;

  /// No description provided for @editorRestShortBody.
  String get editorRestShortBody;

  /// No description provided for @editorRestLongConfirmTitle.
  String get editorRestLongConfirmTitle;

  /// No description provided for @editorRestShortConfirmTitle.
  String get editorRestShortConfirmTitle;

  /// No description provided for @editorRestLongApplied.
  String get editorRestLongApplied;

  /// No description provided for @editorRestShortApplied.
  String get editorRestShortApplied;

  /// No description provided for @editorSpellsCasterClassLabel.
  String get editorSpellsCasterClassLabel;

  /// No description provided for @editorSpellsSaveDcLabel.
  String get editorSpellsSaveDcLabel;

  /// No description provided for @editorSpellsAttackLabel.
  String get editorSpellsAttackLabel;

  /// No description provided for @editorSpellsSlotsHint.
  String get editorSpellsSlotsHint;

  /// No description provided for @editorSpellsListTitle.
  String get editorSpellsListTitle;

  /// No description provided for @editorSpellsListHint.
  String get editorSpellsListHint;

  /// No description provided for @editorSpellsAddFromCatalog.
  String get editorSpellsAddFromCatalog;

  /// No description provided for @editorSpellsCustomSpell.
  String get editorSpellsCustomSpell;

  /// No description provided for @editorSpellsConvertTitle.
  String get editorSpellsConvertTitle;

  /// No description provided for @editorSpellsConvertBody.
  String get editorSpellsConvertBody;

  /// No description provided for @editorSpellsConvertConfirm.
  String get editorSpellsConvertConfirm;

  /// No description provided for @editorSpellsProgressionLabel.
  String get editorSpellsProgressionLabel;

  /// No description provided for @editorSpellsFillFromPhb.
  String get editorSpellsFillFromPhb;

  /// No description provided for @editorSpellsPrefillerPreview.
  String editorSpellsPrefillerPreview(Object level, Object slots);

  /// No description provided for @editorSpellsNoSlotsAtLevel.
  String get editorSpellsNoSlotsAtLevel;

  /// No description provided for @editorSpellsSetLevelFirst.
  String get editorSpellsSetLevelFirst;

  /// No description provided for @editorSpellsFillConfirmTitle.
  String get editorSpellsFillConfirmTitle;

  /// No description provided for @editorSpellsFillConfirmBody.
  String get editorSpellsFillConfirmBody;

  /// No description provided for @editorSpellsFillConfirmYes.
  String get editorSpellsFillConfirmYes;

  /// No description provided for @editorSpellsFillSnack.
  String get editorSpellsFillSnack;

  /// No description provided for @editorSpellsSlotLevel.
  String editorSpellsSlotLevel(Object n);

  /// No description provided for @editorSpellsSlotMax.
  String get editorSpellsSlotMax;

  /// No description provided for @editorSpellsNoSlotsLine.
  String get editorSpellsNoSlotsLine;

  /// No description provided for @editorSpellsConsumeSlot.
  String get editorSpellsConsumeSlot;

  /// No description provided for @editorSpellsRestoreSlot.
  String get editorSpellsRestoreSlot;

  /// No description provided for @editorSpellsLevelChipCantrip.
  String get editorSpellsLevelChipCantrip;

  /// No description provided for @editorSpellsLevelChipLvl.
  String editorSpellsLevelChipLvl(Object n);

  /// No description provided for @editorSpellsFromCatalog.
  String editorSpellsFromCatalog(Object source);

  /// No description provided for @editorSpellsCustomHomebrewTooltip.
  String get editorSpellsCustomHomebrewTooltip;

  /// No description provided for @editorSpellsActionsTooltip.
  String get editorSpellsActionsTooltip;

  /// No description provided for @editorSpellsAlwaysPreparedShort.
  String get editorSpellsAlwaysPreparedShort;

  /// No description provided for @editorSpellsNotesLabel.
  String get editorSpellsNotesLabel;

  /// No description provided for @editorSpellProgressionNone.
  String get editorSpellProgressionNone;

  /// No description provided for @editorSpellProgressionFull.
  String get editorSpellProgressionFull;

  /// No description provided for @editorSpellProgressionHalf.
  String get editorSpellProgressionHalf;

  /// No description provided for @editorSpellProgressionThird.
  String get editorSpellProgressionThird;

  /// No description provided for @editorSpellProgressionWarlock.
  String get editorSpellProgressionWarlock;

  /// No description provided for @editorEquipCoinsTitle.
  String get editorEquipCoinsTitle;

  /// No description provided for @editorEquipAddItem.
  String get editorEquipAddItem;

  /// No description provided for @editorEquipItemName.
  String get editorEquipItemName;

  /// No description provided for @editorEquipItemQty.
  String get editorEquipItemQty;

  /// No description provided for @editorEquipItemWeight.
  String get editorEquipItemWeight;

  /// No description provided for @editorEquipItemNotes.
  String get editorEquipItemNotes;

  /// No description provided for @editorTraitsProficienciesTitle.
  String get editorTraitsProficienciesTitle;

  /// No description provided for @editorTraitsFeaturesFieldLabel.
  String get editorTraitsFeaturesFieldLabel;

  /// No description provided for @editorTraitsLanguagesNone.
  String get editorTraitsLanguagesNone;

  /// No description provided for @editorTraitsAddLanguageLabel.
  String get editorTraitsAddLanguageLabel;

  /// No description provided for @editorNotesBackstoryLabel.
  String get editorNotesBackstoryLabel;

  /// No description provided for @editorNotesNotesLabel.
  String get editorNotesNotesLabel;

  /// No description provided for @editorNotAuthError.
  String get editorNotAuthError;

  /// No description provided for @editorValidatorEnterNumber.
  String get editorValidatorEnterNumber;

  /// No description provided for @editorValidatorMinZero.
  String get editorValidatorMinZero;

  /// No description provided for @editorValidatorMinN.
  String editorValidatorMinN(Object n);

  /// No description provided for @editorValidatorMaxN.
  String editorValidatorMaxN(Object n);

  /// No description provided for @comingSoonTitle.
  String get comingSoonTitle;

  /// No description provided for @comingSoonStayTuned.
  String get comingSoonStayTuned;

  /// No description provided for @comingSoonIos.
  String get comingSoonIos;

  /// No description provided for @comingSoonAndroid.
  String get comingSoonAndroid;

  /// No description provided for @comingSoonSpells.
  String get comingSoonSpells;

  /// No description provided for @comingSoonGeneric.
  String get comingSoonGeneric;

  /// No description provided for @comingSoonBack.
  String get comingSoonBack;

  /// No description provided for @legalPrivacyTitle.
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  String get legalTermsTitle;

  /// No description provided for @legalCookiesTitle.
  String get legalCookiesTitle;

  /// No description provided for @legalContactTitle.
  String get legalContactTitle;

  /// No description provided for @legalLastUpdated.
  String legalLastUpdated(String date);

  /// No description provided for @legalOnlyItalianNotice.
  String get legalOnlyItalianNotice;

  /// No description provided for @legalBackToHome.
  String get legalBackToHome;

  /// No description provided for @registerAcceptPart1.
  String get registerAcceptPart1;

  /// No description provided for @registerAcceptPart2.
  String get registerAcceptPart2;

  /// No description provided for @registerAcceptPart3.
  String get registerAcceptPart3;

  /// No description provided for @registerPrivacyLink.
  String get registerPrivacyLink;

  /// No description provided for @registerTermsLink.
  String get registerTermsLink;

  /// No description provided for @registerAcceptRequired.
  String get registerAcceptRequired;

  /// No description provided for @profilePrivacySectionTitle.
  String get profilePrivacySectionTitle;

  /// No description provided for @profilePrivacyHint.
  String get profilePrivacyHint;

  /// No description provided for @profileExportButton.
  String get profileExportButton;

  /// No description provided for @profileExportInProgress.
  String get profileExportInProgress;

  /// No description provided for @profileExportDone.
  String get profileExportDone;

  /// No description provided for @profileExportFailed.
  String profileExportFailed(String error);

  /// No description provided for @profileLegalPrivacyLink.
  String get profileLegalPrivacyLink;

  /// No description provided for @profileLegalTermsLink.
  String get profileLegalTermsLink;

  /// No description provided for @profileLegalCookiesLink.
  String get profileLegalCookiesLink;

  /// No description provided for @profileLegalContactLink.
  String get profileLegalContactLink;

  /// No description provided for @deletionInfoTitle.
  String get deletionInfoTitle;
  String get deletionInfoIntro;
  String get deletionInfoStepsTitle;
  String get deletionInfoStep1;
  String get deletionInfoStep2;
  String get deletionInfoStep3;
  String get deletionInfoStep4;
  String get deletionInfoWhatRemovedTitle;
  String get deletionInfoWhatRemoved;
  String get deletionInfoBullet1;
  String get deletionInfoBullet2;
  String get deletionInfoBullet3;
  String get deletionInfoBullet4;
  String get deletionInfoBullet5;
  String get deletionInfoCannotLoginTitle;
  String get deletionInfoCannotLogin;
  String get deletionInfoEmail;
  String get deletionInfoLoginBtn;
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
