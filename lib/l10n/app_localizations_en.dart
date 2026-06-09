// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PG 5e';

  @override
  String get navHome => 'Home';

  @override
  String get navCharacters => 'Your characters';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSharedSheet => 'Shared character';

  @override
  String get navCharacterEditor => 'Character sheet';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionExport => 'Export';

  @override
  String get actionImport => 'Import';

  @override
  String get actionShare => 'Share';

  @override
  String get actionLogout => 'Sign out';

  @override
  String get actionClose => 'Close';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionBack => 'Back';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionReload => 'Reload';

  @override
  String get actionGoHome => 'Go to home';

  @override
  String get actionBackHome => 'Back to home';

  @override
  String commonErrorPrefix(Object message) {
    return 'Error: $message';
  }

  @override
  String commonNetworkError(Object message) {
    return 'Network error: $message';
  }

  @override
  String get commonRequired => 'Required';

  @override
  String commonMaxChars(Object n) {
    return 'Max $n characters';
  }

  @override
  String commonMinChars(Object n) {
    return 'At least $n characters';
  }

  @override
  String get commonNotAuthenticated => 'You are not signed in.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageSectionTitle => 'App language';

  @override
  String get languageSectionHint =>
      'Switch the interface between Italian and English. \"System\" follows your device settings.';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get languageSystem => 'System';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Sign up';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authNeedAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authBtnLogin => 'Sign in';

  @override
  String get authBtnRegister => 'Create account';

  @override
  String get authOrDivider => 'or';

  @override
  String get loginGoogleNeedsRegister =>
      'To sign in with Google the first time you need to register accepting the Terms.';

  @override
  String get googleCompleteTitle => 'Complete your registration';

  @override
  String get googleCompleteIntro =>
      'Pick a username and accept the terms to continue with Google.';

  @override
  String get googleCompleteUsernameTaken =>
      'This username is already taken, please choose another.';

  @override
  String get authCheckEmailTitle => 'Check your email';

  @override
  String authCheckEmailBody(Object email) {
    return 'We sent a verification link to $email.';
  }

  @override
  String get landingWelcome => 'Welcome';

  @override
  String get landingTagline =>
      'Manage your character sheets for 5e fantasy role-playing games.';

  @override
  String get landingCreateAccount => 'Create an account';

  @override
  String get landingSignIn => 'Sign in';

  @override
  String get landingHeroEyebrow => 'Chronicles of a 5e adventurer';

  @override
  String get landingHeroTitle => 'Forge your hero.\nLive your legend.';

  @override
  String get landingHeroSubtitle =>
      'Keep every sheet, roll every die, share the deeds of your character — a digital companion for your 5e role-playing adventures.';

  @override
  String get landingCtaOpenWeb => 'Enter your library';

  @override
  String get landingCtaOpenWebSub => 'Already have an account? Sign in.';

  @override
  String get landingCtaAppStore => 'Download on the App Store';

  @override
  String get landingCtaGooglePlay => 'Get it on Google Play';

  @override
  String get landingCtaStorePrefix => 'Soon';

  @override
  String get landingCtaSpellsPrefix => 'Open';

  @override
  String get landingCtaSpells => 'Browse the spell codex';

  @override
  String get landingCtaSpellsSub =>
      'Public SRD catalog, 319 spells translated into Italian';

  @override
  String get landingFeaturesTitle => 'The Chronicler\'s arts';

  @override
  String get landingFeaturesSubtitle =>
      'Everything an adventurer needs, gathered in a single grimoire.';

  @override
  String get landingFeatureSheetTitle => 'Character scroll';

  @override
  String get landingFeatureSheetDesc =>
      'Every field from the 5e core rulebook, eight dedicated sections, automatic calculations. No detail of your hero gets lost.';

  @override
  String get landingFeatureDiceTitle => 'Fate of the dice';

  @override
  String get landingFeatureDiceDesc =>
      'Built-in dice roller, HP tracking, spell slots, conditions and rests at your fingertips.';

  @override
  String get landingFeatureShareTitle => 'Shared sagas';

  @override
  String get landingFeatureShareDesc =>
      'A read-only link for your Dungeon Master and party. Revocable in an instant, always yours.';

  @override
  String get landingFeatureSpellsTitle => 'Spell codex';

  @override
  String get landingFeatureSpellsDesc =>
      '319 spells from the SRD 5.1, fast search, complete descriptions in Italian and English.';

  @override
  String get landingFooterLegal => 'Legal';

  @override
  String get landingFooterPrivacy => 'Privacy';

  @override
  String get landingFooterTerms => 'Terms';

  @override
  String get landingFooterContact => 'Contact';

  @override
  String get landingImageCredit =>
      'Background illustration: Placidplace via Pixabay.';

  @override
  String get landingMadeBy => 'Made by Zaknafein';

  @override
  String get commonBack => 'Back';

  @override
  String get loginAccessTitle => 'Sign in';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginEmailInvalid => 'Invalid email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginGoRegister => 'Don\'t have an account? Sign up';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNetworkError => 'Network error';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordIntro =>
      'Enter your email: if the account exists and is verified, we will send you a link to set a new password.';

  @override
  String get forgotPasswordSubmit => 'Send reset link';

  @override
  String get forgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get forgotPasswordSentTitle => 'Check your email';

  @override
  String get forgotPasswordSentBodyStart => 'If an account exists for ';

  @override
  String get forgotPasswordSentBodyEnd =>
      ', you will soon receive a link to reset your password. The link is valid for 1 hour.';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordIntro =>
      'Choose a new password. All devices where you are currently signed in will be signed out.';

  @override
  String get resetPasswordSubmit => 'Set new password';

  @override
  String get resetPasswordDoneTitle => 'Password updated!';

  @override
  String get resetPasswordDoneBody =>
      'Your password has been reset. You can now sign in with the new one.';

  @override
  String get resetPasswordMissingToken =>
      'Invalid link: missing token. Please request a new reset link.';

  @override
  String get resetPasswordRequestNew => 'Request new link';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerEmailRequired => 'Enter your email';

  @override
  String get registerEmailInvalid => 'Invalid email';

  @override
  String get registerPasswordRequired => 'Enter a password';

  @override
  String get registerPasswordMin => 'At least 10 characters';

  @override
  String get registerPasswordMax => 'Max 100 characters';

  @override
  String get registerPasswordUpper =>
      'At least one uppercase letter is required';

  @override
  String get registerPasswordDigit => 'At least one digit is required';

  @override
  String get registerPasswordsMismatch => 'Passwords do not match';

  @override
  String get registerUsernameRequired => 'Enter a username';

  @override
  String get registerUsernameMin => 'At least 3 characters';

  @override
  String get registerUsernameMax => 'Max 30 characters';

  @override
  String get registerUsernameChars => 'Letters, digits and underscore only';

  @override
  String get registerUsernameHelper =>
      'Letters, digits and underscore only (3-30)';

  @override
  String get registerDisplayRequired => 'Enter a display name';

  @override
  String get registerDisplayMax => 'Max 60 characters';

  @override
  String get registerPasswordHelper =>
      'At least 10 characters, 1 uppercase, 1 digit';

  @override
  String get registerPasswordShow => 'Show password';

  @override
  String get registerPasswordHide => 'Hide password';

  @override
  String get registerConfirmLabel => 'Confirm password';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get checkEmailHeader => 'We sent you an email';

  @override
  String get checkEmailBodyStart =>
      'To activate your account, open the link we sent to ';

  @override
  String get checkEmailBodyEnd => '. The link is valid for 24 hours.';

  @override
  String get verifyEmailTitle => 'Email verification';

  @override
  String get verifyEmailWaiting => 'Verifying your email address…';

  @override
  String get verifyEmailFailed => 'Verification failed';

  @override
  String verifyEmailUnexpected(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get verifyEmailOk => 'Email verified!';

  @override
  String get verifyEmailOkBody =>
      'Your account is now active. You can sign in from the home page.';

  @override
  String homeGreeting(Object name) {
    return 'Hi, $name!';
  }

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileAvatarChange => 'Change avatar';

  @override
  String get profileAvatarRemove => 'Remove';

  @override
  String get profileEmailHelper => 'Email cannot be changed';

  @override
  String get profileUsernameHelper => 'Username cannot be changed';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileSaveBtn => 'Save profile';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profilePasswordChangedLogout =>
      'Password changed. Please sign in again.';

  @override
  String get changePwdTitle => 'Change password';

  @override
  String get changePwdCurrentLabel => 'Current password';

  @override
  String get changePwdNewLabel => 'New password';

  @override
  String get changePwdNewHelper =>
      'At least 10 characters, 1 uppercase, 1 digit';

  @override
  String get changePwdConfirmLabel => 'Confirm new password';

  @override
  String get changePwdRequired => 'Required';

  @override
  String get changePwdNewRequired => 'Enter a new password';

  @override
  String get changePwdMustDiffer => 'Must be different from the current one';

  @override
  String get changePwdSubmit => 'Change';

  @override
  String get changePwdLogoutWarning =>
      'After changing the password you will be signed out and need to sign in again.';

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get deleteAccountHint =>
      'Deletion is permanent: profile, all characters, share links, and roll history are removed.';

  @override
  String get deleteAccountButton => 'Delete my account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountWarning => 'This action is IRREVERSIBLE.';

  @override
  String get deleteAccountBullets =>
      'We will delete: your profile (email, username, avatar), all character sheets with their portraits, all share links (anyone with the link will no longer see anything), the dice roll history. Username and email will become available again for new registrations.';

  @override
  String deleteAccountTypeUsername(Object username) {
    return 'Type your username ($username) to confirm';
  }

  @override
  String get deleteAccountUsernameMismatch => 'Username does not match';

  @override
  String get deleteAccountPasswordLabel => 'Current password';

  @override
  String get deleteAccountConfirmBtn => 'Permanently delete';

  @override
  String get deleteAccountDoneSnack => 'Account deleted. Goodbye.';

  @override
  String get charactersEmpty => 'No characters yet.';

  @override
  String get charactersEmptyHint => 'Tap \"+ New character\" to create one.';

  @override
  String get charactersNewBtn => 'New character';

  @override
  String get charactersNoName => '(unnamed)';

  @override
  String get charactersImportTooltip => 'Import…';

  @override
  String get charactersImportJson => 'Import native JSON';

  @override
  String get charactersImportFoundry => 'Import FoundryVTT (dnd5e)';

  @override
  String get charactersActionsTooltip => 'Actions';

  @override
  String get charactersActionRename => 'Rename';

  @override
  String get charactersActionDuplicate => 'Duplicate';

  @override
  String get charactersActionExportJson => 'Export JSON';

  @override
  String get charactersActionExportFoundry => 'Export Foundry';

  @override
  String get charactersActionExportPdf => 'Export PDF';

  @override
  String get charactersActionDelete => 'Delete';

  @override
  String get charactersRenameDialogTitle => 'Rename character';

  @override
  String get charactersRenameLabel => 'New name';

  @override
  String get charactersDeleteDialogTitle => 'Delete this character?';

  @override
  String charactersDeleteDialogBody(Object name) {
    return 'This action cannot be undone.\nCharacter: $name';
  }

  @override
  String charactersLevelLabel(Object n) {
    return 'Level $n';
  }

  @override
  String get charactersSnackRenamed => 'Character renamed';

  @override
  String get charactersSnackDuplicated => 'Character duplicated';

  @override
  String get charactersSnackDeleted => 'Character deleted';

  @override
  String charactersSnackExported(Object filename) {
    return 'Exported: $filename';
  }

  @override
  String charactersSnackExportedFoundry(Object filename) {
    return 'Exported for Foundry (best-effort): $filename';
  }

  @override
  String charactersSnackExportedPdf(Object filename) {
    return 'Exported PDF: $filename';
  }

  @override
  String get charactersSnackImportedJson => 'Character imported';

  @override
  String get charactersSnackImportedFoundry =>
      'Character imported from Foundry (best-effort, please review)';

  @override
  String charactersErrorCreate(Object message) {
    return 'Create failed: $message';
  }

  @override
  String charactersErrorImport(Object message) {
    return 'Import failed: $message';
  }

  @override
  String charactersErrorJsonInvalid(Object message) {
    return 'Invalid JSON: $message';
  }

  @override
  String get charactersErrorJsonNotObject =>
      'File does not contain a JSON object';

  @override
  String get editorTabAnagrafica => 'Profile';

  @override
  String get editorTabStats => 'Stats';

  @override
  String get editorTabAbilities => 'Abilities';

  @override
  String get editorTabCombat => 'Combat';

  @override
  String get editorTabSpells => 'Spells';

  @override
  String get editorTabEquip => 'Equipment';

  @override
  String get editorTabTraits => 'Traits';

  @override
  String get editorTabNotes => 'Notes';

  @override
  String get autosaveIdle => 'Changes are saved automatically';

  @override
  String get autosaveSaving => 'Saving…';

  @override
  String autosaveSavedAt(Object time) {
    return 'Saved at $time';
  }

  @override
  String autosaveError(Object message) {
    return 'Error: $message';
  }

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminSearchHint => 'Search by email, username or display name';

  @override
  String get adminColEmail => 'Email';

  @override
  String get adminColUsername => 'Username';

  @override
  String get adminColDisplay => 'Name';

  @override
  String get adminColTier => 'Plan';

  @override
  String get adminColRoles => 'Roles';

  @override
  String get adminColCreated => 'Joined';

  @override
  String get adminColActions => 'Actions';

  @override
  String get adminTierFree => 'Free';

  @override
  String get adminTierPremium => 'Premium';

  @override
  String get adminRoleAdmin => 'ADMIN';

  @override
  String get adminActionGrant => 'Grant Premium';

  @override
  String get adminActionRevoke => 'Revoke Premium';

  @override
  String get adminActionDelete => 'Delete account';

  @override
  String get adminDeleteConfirmTitle => 'Confirm deletion';

  @override
  String adminDeleteConfirmBody(Object email) {
    return 'This will permanently delete the account $email with all its data. Continue?';
  }

  @override
  String get adminDeleteConfirmYes => 'Yes, delete';

  @override
  String get adminDeleteConfirmNo => 'Cancel';

  @override
  String adminSnackGranted(Object email) {
    return 'Premium granted to $email';
  }

  @override
  String adminSnackRevoked(Object email) {
    return 'Premium revoked from $email';
  }

  @override
  String adminSnackDeleted(Object email) {
    return 'Account $email deleted';
  }

  @override
  String adminError(Object message) {
    return 'Error: $message';
  }

  @override
  String adminPaginationOf(Object from, Object to, Object total) {
    return '$from–$to of $total';
  }

  @override
  String get adminEmptyList => 'No users found';

  @override
  String get adminMenuLink => 'Admin panel';

  @override
  String get paywallTitle => 'Free plan limit reached';

  @override
  String get paywallBody =>
      'You\'ve reached the maximum number of sheets on the free plan. Premium removes the limit and the ads on the mobile app forever.';

  @override
  String get paywallPriceHint =>
      'Secure payment. Lifetime: pay once, keep it forever.';

  @override
  String get paywallPriceHintComingSoon =>
      'Payments coming soon — the button will be enabled shortly.';

  @override
  String get paywallBuy => 'Buy €4.99';

  @override
  String get paywallClose => 'Cancel';

  @override
  String get billingAlreadyPremium => 'You\'re already Premium!';

  @override
  String get billingSuccessTitle => 'Payment received';

  @override
  String get billingSuccessWaiting => 'Confirming your payment…';

  @override
  String get billingSuccessPollAttempt => 'Just a few seconds';

  @override
  String get billingSuccessConfirmedTitle => 'You\'re Premium!';

  @override
  String get billingSuccessConfirmedBody =>
      'You can now create unlimited sheets.';

  @override
  String get billingSuccessCtaCharacters => 'Go to characters';

  @override
  String get billingSuccessPendingTitle => 'Payment processing';

  @override
  String get billingSuccessPendingBody =>
      'The payment is on its way to our servers. Check back in a few minutes: the purchase succeeded, your account will be updated soon.';

  @override
  String get billingSuccessCtaHome => 'Back to home';

  @override
  String get billingCancelTitle => 'Payment cancelled';

  @override
  String get billingCancelHeading => 'You didn\'t complete the payment';

  @override
  String get billingCancelBody =>
      'Nothing was charged. You can try again any time from the paywall.';

  @override
  String get billingCancelCtaHome => 'Back to home';

  @override
  String get aboutSectionTitle => 'About';

  @override
  String get aboutPlanFree => 'Current plan: Free (1 sheet)';

  @override
  String get aboutPlanPremium => 'Current plan: Premium';

  @override
  String get aboutPremiumComing =>
      'Premium €4.99 one-time will be available soon: removes the sheet limit and the ads on the mobile app.';

  @override
  String get aboutSrdCredit =>
      'Spell data is derived from the D&D 5.1 SRD (CC BY 4.0) by Wizards of the Coast. This app is not affiliated with or endorsed by Wizards of the Coast.';

  @override
  String get sheetSectionAbilities => 'Ability scores';

  @override
  String get sheetSectionSavesSkills => 'Saving throws & skills';

  @override
  String get sheetSectionCombat => 'Combat';

  @override
  String get sheetSectionSpells => 'Spells';

  @override
  String get sheetSectionEquipment => 'Equipment';

  @override
  String get sheetSectionTraits => 'Traits';

  @override
  String get sheetSectionNotes => 'Notes';

  @override
  String get sheetHeaderBackground => 'Background';

  @override
  String get sheetHeaderAlignment => 'Alignment';

  @override
  String get sheetHpLabel => 'HP';

  @override
  String get sheetAbilityStr => 'Strength';

  @override
  String get sheetAbilityDex => 'Dexterity';

  @override
  String get sheetAbilityCon => 'Constitution';

  @override
  String get sheetAbilityInt => 'Intelligence';

  @override
  String get sheetAbilityWis => 'Wisdom';

  @override
  String get sheetAbilityCha => 'Charisma';

  @override
  String get sheetSavingThrowsLabel => 'Saving throws';

  @override
  String get sheetSkillsLabel => 'Skills';

  @override
  String get sheetCombatAc => 'Armor Class';

  @override
  String get sheetCombatInitiative => 'Initiative';

  @override
  String get sheetCombatSpeed => 'Speed';

  @override
  String get sheetCombatProfBonus => 'Prof. bonus';

  @override
  String get sheetCombatHitDice => 'Hit dice';

  @override
  String get sheetCombatDeathSaves => 'Death saves';

  @override
  String sheetCombatDeathSavesValue(Object s, Object f) {
    return 'OK $s / Fail $f';
  }

  @override
  String get sheetSpellsClass => 'Class';

  @override
  String get sheetSpellsSaveDc => 'Save DC';

  @override
  String get sheetSpellsAttackBonus => 'Attack bonus';

  @override
  String get sheetSpellsSlotsByLevel => 'Slots per level';

  @override
  String get sheetSpellsKnown => 'Known spells';

  @override
  String get sheetSpellCantrip => 'cantrip';

  @override
  String sheetSpellLevelShort(Object n) {
    return 'Lv $n';
  }

  @override
  String get sheetSpellAlwaysPrepared => 'Always prepared';

  @override
  String get sheetSpellPrepared => 'Prepared';

  @override
  String get sheetEquipmentInventory => 'Inventory';

  @override
  String get sheetTraitsPersonality => 'Personality traits';

  @override
  String get sheetTraitsIdeals => 'Ideals';

  @override
  String get sheetTraitsBonds => 'Bonds';

  @override
  String get sheetTraitsFlaws => 'Flaws';

  @override
  String get sheetTraitsLanguages => 'Languages';

  @override
  String get sheetTraitsArmor => 'Armor';

  @override
  String get sheetTraitsWeapons => 'Weapons';

  @override
  String get sheetTraitsTools => 'Tools';

  @override
  String get sheetTraitsFeatures => 'Features & traits';

  @override
  String get sheetNotesBackstory => 'Backstory';

  @override
  String get sheetNotesAllies => 'Allies & organizations';

  @override
  String get sheetNotesSymbol => 'Symbol';

  @override
  String get sheetNotesPhysical => 'Physical description';

  @override
  String get sheetNotesNotes => 'Notes';

  @override
  String get sharedInvalidLink => 'Invalid or revoked link.';

  @override
  String get shareDialogTitle => 'Share sheet';

  @override
  String get shareDialogIntro =>
      'Generate a read-only public link to show the sheet to your DM. Anyone with the link can view it (no login required). You can revoke it anytime.';

  @override
  String get shareDialogPublicLink => 'Public link:';

  @override
  String get shareDialogCopyHint =>
      'Copy this link now — it won\'t be displayed again after closing the dialog.';

  @override
  String get shareDialogCopiedSnack => 'Link copied';

  @override
  String get shareDialogCopy => 'Copy';

  @override
  String get shareDialogRevoke => 'Revoke';

  @override
  String get shareDialogActive => 'Active link';

  @override
  String shareDialogGeneratedAt(Object date) {
    return 'Generated on $date.';
  }

  @override
  String get shareDialogLostHint =>
      'The plaintext link is not recoverable. If you lost it, generate a new link (the old one will be revoked automatically).';

  @override
  String get shareDialogRegenerate => 'Regenerate link';

  @override
  String get shareDialogGenerate => 'Generate share link';

  @override
  String get customSpellDialogTitleNew => 'New custom spell';

  @override
  String get customSpellDialogTitleEdit => 'Edit spell';

  @override
  String get customSpellFieldName => 'Name';

  @override
  String get customSpellFieldLevel => 'Level';

  @override
  String get customSpellFieldLevelHelper => '0 = cantrip';

  @override
  String get customSpellFieldSchool => 'School';

  @override
  String get customSpellFieldCastingTime => 'Casting time';

  @override
  String get customSpellHintCastingTime => 'e.g. 1 action';

  @override
  String get customSpellFieldRange => 'Range';

  @override
  String get customSpellHintRange => 'e.g. 60 feet';

  @override
  String get customSpellFieldDuration => 'Duration';

  @override
  String get customSpellHintDuration => 'e.g. Instantaneous, 1 minute';

  @override
  String get customSpellComponents => 'Components';

  @override
  String get customSpellMaterials => 'Materials';

  @override
  String get customSpellMaterialsHint => 'e.g. a phoenix feather';

  @override
  String get customSpellConcentration => 'Concentration';

  @override
  String get customSpellRitual => 'Ritual';

  @override
  String get customSpellClasses => 'Classes';

  @override
  String get customSpellDescription => 'Description';

  @override
  String get customSpellHigherLevels => 'At Higher Levels';

  @override
  String get abilityShortStr => 'STR';

  @override
  String get abilityShortDex => 'DEX';

  @override
  String get abilityShortCon => 'CON';

  @override
  String get abilityShortInt => 'INT';

  @override
  String get abilityShortWis => 'WIS';

  @override
  String get abilityShortCha => 'CHA';

  @override
  String get skillAcrobatics => 'Acrobatics';

  @override
  String get skillAnimalHandling => 'Animal Handling';

  @override
  String get skillArcana => 'Arcana';

  @override
  String get skillAthletics => 'Athletics';

  @override
  String get skillDeception => 'Deception';

  @override
  String get skillHistory => 'History';

  @override
  String get skillInsight => 'Insight';

  @override
  String get skillIntimidation => 'Intimidation';

  @override
  String get skillInvestigation => 'Investigation';

  @override
  String get skillMedicine => 'Medicine';

  @override
  String get skillNature => 'Nature';

  @override
  String get skillPerception => 'Perception';

  @override
  String get skillPerformance => 'Performance';

  @override
  String get skillPersuasion => 'Persuasion';

  @override
  String get skillReligion => 'Religion';

  @override
  String get skillSleightOfHand => 'Sleight of Hand';

  @override
  String get skillStealth => 'Stealth';

  @override
  String get skillSurvival => 'Survival';

  @override
  String get conditionBlinded => 'Blinded';

  @override
  String get conditionBlindedDesc =>
      'A blinded creature can\'t see and automatically fails any ability check that requires sight. Attack rolls against the creature have advantage, and the creature\'s attack rolls have disadvantage.';

  @override
  String get conditionCharmed => 'Charmed';

  @override
  String get conditionCharmedDesc =>
      'A charmed creature can\'t attack the charmer or target the charmer with harmful abilities or magical effects. The charmer has advantage on any ability check to interact socially with the creature.';

  @override
  String get conditionDeafened => 'Deafened';

  @override
  String get conditionDeafenedDesc =>
      'A deafened creature can\'t hear and automatically fails any ability check that requires hearing.';

  @override
  String get conditionFrightened => 'Frightened';

  @override
  String get conditionFrightenedDesc =>
      'A frightened creature has disadvantage on ability checks and attack rolls while the source of its fear is within line of sight. The creature can\'t willingly move closer to the source of its fear.';

  @override
  String get conditionGrappled => 'Grappled';

  @override
  String get conditionGrappledDesc =>
      'A grappled creature\'s speed becomes 0, and it can\'t benefit from any bonus to its speed. The condition ends if the grappler is incapacitated or if the creature is moved out of reach.';

  @override
  String get conditionIncapacitated => 'Incapacitated';

  @override
  String get conditionIncapacitatedDesc =>
      'An incapacitated creature can\'t take actions or reactions.';

  @override
  String get conditionInvisible => 'Invisible';

  @override
  String get conditionInvisibleDesc =>
      'An invisible creature is impossible to see without the aid of magic or a special sense. For the purpose of hiding, the creature is heavily obscured. Attack rolls against the creature have disadvantage, and the creature\'s attack rolls have advantage.';

  @override
  String get conditionParalyzed => 'Paralyzed';

  @override
  String get conditionParalyzedDesc =>
      'A paralyzed creature is incapacitated and can\'t move or speak. The creature automatically fails Strength and Dexterity saving throws. Attack rolls against the creature have advantage. Any attack that hits the creature is a critical hit if the attacker is within 5 feet.';

  @override
  String get conditionPetrified => 'Petrified';

  @override
  String get conditionPetrifiedDesc =>
      'A petrified creature is transformed into solid inanimate substance. It is incapacitated, weight x10, and ceases aging. Attack rolls against the creature have advantage. It has resistance to all damage and is immune to poison and disease.';

  @override
  String get conditionPoisoned => 'Poisoned';

  @override
  String get conditionPoisonedDesc =>
      'A poisoned creature has disadvantage on attack rolls and ability checks.';

  @override
  String get conditionProne => 'Prone';

  @override
  String get conditionProneDesc =>
      'A prone creature can only crawl. It has disadvantage on attack rolls. Attack rolls against the creature have advantage if the attacker is within 5 feet, otherwise disadvantage.';

  @override
  String get conditionRestrained => 'Restrained';

  @override
  String get conditionRestrainedDesc =>
      'A restrained creature\'s speed becomes 0, and it can\'t benefit from any bonus to its speed. Attack rolls against the creature have advantage, and the creature\'s attack rolls have disadvantage. The creature has disadvantage on Dexterity saving throws.';

  @override
  String get conditionStunned => 'Stunned';

  @override
  String get conditionStunnedDesc =>
      'A stunned creature is incapacitated, can\'t move, and can speak only falteringly. The creature automatically fails Strength and Dexterity saving throws. Attack rolls against the creature have advantage.';

  @override
  String get conditionUnconscious => 'Unconscious';

  @override
  String get conditionUnconsciousDesc =>
      'An unconscious creature is incapacitated, can\'t move or speak, and is unaware of its surroundings. It drops what it\'s holding and falls prone. The creature automatically fails Strength and Dexterity saving throws. Attack rolls against the creature have advantage. Any attack that hits the creature is a critical hit if the attacker is within 5 feet.';

  @override
  String get conditionExhaustion => 'Exhaustion';

  @override
  String get conditionExhaustionDesc =>
      'Exhaustion has 6 levels with cumulative effects. Level 1: disadvantage on ability checks. Level 2: speed halved. Level 3: disadvantage on attack rolls and saving throws. Level 4: HP maximum halved. Level 5: speed 0. Level 6: death.';

  @override
  String get diceTitle => 'Dice roller';

  @override
  String get diceFormulaLabel => 'Formula (e.g. 1d20+5, 3d6+1d4)';

  @override
  String get diceAdvantage => 'Advantage';

  @override
  String get diceDisadvantage => 'Disadvantage';

  @override
  String get diceRollButton => 'Roll';

  @override
  String get diceHistory => 'History';

  @override
  String get diceClear => 'Clear';

  @override
  String get diceNoRollsYet => '— no rolls yet —';

  @override
  String get diceNoOtherRolls => '— no other rolls —';

  @override
  String get spellCatalogTitle => 'Spell codex';

  @override
  String spellCatalogResultsCount(int shown, int total) =>
      '$shown of $total spells';

  @override
  String get spellPickerTitle => 'SRD catalog';

  @override
  String get spellPickerSearchHint => 'Search by name (e.g. \"fire\")';

  @override
  String get spellFilterLevelHint => 'Level';

  @override
  String get spellFilterLevelAll => 'Level: all';

  @override
  String get spellFilterCantrips => 'Cantrips';

  @override
  String spellFilterLevelN(Object n) {
    return 'Lv. $n';
  }

  @override
  String get spellFilterSchoolHint => 'School';

  @override
  String get spellFilterSchoolAll => 'School: all';

  @override
  String get spellFilterClassHint => 'Class';

  @override
  String get spellFilterClassAll => 'Class: all';

  @override
  String get spellFilterRitualOnly => 'Ritual only';

  @override
  String get spellFilterConcentrationOnly => 'Concentration only';

  @override
  String get spellPickerNoResults => 'No results';

  @override
  String get spellPickerDetails => 'Details';

  @override
  String get spellPickerAdd => 'Add to sheet';

  @override
  String get editorToolbarShare => 'Share (read-only link)';

  @override
  String get editorPortraitChange => 'Change portrait';

  @override
  String get editorPortraitUpload => 'Upload portrait';

  @override
  String get editorPortraitUpdatedSnack => 'Portrait updated';

  @override
  String get editorPortraitRemovedSnack => 'Portrait removed';

  @override
  String get autosaveFormInvalid => 'Invalid form — not saved';

  @override
  String get editorExitDirtyTitle => 'Unsaved changes';

  @override
  String get editorExitDirtyBody =>
      'You have unsaved changes (some fields are invalid and were not saved). Exit and discard them?';

  @override
  String get editorExitDirtyDiscard => 'Discard and exit';

  @override
  String get editorLayoutTitle => 'Custom dashboard';

  @override
  String get editorLayoutOpenButton => 'Edit layout';

  @override
  String get editorLayoutEmpty =>
      'No widgets yet. Add one to start building your custom dashboard.';

  @override
  String get editorLayoutAddWidget => 'Add widget';

  @override
  String get editorLayoutReset => 'Reset to default';

  @override
  String get editorLayoutSavedSnack => 'Layout saved';

  @override
  String get editorLayoutResetConfirmTitle => 'Reset the layout?';

  @override
  String get editorLayoutResetConfirmBody =>
      'Your custom layout will be removed and the character returns to the classic tab view.';

  @override
  String get editorLayoutResetConfirmYes => 'Reset';

  @override
  String get editorLayoutRemoveWidget => 'Remove widget';

  @override
  String get editorLayoutBringForward => 'Bring forward';

  @override
  String get editorLayoutSendBackward => 'Send backward';

  @override
  String get editorLayoutWidgetHpTracker => 'HP tracker';

  @override
  String get editorLayoutWidgetConditions => 'Conditions';

  @override
  String get editorLayoutWidgetPortrait => 'Portrait';

  @override
  String get homeCustomDashboardBadge => 'NEW';

  @override
  String get homeCustomDashboardTitle => 'Custom dashboard';

  @override
  String get homeCustomDashboardSubtitle =>
      'Build your character sheet with drag-and-drop widgets — pick what to show and where.';

  @override
  String get homeCustomDashboardOpen => 'Open characters';

  @override
  String get charactersCardOpenClassic => 'Classic view';

  @override
  String get charactersCardOpenLayout => 'Custom layout';

  @override
  String get landingDashboardSpotlightBadge => 'NEW';

  @override
  String get landingDashboardSpotlightTitle => 'The Chronicler\'s atelier';

  @override
  String get landingDashboardSpotlightDesc =>
      'Build the sheet your way: drag, resize and arrange the parchment blocks of your hero. Make it truly yours.';

  @override
  String get editorAnagraficaName => 'Name';

  @override
  String get editorAnagraficaLevel => 'Level';

  @override
  String get editorAnagraficaRace => 'Race';

  @override
  String get editorAnagraficaSubrace => 'Subrace';

  @override
  String get editorAnagraficaClass => 'Class';

  @override
  String get editorAnagraficaSubclass => 'Subclass';

  @override
  String get editorAnagraficaExperience => 'Experience (XP)';

  @override
  String get editorAnagraficaInspiration => 'Inspiration';

  @override
  String get editorStatsTitle => 'Ability scores';

  @override
  String get editorStatsHint =>
      'Values 1-30. The modifier (below the field) updates automatically.';

  @override
  String get editorAbilityTooltipNeedsValue => 'Enter the score to roll';

  @override
  String editorAbilityTooltipRoll(Object formula, Object ability) {
    return 'Roll $formula ($ability)';
  }

  @override
  String get editorColComp => 'Prof.';

  @override
  String get editorColExpert => 'Exp.';

  @override
  String get editorColTotal => 'Tot.';

  @override
  String get editorFlagOverrideTag => 'override';

  @override
  String get editorProfBonusOverrideTooltip => 'Manual override (Combat)';

  @override
  String get editorProfBonusAutoTooltip => 'Calculated from level';

  @override
  String editorProfBonusChipLabel(Object value) {
    return 'Prof $value';
  }

  @override
  String get editorCombatDefenseMovement => 'Defense & movement';

  @override
  String get editorCombatArmorClassLabel => 'Armor Class (AC)';

  @override
  String editorCombatHintAcAuto(Object value, Object ability) {
    return 'auto: $value (10 + $ability)';
  }

  @override
  String editorCombatHintInitAuto(Object value, Object ability) {
    return 'auto: $value ($ability mod)';
  }

  @override
  String get editorCombatSpeedLabel => 'Speed (ft)';

  @override
  String get editorCombatProfBonusLabel => 'Proficiency bonus';

  @override
  String editorCombatHintProfAuto(Object value) {
    return 'auto: $value (from level)';
  }

  @override
  String get editorCombatHpSectionTitle => 'Hit Points';

  @override
  String get editorCombatHpMaxLabel => 'Max HP';

  @override
  String get editorCombatHpCurrentLabel => 'Current HP';

  @override
  String get editorCombatHitDiceTotalLabel => 'Total';

  @override
  String get editorCombatHitDiceUsedLabel => 'Used';

  @override
  String get editorCombatDeathSavesSectionTitle => 'Death saving throws';

  @override
  String get editorCombatDeathSavesSuccLabel => 'Successes (0-3)';

  @override
  String get editorCombatDeathSavesFailLabel => 'Failures (0-3)';

  @override
  String get editorCombatConditionsTitle => 'Conditions';

  @override
  String get editorCombatConditionsHint =>
      'Tap a chip to toggle. Tap the ⓘ icon for the PHB description.';

  @override
  String get editorCombatRestsTitle => 'Rests';

  @override
  String get editorCombatRestsHint =>
      'Short rest: reset death saves (and warlock slots if warlock progression). Long rest: HP=max, temp=0, full slots, hit dice recovered by half.';

  @override
  String get editorSpellsCasterClassLabel => 'Spellcasting class';

  @override
  String get editorSpellsSaveDcLabel => 'Spell save DC';

  @override
  String get editorSpellsAttackLabel => 'Attack bonus';

  @override
  String get editorSpellsSlotsHint =>
      'Leave empty the levels you don\'t have (won\'t be sent). You can prefill from the PHB table.';

  @override
  String get editorSpellsListTitle => 'Spell list';

  @override
  String get editorSpellsListHint =>
      'Add from the SRD catalog (319 spells) or create a custom homebrew.';

  @override
  String get editorSpellsAddFromCatalog => 'Add from catalog';

  @override
  String get editorSpellsCustomSpell => 'Custom spell';

  @override
  String get editorSpellsConvertTitle => 'Customize spell';

  @override
  String get editorSpellsConvertBody =>
      'It will be copied from the catalog and become an editable custom. The link to the SRD catalog is lost.';

  @override
  String get editorSpellsConvertConfirm => 'Customize';

  @override
  String get editorSpellsProgressionLabel => 'Progression (PHB)';

  @override
  String get editorSpellsFillFromPhb => 'Fill from PHB';

  @override
  String editorSpellsPrefillerPreview(Object level, Object slots) {
    return 'Preview at level $level: $slots';
  }

  @override
  String get editorSpellsNoSlotsAtLevel => 'no slots at this level';

  @override
  String get editorSpellsSetLevelFirst =>
      'Set the character level first in the Profile tab.';

  @override
  String get editorSpellsFillConfirmTitle => 'Fill the slots?';

  @override
  String get editorSpellsFillConfirmBody =>
      'The \"Max\" values will be overwritten from the PHB table. The current count will be clamped to the new max.';

  @override
  String get editorSpellsFillConfirmYes => 'Fill';

  @override
  String get editorSpellsFillSnack => 'Slots prefilled';

  @override
  String editorSpellsSlotLevel(Object n) {
    return 'Level $n';
  }

  @override
  String get editorSpellsSlotMax => 'Max';

  @override
  String get editorSpellsNoSlotsLine => '— no slots —';

  @override
  String get editorSpellsConsumeSlot => 'Use slot';

  @override
  String get editorSpellsRestoreSlot => 'Restore slot';

  @override
  String get editorSpellsLevelChipCantrip => 'Cant.';

  @override
  String editorSpellsLevelChipLvl(Object n) {
    return 'L$n';
  }

  @override
  String editorSpellsFromCatalog(Object source) {
    return 'From catalog ($source)';
  }

  @override
  String get editorSpellsCustomHomebrewTooltip => 'Custom homebrew';

  @override
  String get editorSpellsActionsTooltip => 'Actions';

  @override
  String get editorSpellsAlwaysPreparedShort => 'Always prep.';

  @override
  String get editorSpellsNotesLabel => 'Notes (per sheet)';

  @override
  String get editorSpellProgressionNone => 'None';

  @override
  String get editorSpellProgressionFull => 'Full caster (Wizard, Cleric, …)';

  @override
  String get editorSpellProgressionHalf => 'Half caster (Paladin, Ranger)';

  @override
  String get editorSpellProgressionThird =>
      'Third caster (Trickster, Eldritch)';

  @override
  String get editorSpellProgressionWarlock => 'Warlock (Pact Magic)';

  @override
  String get editorEquipCoinsTitle => 'Coins';

  @override
  String get editorEquipAddItem => 'Add item';

  @override
  String get editorEquipItemName => 'Item';

  @override
  String get editorEquipItemQty => 'Quantity';

  @override
  String get editorEquipItemWeight => 'Weight (lb)';

  @override
  String get editorEquipItemNotes => 'Notes';

  @override
  String get editorTraitsProficienciesTitle => 'Proficiencies';

  @override
  String get editorTraitsFeaturesFieldLabel => 'Features/traits';

  @override
  String get editorTraitsLanguagesNone => '— none —';

  @override
  String get editorTraitsAddLanguageLabel => 'Add language';

  @override
  String get editorNotesBackstoryLabel => 'Backstory';

  @override
  String get editorNotesNotesLabel => 'Free notes';

  @override
  String get editorNotAuthError => 'User not authenticated';

  @override
  String get editorValidatorEnterNumber => 'Enter a number';

  @override
  String get editorValidatorMinZero => 'Must be ≥ 0';

  @override
  String editorValidatorMinN(Object n) {
    return 'Min $n';
  }

  @override
  String editorValidatorMaxN(Object n) {
    return 'Max $n';
  }

  @override
  String get editorHpDialogTitle => 'Edit HP';

  @override
  String get editorHpQuantityLabel => 'Amount';

  @override
  String get editorHpQuantityHint => 'e.g. 8';

  @override
  String get editorHpHeal => 'Heal';

  @override
  String get editorHpDamage => 'Damage';

  @override
  String get editorHpTempLabel => 'Temp HP';

  @override
  String get editorHpTempHelper => 'Do not stack: the highest value applies';

  @override
  String get editorHpTempApply => 'Apply temp HP';

  @override
  String get editorRestLong => 'Long rest';

  @override
  String get editorRestShort => 'Short rest';

  @override
  String get editorRestLongBody =>
      'Will apply: HP to max, temp HP to 0, spell slots full, hit dice recovered by half, death saves reset.';

  @override
  String get editorRestShortBody =>
      'Death saves will be reset. If warlock progression, spell slots refill.';

  @override
  String get editorRestLongConfirmTitle => 'Long rest?';

  @override
  String get editorRestShortConfirmTitle => 'Short rest?';

  @override
  String get editorRestLongApplied => 'Long rest applied';

  @override
  String get editorRestShortApplied => 'Short rest applied';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonStayTuned =>
      'We\'re working to make this available soon. Stay tuned.';

  @override
  String get comingSoonIos =>
      'The iPhone and iPad app is coming soon to the App Store.';

  @override
  String get comingSoonAndroid =>
      'The Android app is coming soon to the Google Play Store.';

  @override
  String get comingSoonSpells =>
      'The public spell catalog will soon be browsable without an account.';

  @override
  String get comingSoonGeneric => 'This section is under construction.';

  @override
  String get comingSoonBack => 'Back to home';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalCookiesTitle => 'Cookie Policy';

  @override
  String get legalContactTitle => 'Contact';

  @override
  String legalLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get legalOnlyItalianNotice =>
      'Legal texts are published in Italian. The Italian version is the official one.';

  @override
  String get legalBackToHome => 'Back to home';

  @override
  String get registerAcceptPart1 => 'I have read and accept the ';

  @override
  String get registerAcceptPart2 => ' and the ';

  @override
  String get registerAcceptPart3 => '.';

  @override
  String get registerPrivacyLink => 'Privacy Policy';

  @override
  String get registerTermsLink => 'Terms of Service';

  @override
  String get registerAcceptRequired =>
      'You must accept the Privacy Policy and the Terms of Service to register';

  @override
  String get registerAgeDeclaration => 'I declare I am at least 14 years old';

  @override
  String get registerAgeRequired =>
      'You must confirm you are at least 14 years old to register';

  @override
  String get profilePrivacySectionTitle => 'Privacy & data';

  @override
  String get profilePrivacyHint =>
      'Download a full copy of your personal data in JSON format, or read our Privacy Policy.';

  @override
  String get profileExportButton => 'Export my data';

  @override
  String get profileExportInProgress => 'Preparing export…';

  @override
  String get profileExportDone => 'Export completed.';

  @override
  String profileExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get profileLegalPrivacyLink => 'Privacy Policy';

  @override
  String get profileLegalTermsLink => 'Terms of Service';

  @override
  String get profileLegalCookiesLink => 'Cookies';

  @override
  String get profileLegalContactLink => 'Contact';

  @override
  String get deletionInfoTitle => 'How to delete your account';

  @override
  String get deletionInfoIntro =>
      'You can delete your account and all associated data at any time. Deletion is immediate and irreversible.';

  @override
  String get deletionInfoStepsTitle => 'Standard procedure';

  @override
  String get deletionInfoStep1 => 'Sign in to your account.';

  @override
  String get deletionInfoStep2 =>
      'Go to Profile → \"Danger zone\" at the bottom of the page.';

  @override
  String get deletionInfoStep3 => 'Press \"Delete account\".';

  @override
  String get deletionInfoStep4 =>
      'Type your username and password to confirm, then press the red button.';

  @override
  String get deletionInfoWhatRemovedTitle => 'What gets deleted';

  @override
  String get deletionInfoWhatRemoved =>
      'All of the following data is permanently removed, with no possibility of recovery:';

  @override
  String get deletionInfoBullet1 =>
      'Account, email, password (hash), profile picture.';

  @override
  String get deletionInfoBullet2 =>
      'All your character sheets and portrait images.';

  @override
  String get deletionInfoBullet3 => 'Dice roll history.';

  @override
  String get deletionInfoBullet4 => 'All active sharing links of your sheets.';

  @override
  String get deletionInfoBullet5 => 'All active sessions on every device.';

  @override
  String get deletionInfoCannotLoginTitle => 'Can\'t sign in?';

  @override
  String get deletionInfoCannotLogin =>
      'If you have lost your credentials and can\'t reset your password, write us at the email below, specifying the email address of your account. We\'ll help you complete the deletion after verifying your identity.';

  @override
  String get deletionInfoEmail => 'franksisca@gmail.com';

  @override
  String get deletionInfoLoginBtn => 'Sign in and delete';

  @override
  String get deletionInfoBackHome => 'Back to home';
}
