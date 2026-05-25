// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppL10nIt extends AppL10n {
  AppL10nIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PG 5e';

  @override
  String get navHome => 'Home';

  @override
  String get navCharacters => 'Le tue schede';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navSharedSheet => 'Scheda condivisa';

  @override
  String get navCharacterEditor => 'Scheda personaggio';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionDuplicate => 'Duplica';

  @override
  String get actionRename => 'Rinomina';

  @override
  String get actionExport => 'Esporta';

  @override
  String get actionImport => 'Importa';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionLogout => 'Esci';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionReload => 'Ricarica';

  @override
  String get actionGoHome => 'Vai alla home';

  @override
  String get actionBackHome => 'Torna alla home';

  @override
  String commonErrorPrefix(Object message) {
    return 'Errore: $message';
  }

  @override
  String commonNetworkError(Object message) {
    return 'Errore di rete: $message';
  }

  @override
  String get commonRequired => 'Obbligatorio';

  @override
  String commonMaxChars(Object n) {
    return 'Massimo $n caratteri';
  }

  @override
  String commonMinChars(Object n) {
    return 'Almeno $n caratteri';
  }

  @override
  String get commonNotAuthenticated => 'Non sei autenticato.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Lingua';

  @override
  String get languageSectionTitle => 'Lingua dell\'app';

  @override
  String get languageSectionHint =>
      'Cambia l\'interfaccia tra italiano e inglese. \"Sistema\" segue le impostazioni del dispositivo.';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get authLoginTitle => 'Accedi';

  @override
  String get authRegisterTitle => 'Registrati';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authDisplayNameLabel => 'Nome visualizzato';

  @override
  String get authNeedAccount => 'Non hai un account?';

  @override
  String get authHaveAccount => 'Hai già un account?';

  @override
  String get authBtnLogin => 'Entra';

  @override
  String get authBtnRegister => 'Crea account';

  @override
  String get authCheckEmailTitle => 'Controlla la tua email';

  @override
  String authCheckEmailBody(Object email) {
    return 'Ti abbiamo inviato un link di verifica a $email.';
  }

  @override
  String get landingWelcome => 'Benvenuto';

  @override
  String get landingTagline =>
      'Gestisci le tue schede personaggio per giochi di ruolo fantasy 5e.';

  @override
  String get landingCreateAccount => 'Crea un account';

  @override
  String get landingSignIn => 'Accedi';

  @override
  String get landingHeroEyebrow => 'Cronache di un avventuriero 5e';

  @override
  String get landingHeroTitle => 'Forgia il tuo eroe.\nVivi la tua leggenda.';

  @override
  String get landingHeroSubtitle =>
      'Custodisci ogni scheda, lancia ogni dado, condividi le gesta del tuo personaggio — '
      'un compagno digitale per le tue avventure di ruolo 5e.';

  @override
  String get landingCtaOpenWeb => 'Entra nella tua biblioteca';

  @override
  String get landingCtaOpenWebSub => 'Hai già un account? Accedi.';

  @override
  String get landingCtaAppStore => 'Scarica su App Store';

  @override
  String get landingCtaGooglePlay => 'Disponibile su Google Play';

  @override
  String get landingCtaStorePrefix => 'Presto';

  @override
  String get landingCtaSpells => 'Sfoglia il codex degli incantesimi';

  @override
  String get landingCtaSpellsSub =>
      'Anteprima del catalogo pubblico (in arrivo)';

  @override
  String get landingFeaturesTitle => 'Le arti del Cronista';

  @override
  String get landingFeaturesSubtitle =>
      'Tutto quello che serve a un avventuriero, raccolto in un solo grimorio.';

  @override
  String get landingFeatureSheetTitle => 'Pergamena del PG';

  @override
  String get landingFeatureSheetDesc =>
      'Ogni campo del manuale 5e, otto sezioni dedicate, calcoli automatici. '
      'Nessun dettaglio del tuo eroe va perduto.';

  @override
  String get landingFeatureDiceTitle => 'Il fato dei dadi';

  @override
  String get landingFeatureDiceDesc =>
      'Dice roller integrato, gestione PF, slot incantesimi, condizioni e riposi a portata di mano.';

  @override
  String get landingFeatureShareTitle => 'Saghe condivise';

  @override
  String get landingFeatureShareDesc =>
      'Un link in sola lettura per il tuo Dungeon Master e la compagnia. '
      'Revocabile in un istante, sempre tuo.';

  @override
  String get landingFeatureSpellsTitle => 'Codex degli incantesimi';

  @override
  String get landingFeatureSpellsDesc =>
      '319 incantesimi del SRD 5.1, ricerca rapida, descrizioni complete in italiano e inglese.';

  @override
  String get landingFooterLegal => 'Note legali';

  @override
  String get landingFooterPrivacy => 'Privacy';

  @override
  String get landingFooterTerms => 'Termini';

  @override
  String get landingFooterContact => 'Contatti';

  @override
  String get loginAccessTitle => 'Accedi';

  @override
  String get loginEmailRequired => 'Inserisci la tua email';

  @override
  String get loginEmailInvalid => 'Email non valida';

  @override
  String get loginPasswordRequired => 'Inserisci la password';

  @override
  String get loginGoRegister => 'Non hai un account? Registrati';

  @override
  String get loginForgotPassword => 'Password dimenticata?';

  @override
  String get loginNetworkError => 'Errore di rete';

  @override
  String get forgotPasswordTitle => 'Password dimenticata';

  @override
  String get forgotPasswordIntro =>
      'Inserisci la tua email: se l\'account esiste ed è verificato, ti invieremo un link per impostare una nuova password.';

  @override
  String get forgotPasswordSubmit => 'Invia link di reset';

  @override
  String get forgotPasswordBackToLogin => 'Torna al login';

  @override
  String get forgotPasswordSentTitle => 'Controlla la tua email';

  @override
  String get forgotPasswordSentBodyStart => 'Se esiste un account collegato a ';

  @override
  String get forgotPasswordSentBodyEnd =>
      ', riceverai a breve un link per reimpostare la password. Il link è valido per 1 ora.';

  @override
  String get resetPasswordTitle => 'Reimposta password';

  @override
  String get resetPasswordIntro =>
      'Scegli una nuova password. Tutti i dispositivi su cui sei loggato verranno disconnessi.';

  @override
  String get resetPasswordSubmit => 'Imposta nuova password';

  @override
  String get resetPasswordDoneTitle => 'Password aggiornata!';

  @override
  String get resetPasswordDoneBody =>
      'La tua password è stata reimpostata. Ora puoi accedere con quella nuova.';

  @override
  String get resetPasswordMissingToken =>
      'Link non valido: manca il token. Richiedi un nuovo link di reset.';

  @override
  String get resetPasswordRequestNew => 'Richiedi nuovo link';

  @override
  String get registerTitle => 'Crea un account';

  @override
  String get registerEmailRequired => 'Inserisci la tua email';

  @override
  String get registerEmailInvalid => 'Email non valida';

  @override
  String get registerPasswordRequired => 'Inserisci una password';

  @override
  String get registerPasswordMin => 'Almeno 10 caratteri';

  @override
  String get registerPasswordMax => 'Massimo 100 caratteri';

  @override
  String get registerPasswordUpper => 'Serve almeno una lettera maiuscola';

  @override
  String get registerPasswordDigit => 'Serve almeno un numero';

  @override
  String get registerPasswordsMismatch => 'Le due password non coincidono';

  @override
  String get registerUsernameRequired => 'Inserisci uno username';

  @override
  String get registerUsernameMin => 'Almeno 3 caratteri';

  @override
  String get registerUsernameMax => 'Massimo 30 caratteri';

  @override
  String get registerUsernameChars => 'Solo lettere, numeri e underscore';

  @override
  String get registerUsernameHelper =>
      'Solo lettere, numeri e underscore (3-30)';

  @override
  String get registerDisplayRequired => 'Inserisci un nome visualizzato';

  @override
  String get registerDisplayMax => 'Massimo 60 caratteri';

  @override
  String get registerPasswordHelper =>
      'Almeno 10 caratteri, 1 maiuscola, 1 numero';

  @override
  String get registerPasswordShow => 'Mostra password';

  @override
  String get registerPasswordHide => 'Nascondi password';

  @override
  String get registerConfirmLabel => 'Conferma password';

  @override
  String get checkEmailTitle => 'Controlla la tua email';

  @override
  String get checkEmailHeader => 'Ti abbiamo inviato una email';

  @override
  String get checkEmailBodyStart =>
      'Per attivare il tuo account, apri il link che abbiamo mandato a ';

  @override
  String get checkEmailBodyEnd => '. Il link è valido per 24 ore.';

  @override
  String get verifyEmailTitle => 'Verifica email';

  @override
  String get verifyEmailWaiting => 'Sto verificando il tuo indirizzo email…';

  @override
  String get verifyEmailFailed => 'Verifica fallita';

  @override
  String verifyEmailUnexpected(Object error) {
    return 'Errore inatteso: $error';
  }

  @override
  String get verifyEmailOk => 'Email verificata!';

  @override
  String get verifyEmailOkBody =>
      'Il tuo account è ora attivo. Puoi accedere dalla home.';

  @override
  String homeGreeting(Object name) {
    return 'Ciao, $name!';
  }

  @override
  String get profileTitle => 'Il tuo profilo';

  @override
  String get profileAvatarChange => 'Cambia avatar';

  @override
  String get profileAvatarRemove => 'Rimuovi';

  @override
  String get profileEmailHelper => 'L\'email non è modificabile';

  @override
  String get profileUsernameHelper => 'Lo username non è modificabile';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileSaveBtn => 'Salva profilo';

  @override
  String get profileChangePassword => 'Cambia password';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get profileAvatarUpdated => 'Avatar aggiornato';

  @override
  String get profilePasswordChangedLogout =>
      'Password cambiata. Accedi di nuovo.';

  @override
  String get changePwdTitle => 'Cambia password';

  @override
  String get changePwdCurrentLabel => 'Password attuale';

  @override
  String get changePwdNewLabel => 'Nuova password';

  @override
  String get changePwdNewHelper => 'Almeno 10 caratteri, 1 maiuscola, 1 numero';

  @override
  String get changePwdConfirmLabel => 'Conferma nuova password';

  @override
  String get changePwdRequired => 'Obbligatoria';

  @override
  String get changePwdNewRequired => 'Inserisci una nuova password';

  @override
  String get changePwdMustDiffer => 'Deve essere diversa da quella attuale';

  @override
  String get changePwdSubmit => 'Cambia';

  @override
  String get changePwdLogoutWarning =>
      'Dopo il cambio password verrai disconnesso e dovrai accedere di nuovo.';

  @override
  String get dangerZoneTitle => 'Zona pericolosa';

  @override
  String get deleteAccountHint =>
      'La cancellazione è definitiva: vengono rimossi profilo, tutte le schede, condivisioni, cronologia tiri.';

  @override
  String get deleteAccountButton => 'Elimina il mio account';

  @override
  String get deleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountWarning => 'Questa azione è IRREVERSIBILE.';

  @override
  String get deleteAccountBullets =>
      'Verranno cancellati: il tuo profilo (email, username, avatar), tutte le schede personaggio con relativi ritratti, tutti i link di condivisione (chi ha il link non vedrà più nulla), la cronologia dei tiri di dado. L\'username e l\'email torneranno disponibili per altre registrazioni.';

  @override
  String deleteAccountTypeUsername(Object username) {
    return 'Digita il tuo username ($username) per confermare';
  }

  @override
  String get deleteAccountUsernameMismatch => 'L\'username non coincide';

  @override
  String get deleteAccountPasswordLabel => 'Password attuale';

  @override
  String get deleteAccountConfirmBtn => 'Elimina definitivamente';

  @override
  String get deleteAccountDoneSnack => 'Account eliminato. Arrivederci.';

  @override
  String get charactersEmpty => 'Nessuna scheda ancora.';

  @override
  String get charactersEmptyHint => 'Tocca \"+ Nuova scheda\" per crearne una.';

  @override
  String get charactersNewBtn => 'Nuova scheda';

  @override
  String get charactersNoName => '(senza nome)';

  @override
  String get charactersImportTooltip => 'Importa…';

  @override
  String get charactersImportJson => 'Importa JSON proprietario';

  @override
  String get charactersImportFoundry => 'Importa FoundryVTT (dnd5e)';

  @override
  String get charactersActionsTooltip => 'Azioni';

  @override
  String get charactersActionRename => 'Rinomina';

  @override
  String get charactersActionDuplicate => 'Duplica';

  @override
  String get charactersActionExportJson => 'Esporta JSON';

  @override
  String get charactersActionExportFoundry => 'Esporta Foundry';

  @override
  String get charactersActionExportPdf => 'Esporta PDF';

  @override
  String get charactersActionDelete => 'Elimina';

  @override
  String get charactersRenameDialogTitle => 'Rinomina scheda';

  @override
  String get charactersRenameLabel => 'Nuovo nome';

  @override
  String get charactersDeleteDialogTitle => 'Eliminare la scheda?';

  @override
  String charactersDeleteDialogBody(Object name) {
    return 'Questa azione non si può annullare.\nScheda: $name';
  }

  @override
  String charactersLevelLabel(Object n) {
    return 'Livello $n';
  }

  @override
  String get charactersSnackRenamed => 'Scheda rinominata';

  @override
  String get charactersSnackDuplicated => 'Scheda duplicata';

  @override
  String get charactersSnackDeleted => 'Scheda eliminata';

  @override
  String charactersSnackExported(Object filename) {
    return 'Esportata: $filename';
  }

  @override
  String charactersSnackExportedFoundry(Object filename) {
    return 'Esportata per Foundry (best-effort): $filename';
  }

  @override
  String charactersSnackExportedPdf(Object filename) {
    return 'Esportato PDF: $filename';
  }

  @override
  String get charactersSnackImportedJson => 'Scheda importata';

  @override
  String get charactersSnackImportedFoundry =>
      'Scheda importata da Foundry (best-effort, controlla i dati)';

  @override
  String charactersErrorCreate(Object message) {
    return 'Errore creazione: $message';
  }

  @override
  String charactersErrorImport(Object message) {
    return 'Errore import: $message';
  }

  @override
  String charactersErrorJsonInvalid(Object message) {
    return 'JSON non valido: $message';
  }

  @override
  String get charactersErrorJsonNotObject =>
      'Il file non contiene un oggetto JSON';

  @override
  String get editorTabAnagrafica => 'Anagrafica';

  @override
  String get editorTabStats => 'Stats';

  @override
  String get editorTabAbilities => 'Abilità';

  @override
  String get editorTabCombat => 'Combat';

  @override
  String get editorTabSpells => 'Incantesimi';

  @override
  String get editorTabEquip => 'Equip';

  @override
  String get editorTabTraits => 'Tratti';

  @override
  String get editorTabNotes => 'Note';

  @override
  String get autosaveIdle => 'Modifiche salvate automaticamente';

  @override
  String get autosaveSaving => 'Salvataggio…';

  @override
  String autosaveSavedAt(Object time) {
    return 'Salvato alle $time';
  }

  @override
  String autosaveError(Object message) {
    return 'Errore: $message';
  }

  @override
  String get adminTitle => 'Pannello admin';

  @override
  String get adminSearchHint => 'Cerca per email, username o nome';

  @override
  String get adminColEmail => 'Email';

  @override
  String get adminColUsername => 'Username';

  @override
  String get adminColDisplay => 'Nome';

  @override
  String get adminColTier => 'Piano';

  @override
  String get adminColRoles => 'Ruoli';

  @override
  String get adminColCreated => 'Registrato';

  @override
  String get adminColActions => 'Azioni';

  @override
  String get adminTierFree => 'Free';

  @override
  String get adminTierPremium => 'Premium';

  @override
  String get adminRoleAdmin => 'ADMIN';

  @override
  String get adminActionGrant => 'Regala Premium';

  @override
  String get adminActionRevoke => 'Revoca Premium';

  @override
  String get adminActionDelete => 'Elimina account';

  @override
  String get adminDeleteConfirmTitle => 'Conferma eliminazione';

  @override
  String adminDeleteConfirmBody(Object email) {
    return 'Eliminerai definitivamente l\'account $email con tutti i suoi dati. Procedo?';
  }

  @override
  String get adminDeleteConfirmYes => 'Sì, elimina';

  @override
  String get adminDeleteConfirmNo => 'Annulla';

  @override
  String adminSnackGranted(Object email) {
    return 'Premium concesso a $email';
  }

  @override
  String adminSnackRevoked(Object email) {
    return 'Premium revocato a $email';
  }

  @override
  String adminSnackDeleted(Object email) {
    return 'Account $email eliminato';
  }

  @override
  String adminError(Object message) {
    return 'Errore: $message';
  }

  @override
  String adminPaginationOf(Object from, Object to, Object total) {
    return '$from–$to di $total';
  }

  @override
  String get adminEmptyList => 'Nessun utente trovato';

  @override
  String get adminMenuLink => 'Pannello admin';

  @override
  String get paywallTitle => 'Piano gratuito al limite';

  @override
  String get paywallBody =>
      'Hai raggiunto il numero massimo di schede del piano gratuito. Premium toglie il limite e le pubblicità sull\'app mobile per sempre.';

  @override
  String get paywallPriceHint =>
      'Premium 4,99€ una tantum — disponibile presto su mobile e web.';

  @override
  String get paywallOk => 'Ho capito';

  @override
  String get aboutSectionTitle => 'Informazioni';

  @override
  String get aboutPlanFree => 'Piano attuale: Gratuito (fino a 2 schede)';

  @override
  String get aboutPlanPremium => 'Piano attuale: Premium';

  @override
  String get aboutPremiumComing =>
      'Premium 4,99€ una tantum sarà disponibile presto: rimuove il limite delle schede e le pubblicità sull\'app mobile.';

  @override
  String get aboutSrdCredit =>
      'I dati degli incantesimi derivano dal D&D 5.1 SRD (CC BY 4.0) di Wizards of the Coast. Questa app non è affiliata né approvata da Wizards of the Coast.';

  @override
  String get sheetSectionAbilities => 'Caratteristiche';

  @override
  String get sheetSectionSavesSkills => 'Tiri salvezza & abilità';

  @override
  String get sheetSectionCombat => 'Combattimento';

  @override
  String get sheetSectionSpells => 'Incantesimi';

  @override
  String get sheetSectionEquipment => 'Equipaggiamento';

  @override
  String get sheetSectionTraits => 'Tratti';

  @override
  String get sheetSectionNotes => 'Note';

  @override
  String get sheetHeaderBackground => 'Background';

  @override
  String get sheetHeaderAlignment => 'Allineamento';

  @override
  String get sheetHpLabel => 'HP';

  @override
  String get sheetAbilityStr => 'Forza';

  @override
  String get sheetAbilityDex => 'Destrezza';

  @override
  String get sheetAbilityCon => 'Costituzione';

  @override
  String get sheetAbilityInt => 'Intelligenza';

  @override
  String get sheetAbilityWis => 'Saggezza';

  @override
  String get sheetAbilityCha => 'Carisma';

  @override
  String get sheetSavingThrowsLabel => 'Tiri salvezza';

  @override
  String get sheetSkillsLabel => 'Abilità';

  @override
  String get sheetCombatAc => 'Classe Armatura';

  @override
  String get sheetCombatInitiative => 'Iniziativa';

  @override
  String get sheetCombatSpeed => 'Velocità';

  @override
  String get sheetCombatProfBonus => 'Bonus comp.';

  @override
  String get sheetCombatHitDice => 'Dadi vita';

  @override
  String get sheetCombatDeathSaves => 'TS morte';

  @override
  String sheetCombatDeathSavesValue(Object s, Object f) {
    return 'OK $s / KO $f';
  }

  @override
  String get sheetSpellsClass => 'Classe';

  @override
  String get sheetSpellsSaveDc => 'CD TS';

  @override
  String get sheetSpellsAttackBonus => 'Bonus attacco';

  @override
  String get sheetSpellsSlotsByLevel => 'Slot per livello';

  @override
  String get sheetSpellsKnown => 'Incantesimi conosciuti';

  @override
  String get sheetSpellCantrip => 'trucchetto';

  @override
  String sheetSpellLevelShort(Object n) {
    return 'Liv $n';
  }

  @override
  String get sheetSpellAlwaysPrepared => 'Sempre preparato';

  @override
  String get sheetSpellPrepared => 'Preparato';

  @override
  String get sheetEquipmentInventory => 'Inventario';

  @override
  String get sheetTraitsPersonality => 'Tratti caratteriali';

  @override
  String get sheetTraitsIdeals => 'Ideali';

  @override
  String get sheetTraitsBonds => 'Legami';

  @override
  String get sheetTraitsFlaws => 'Difetti';

  @override
  String get sheetTraitsLanguages => 'Lingue';

  @override
  String get sheetTraitsArmor => 'Armature';

  @override
  String get sheetTraitsWeapons => 'Armi';

  @override
  String get sheetTraitsTools => 'Strumenti';

  @override
  String get sheetTraitsFeatures => 'Privilegi & tratti';

  @override
  String get sheetNotesBackstory => 'Background';

  @override
  String get sheetNotesAllies => 'Alleati & organizzazioni';

  @override
  String get sheetNotesSymbol => 'Simbolo';

  @override
  String get sheetNotesPhysical => 'Aspetto fisico';

  @override
  String get sheetNotesNotes => 'Note';

  @override
  String get sharedInvalidLink => 'Link non valido o revocato.';

  @override
  String get shareDialogTitle => 'Condividi scheda';

  @override
  String get shareDialogIntro =>
      'Genera un link pubblico read-only per mostrare la scheda al DM. Chiunque conosca il link può vederla (no login). Puoi revocarlo in ogni momento.';

  @override
  String get shareDialogPublicLink => 'Link pubblico:';

  @override
  String get shareDialogCopyHint =>
      'Copia questo link ora — non sarà più visualizzabile dopo aver chiuso il dialog.';

  @override
  String get shareDialogCopiedSnack => 'Link copiato';

  @override
  String get shareDialogCopy => 'Copia';

  @override
  String get shareDialogRevoke => 'Revoca';

  @override
  String get shareDialogActive => 'Link attivo';

  @override
  String shareDialogGeneratedAt(Object date) {
    return 'Generato il $date.';
  }

  @override
  String get shareDialogLostHint =>
      'Il link in chiaro non è recuperabile. Se l\'hai perso, rigenera un nuovo link (il vecchio viene revocato automaticamente).';

  @override
  String get shareDialogRegenerate => 'Rigenera link';

  @override
  String get shareDialogGenerate => 'Genera link di condivisione';

  @override
  String get customSpellDialogTitleNew => 'Nuovo incantesimo custom';

  @override
  String get customSpellDialogTitleEdit => 'Modifica incantesimo';

  @override
  String get customSpellFieldName => 'Nome';

  @override
  String get customSpellFieldLevel => 'Livello';

  @override
  String get customSpellFieldLevelHelper => '0 = trucchetto';

  @override
  String get customSpellFieldSchool => 'Scuola';

  @override
  String get customSpellFieldCastingTime => 'Casting time';

  @override
  String get customSpellHintCastingTime => 'es. 1 action';

  @override
  String get customSpellFieldRange => 'Range';

  @override
  String get customSpellHintRange => 'es. 60 feet';

  @override
  String get customSpellFieldDuration => 'Duration';

  @override
  String get customSpellHintDuration => 'es. Instantaneous, 1 minute';

  @override
  String get customSpellComponents => 'Componenti';

  @override
  String get customSpellMaterials => 'Materiali';

  @override
  String get customSpellMaterialsHint => 'es. una piuma di phoenix';

  @override
  String get customSpellConcentration => 'Concentration';

  @override
  String get customSpellRitual => 'Ritual';

  @override
  String get customSpellClasses => 'Classi';

  @override
  String get customSpellDescription => 'Descrizione';

  @override
  String get customSpellHigherLevels => 'At Higher Levels';

  @override
  String get abilityShortStr => 'FOR';

  @override
  String get abilityShortDex => 'DES';

  @override
  String get abilityShortCon => 'COS';

  @override
  String get abilityShortInt => 'INT';

  @override
  String get abilityShortWis => 'SAG';

  @override
  String get abilityShortCha => 'CAR';

  @override
  String get skillAcrobatics => 'Acrobazia';

  @override
  String get skillAnimalHandling => 'Addestrare animali';

  @override
  String get skillArcana => 'Arcano';

  @override
  String get skillAthletics => 'Atletica';

  @override
  String get skillDeception => 'Inganno';

  @override
  String get skillHistory => 'Storia';

  @override
  String get skillInsight => 'Intuizione';

  @override
  String get skillIntimidation => 'Intimidire';

  @override
  String get skillInvestigation => 'Indagare';

  @override
  String get skillMedicine => 'Medicina';

  @override
  String get skillNature => 'Natura';

  @override
  String get skillPerception => 'Percezione';

  @override
  String get skillPerformance => 'Intrattenere';

  @override
  String get skillPersuasion => 'Persuasione';

  @override
  String get skillReligion => 'Religione';

  @override
  String get skillSleightOfHand => 'Rapidità di mano';

  @override
  String get skillStealth => 'Furtività';

  @override
  String get skillSurvival => 'Sopravvivenza';

  @override
  String get conditionBlinded => 'Accecato';

  @override
  String get conditionBlindedDesc =>
      'Una creatura accecata non può vedere e fallisce automaticamente qualsiasi prova di caratteristica che richieda la vista. I tiri per colpire contro di essa hanno vantaggio, i suoi tiri per colpire hanno svantaggio.';

  @override
  String get conditionCharmed => 'Affascinato';

  @override
  String get conditionCharmedDesc =>
      'Una creatura affascinata non può attaccare l\'incantatore né bersagliarlo con abilità o effetti magici dannosi. L\'incantatore ha vantaggio sulle prove di caratteristica sociali contro di essa.';

  @override
  String get conditionDeafened => 'Assordato';

  @override
  String get conditionDeafenedDesc =>
      'Una creatura assordata non può udire e fallisce automaticamente qualsiasi prova di caratteristica che richieda l\'udito.';

  @override
  String get conditionFrightened => 'Spaventato';

  @override
  String get conditionFrightenedDesc =>
      'Una creatura spaventata ha svantaggio a prove di caratteristica e tiri per colpire mentre la fonte della paura è nella sua linea di vista. Non può volontariamente avvicinarsi alla fonte della paura.';

  @override
  String get conditionGrappled => 'Afferrato';

  @override
  String get conditionGrappledDesc =>
      'Una creatura afferrata ha velocità 0 e non può beneficiare di alcun bonus alla velocità. La condizione termina se chi afferra è incapacitato o se la creatura viene spostata fuori dalla portata.';

  @override
  String get conditionIncapacitated => 'Incapacitato';

  @override
  String get conditionIncapacitatedDesc =>
      'Una creatura incapacitata non può eseguire azioni né reazioni.';

  @override
  String get conditionInvisible => 'Invisibile';

  @override
  String get conditionInvisibleDesc =>
      'Una creatura invisibile è impossibile da vedere senza l\'aiuto di magia o senso speciale. Per nascondersi è considerata pesantemente nascosta. I tiri per colpire contro di essa hanno svantaggio, i suoi tiri per colpire hanno vantaggio.';

  @override
  String get conditionParalyzed => 'Paralizzato';

  @override
  String get conditionParalyzedDesc =>
      'Una creatura paralizzata è incapacitata, non può muoversi né parlare. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio. Qualsiasi colpo entro 1,5 m è un colpo critico.';

  @override
  String get conditionPetrified => 'Pietrificato';

  @override
  String get conditionPetrifiedDesc =>
      'Una creatura pietrificata è trasformata in solida sostanza inanimata. È incapacitata, peso x10, non invecchia. I tiri per colpire contro di essa hanno vantaggio. Resistenza a tutti i danni, immune a veleno e malattia.';

  @override
  String get conditionPoisoned => 'Avvelenato';

  @override
  String get conditionPoisonedDesc =>
      'Una creatura avvelenata ha svantaggio a tiri per colpire e prove di caratteristica.';

  @override
  String get conditionProne => 'Prono';

  @override
  String get conditionProneDesc =>
      'Una creatura prona può solo strisciare. Ha svantaggio ai tiri per colpire. I tiri per colpire contro di essa hanno vantaggio se l\'attaccante è entro 1,5 m, svantaggio altrimenti.';

  @override
  String get conditionRestrained => 'Trattenuto';

  @override
  String get conditionRestrainedDesc =>
      'Una creatura trattenuta ha velocità 0 e non può beneficiare di alcun bonus alla velocità. I tiri per colpire contro di essa hanno vantaggio, i suoi tiri per colpire hanno svantaggio. Svantaggio ai TS di Destrezza.';

  @override
  String get conditionStunned => 'Stordito';

  @override
  String get conditionStunnedDesc =>
      'Una creatura stordita è incapacitata, non può muoversi e può solo parlare a fatica. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio.';

  @override
  String get conditionUnconscious => 'Privo di sensi';

  @override
  String get conditionUnconsciousDesc =>
      'Una creatura priva di sensi è incapacitata, non può muoversi né parlare, e ignora l\'ambiente. Lascia cadere ciò che tiene e cade prona. Fallisce automaticamente i TS su Forza e Destrezza. I tiri per colpire contro di essa hanno vantaggio. Qualsiasi colpo entro 1,5 m è un colpo critico.';

  @override
  String get conditionExhaustion => 'Esausto';

  @override
  String get conditionExhaustionDesc =>
      'L\'esaurimento ha 6 livelli con effetti cumulativi. Livello 1: svantaggio alle prove di caratteristica. Livello 2: velocità dimezzata. Livello 3: svantaggio ai tiri per colpire e TS. Livello 4: HP massimi dimezzati. Livello 5: velocità 0. Livello 6: morte.';

  @override
  String get diceTitle => 'Dice roller';

  @override
  String get diceFormulaLabel => 'Formula (es. 1d20+5, 3d6+1d4)';

  @override
  String get diceAdvantage => 'Vantaggio';

  @override
  String get diceDisadvantage => 'Svantaggio';

  @override
  String get diceRollButton => 'Tira';

  @override
  String get diceHistory => 'Cronologia';

  @override
  String get diceClear => 'Pulisci';

  @override
  String get diceNoRollsYet => '— nessun tiro ancora —';

  @override
  String get diceNoOtherRolls => '— nessun altro tiro —';

  @override
  String get spellPickerTitle => 'Catalogo SRD';

  @override
  String get spellPickerSearchHint => 'Cerca per nome (es. "fire")';

  @override
  String get spellFilterLevelHint => 'Livello';

  @override
  String get spellFilterLevelAll => 'Livello: tutti';

  @override
  String get spellFilterCantrips => 'Trucchetti';

  @override
  String spellFilterLevelN(Object n) {
    return 'Liv. $n';
  }

  @override
  String get spellFilterSchoolHint => 'Scuola';

  @override
  String get spellFilterSchoolAll => 'Scuola: tutte';

  @override
  String get spellFilterClassHint => 'Classe';

  @override
  String get spellFilterClassAll => 'Classe: tutte';

  @override
  String get spellPickerNoResults => 'Nessun risultato';

  @override
  String get spellPickerDetails => 'Dettagli';

  @override
  String get spellPickerAdd => 'Aggiungi alla scheda';

  @override
  String get editorToolbarShare => 'Condividi (link read-only)';

  @override
  String get editorPortraitChange => 'Cambia ritratto';

  @override
  String get editorPortraitUpload => 'Carica ritratto';

  @override
  String get editorPortraitUpdatedSnack => 'Ritratto aggiornato';

  @override
  String get editorPortraitRemovedSnack => 'Ritratto rimosso';

  @override
  String get autosaveFormInvalid => 'Form non valido — non salvato';

  @override
  String get editorAnagraficaName => 'Nome';

  @override
  String get editorAnagraficaLevel => 'Livello';

  @override
  String get editorAnagraficaRace => 'Razza';

  @override
  String get editorAnagraficaSubrace => 'Sotto-razza';

  @override
  String get editorAnagraficaClass => 'Classe';

  @override
  String get editorAnagraficaSubclass => 'Sotto-classe';

  @override
  String get editorAnagraficaExperience => 'Esperienza (XP)';

  @override
  String get editorAnagraficaInspiration => 'Ispirazione';

  @override
  String get editorStatsTitle => 'Punteggi caratteristica';

  @override
  String get editorStatsHint =>
      'Valori 1-30. Il modificatore (sotto al campo) si aggiorna automaticamente.';

  @override
  String get editorAbilityTooltipNeedsValue => 'Inserisci la statistica per tirare';

  @override
  String editorAbilityTooltipRoll(Object formula, Object ability) {
    return 'Tira $formula ($ability)';
  }

  @override
  String get editorColComp => 'Comp.';

  @override
  String get editorColExpert => 'Maest.';

  @override
  String get editorColTotal => 'Tot.';

  @override
  String get editorFlagOverrideTag => 'override';

  @override
  String get editorProfBonusOverrideTooltip => 'Override manuale (Combat)';

  @override
  String get editorProfBonusAutoTooltip => 'Calcolato dal livello';

  @override
  String editorProfBonusChipLabel(Object value) {
    return 'Comp $value';
  }

  @override
  String get editorCombatDefenseMovement => 'Difesa & movimento';

  @override
  String get editorCombatArmorClassLabel => 'Classe Armatura (CA)';

  @override
  String editorCombatHintAcAuto(Object value, Object ability) {
    return 'auto: $value (10 + $ability)';
  }

  @override
  String editorCombatHintInitAuto(Object value, Object ability) {
    return 'auto: $value (mod $ability)';
  }

  @override
  String get editorCombatSpeedLabel => 'Velocità (ft)';

  @override
  String get editorCombatProfBonusLabel => 'Bonus competenza';

  @override
  String editorCombatHintProfAuto(Object value) {
    return 'auto: $value (dal livello)';
  }

  @override
  String get editorCombatHpSectionTitle => 'Punti ferita';

  @override
  String get editorCombatHpMaxLabel => 'PF max';

  @override
  String get editorCombatHpCurrentLabel => 'PF attuali';

  @override
  String get editorCombatHitDiceTotalLabel => 'Totali';

  @override
  String get editorCombatHitDiceUsedLabel => 'Usati';

  @override
  String get editorCombatDeathSavesSectionTitle => 'Tiri salvezza contro morte';

  @override
  String get editorCombatDeathSavesSuccLabel => 'Successi (0-3)';

  @override
  String get editorCombatDeathSavesFailLabel => 'Fallimenti (0-3)';

  @override
  String get editorCombatConditionsTitle => 'Condizioni';

  @override
  String get editorCombatConditionsHint =>
      'Tocca il chip per attivare/disattivare. Tocca l\'icona ⓘ per la descrizione PHB.';

  @override
  String get editorCombatRestsTitle => 'Riposi';

  @override
  String get editorCombatRestsHint =>
      'Riposo breve: reset TS morte (e slot warlock se progressione warlock). Riposo lungo: HP=max, temp=0, slot pieni, dadi vita recuperati per metà.';

  @override
  String get editorHpDialogTitle => 'Modifica HP';

  @override
  String get editorHpQuantityLabel => 'Quantità';

  @override
  String get editorHpQuantityHint => 'es. 8';

  @override
  String get editorHpHeal => 'Cura';

  @override
  String get editorHpDamage => 'Danno';

  @override
  String get editorHpTempLabel => 'PF temporanei';

  @override
  String get editorHpTempHelper => 'Non si stackano: vale il valore più alto';

  @override
  String get editorHpTempApply => 'Applica PF temporanei';

  @override
  String get editorRestLong => 'Riposo lungo';

  @override
  String get editorRestShort => 'Riposo breve';

  @override
  String get editorRestLongBody =>
      'Verranno applicate: HP a max, PF temp a 0, slot incantesimi pieni, dadi vita recuperati per metà, tiri salvezza contro morte azzerati.';

  @override
  String get editorRestShortBody =>
      'Verranno azzerati i tiri salvezza contro morte. Se la progressione è warlock, gli slot tornano pieni.';

  @override
  String get editorRestLongConfirmTitle => 'Riposo lungo?';

  @override
  String get editorRestShortConfirmTitle => 'Riposo breve?';

  @override
  String get editorRestLongApplied => 'Riposo lungo applicato';

  @override
  String get editorRestShortApplied => 'Riposo breve applicato';

  @override
  String get editorSpellsCasterClassLabel => 'Classe incantatrice';

  @override
  String get editorSpellsSaveDcLabel => 'CD tiro salvezza';

  @override
  String get editorSpellsAttackLabel => 'Bonus attacco';

  @override
  String get editorSpellsSlotsHint =>
      'Lascia vuoti i livelli che non hai (non vengono inviati). Puoi precompilare dalla tabella PHB.';

  @override
  String get editorSpellsListTitle => 'Lista incantesimi';

  @override
  String get editorSpellsListHint =>
      'Aggiungi dal catalogo SRD (319 spell) o crea una custom homebrew.';

  @override
  String get editorSpellsAddFromCatalog => 'Aggiungi dal catalogo';

  @override
  String get editorSpellsCustomSpell => 'Custom spell';

  @override
  String get editorSpellsConvertTitle => 'Personalizza incantesimo';

  @override
  String get editorSpellsConvertBody =>
      'Verrà copiato dal catalogo e diventerà una custom modificabile. La connessione al catalogo SRD viene persa.';

  @override
  String get editorSpellsConvertConfirm => 'Personalizza';

  @override
  String get editorSpellsProgressionLabel => 'Progressione (PHB)';

  @override
  String get editorSpellsFillFromPhb => 'Compila da PHB';

  @override
  String editorSpellsPrefillerPreview(Object level, Object slots) {
    return 'Anteprima a livello $level: $slots';
  }

  @override
  String get editorSpellsNoSlotsAtLevel => 'nessuno slot a questo livello';

  @override
  String get editorSpellsSetLevelFirst =>
      'Imposta prima il livello del personaggio nella tab Anagrafica.';

  @override
  String get editorSpellsFillConfirmTitle => 'Compilare gli slot?';

  @override
  String get editorSpellsFillConfirmBody =>
      'I valori "Max" verranno sovrascritti dalla tabella PHB. Il numero corrente verrà allineato al nuovo max.';

  @override
  String get editorSpellsFillConfirmYes => 'Compila';

  @override
  String get editorSpellsFillSnack => 'Slot precompilati';

  @override
  String editorSpellsSlotLevel(Object n) {
    return 'Livello $n';
  }

  @override
  String get editorSpellsSlotMax => 'Max';

  @override
  String get editorSpellsNoSlotsLine => '— nessuno slot —';

  @override
  String get editorSpellsConsumeSlot => 'Consuma slot';

  @override
  String get editorSpellsRestoreSlot => 'Ripristina slot';

  @override
  String get editorSpellsLevelChipCantrip => 'Trucc.';

  @override
  String editorSpellsLevelChipLvl(Object n) {
    return 'L$n';
  }

  @override
  String editorSpellsFromCatalog(Object source) {
    return 'Dal catalogo ($source)';
  }

  @override
  String get editorSpellsCustomHomebrewTooltip => 'Custom homebrew';

  @override
  String get editorSpellsActionsTooltip => 'Azioni';

  @override
  String get editorSpellsAlwaysPreparedShort => 'Sempre prep.';

  @override
  String get editorSpellsNotesLabel => 'Note (per la scheda)';

  @override
  String get editorSpellProgressionNone => 'Nessuna';

  @override
  String get editorSpellProgressionFull => 'Incantatore pieno (Mago, Chierico, …)';

  @override
  String get editorSpellProgressionHalf => 'Mezzo incantatore (Paladino, Ranger)';

  @override
  String get editorSpellProgressionThird => 'Terzo incantatore (Trickster, Eldritch)';

  @override
  String get editorSpellProgressionWarlock => 'Warlock (Pact Magic)';

  @override
  String get editorEquipCoinsTitle => 'Monete';

  @override
  String get editorEquipAddItem => 'Aggiungi oggetto';

  @override
  String get editorEquipItemName => 'Oggetto';

  @override
  String get editorEquipItemQty => 'Quantità';

  @override
  String get editorEquipItemWeight => 'Peso (lb)';

  @override
  String get editorEquipItemNotes => 'Note';

  @override
  String get editorTraitsProficienciesTitle => 'Competenze';

  @override
  String get editorTraitsFeaturesFieldLabel => 'Privilegi/tratti';

  @override
  String get editorTraitsLanguagesNone => '— nessuna —';

  @override
  String get editorTraitsAddLanguageLabel => 'Aggiungi lingua';

  @override
  String get editorNotesBackstoryLabel => 'Background storia';

  @override
  String get editorNotesNotesLabel => 'Note libere';

  @override
  String get editorNotAuthError => 'Utente non autenticato';

  @override
  String get editorValidatorEnterNumber => 'Inserisci un numero';

  @override
  String get editorValidatorMinZero => 'Deve essere ≥ 0';

  @override
  String editorValidatorMinN(Object n) {
    return 'Min $n';
  }

  @override
  String editorValidatorMaxN(Object n) {
    return 'Max $n';
  }

  @override
  String get comingSoonTitle => 'Lavori in corso';

  @override
  String get comingSoonStayTuned =>
      'Stiamo lavorando per renderla disponibile a breve. Torna a trovarci.';

  @override
  String get comingSoonIos =>
      "L'app per iPhone e iPad arriverà presto sull'App Store.";

  @override
  String get comingSoonAndroid =>
      "L'app per Android arriverà presto sul Google Play Store.";

  @override
  String get comingSoonSpells =>
      'Il catalogo pubblico degli incantesimi sarà presto consultabile senza account.';

  @override
  String get comingSoonGeneric => 'Questa sezione è in lavorazione.';

  @override
  String get comingSoonBack => 'Torna alla home';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Termini di Servizio';

  @override
  String get legalCookiesTitle => 'Politica sui Cookie';

  @override
  String get legalContactTitle => 'Contatti';

  @override
  String legalLastUpdated(String date) => 'Ultimo aggiornamento: $date';

  @override
  String get legalOnlyItalianNotice =>
      'I testi legali sono pubblicati in italiano. La versione in lingua italiana è quella ufficiale.';

  @override
  String get legalBackToHome => 'Torna alla home';

  @override
  String get registerAcceptPart1 => 'Ho letto e accetto la ';

  @override
  String get registerAcceptPart2 => ' e i ';

  @override
  String get registerAcceptPart3 => '.';

  @override
  String get registerPrivacyLink => 'Privacy Policy';

  @override
  String get registerTermsLink => 'Termini di Servizio';

  @override
  String get registerAcceptRequired =>
      'Devi accettare la Privacy Policy e i Termini di Servizio per registrarti';

  @override
  String get profilePrivacySectionTitle => 'Privacy e dati';

  @override
  String get profilePrivacyHint =>
      'Scarica una copia completa dei tuoi dati personali in formato JSON, oppure consulta la nostra Privacy Policy.';

  @override
  String get profileExportButton => 'Esporta i miei dati';

  @override
  String get profileExportInProgress => 'Preparazione export in corso…';

  @override
  String get profileExportDone => 'Esportazione completata.';

  @override
  String profileExportFailed(String error) => 'Esportazione fallita: $error';

  @override
  String get profileLegalPrivacyLink => 'Privacy Policy';

  @override
  String get profileLegalTermsLink => 'Termini di Servizio';

  @override
  String get profileLegalCookiesLink => 'Cookie';

  @override
  String get profileLegalContactLink => 'Contatti';

  @override
  String get deletionInfoTitle => 'Come cancellare il tuo account';
  @override
  String get deletionInfoIntro =>
      'Puoi cancellare il tuo account e tutti i dati associati in qualsiasi momento. '
      'La cancellazione è immediata e irreversibile.';
  @override
  String get deletionInfoStepsTitle => 'Procedura standard';
  @override
  String get deletionInfoStep1 => 'Accedi al tuo account.';
  @override
  String get deletionInfoStep2 => 'Vai su Profilo → sezione "Danger zone" in fondo alla pagina.';
  @override
  String get deletionInfoStep3 => 'Premi "Cancella account".';
  @override
  String get deletionInfoStep4 =>
      'Digita il tuo username e la password per conferma, poi premi il bottone rosso.';
  @override
  String get deletionInfoWhatRemovedTitle => 'Cosa viene cancellato';
  @override
  String get deletionInfoWhatRemoved =>
      'Tutti i seguenti dati vengono rimossi in modo definitivo, senza possibilità di recupero:';
  @override
  String get deletionInfoBullet1 => 'Account, email, password (hash), foto del profilo.';
  @override
  String get deletionInfoBullet2 => 'Tutte le tue schede personaggio e le immagini dei ritratti.';
  @override
  String get deletionInfoBullet3 => 'Cronologia dei tiri di dado.';
  @override
  String get deletionInfoBullet4 => 'Tutti i link di condivisione attivi delle tue schede.';
  @override
  String get deletionInfoBullet5 => 'Tutte le sessioni attive su qualsiasi dispositivo.';
  @override
  String get deletionInfoCannotLoginTitle => 'Non riesci ad accedere?';
  @override
  String get deletionInfoCannotLogin =>
      'Se hai perso le credenziali e non riesci a fare il reset password, scrivici '
      "un'email all'indirizzo qui sotto specificando l'indirizzo email del tuo account. "
      'Ti aiuteremo a procedere con la cancellazione dopo aver verificato la tua identità.';
  @override
  String get deletionInfoEmail => 'franksisca@gmail.com';
  @override
  String get deletionInfoLoginBtn => 'Accedi e cancella';
  @override
  String get deletionInfoBackHome => 'Torna alla home';
}
