import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../core/locale.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../share/logic/file_download.dart';
import 'avatar_widget.dart';
import 'change_password_dialog.dart';
import 'delete_account_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _displayName  = TextEditingController();
  final _bio          = TextEditingController();
  bool _initialized = false;
  bool _submitting  = false;
  bool _exporting   = false;

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _ensureInit() {
    if (_initialized) return;
    final user = ref.read(authControllerProvider).asData?.value;
    if (user == null) return;
    _displayName.text = user.displayName;
    _bio.text         = user.bio ?? '';
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authControllerProvider).asData?.value;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final newDisplay = _displayName.text.trim();
      final newBio     = _bio.text.trim();

      await ref.read(authControllerProvider.notifier).updateMe(
            displayName: newDisplay != user.displayName ? newDisplay : null,
            bio:         newBio != (user.bio ?? '')     ? newBio     : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).profileUpdated)),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    final bytes = f.bytes;
    if (bytes == null) return;

    final ext = (f.extension ?? '').toLowerCase();
    final contentType = switch (ext) {
      'png'         => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp'        => 'image/webp',
      _ => 'application/octet-stream',
    };

    try {
      await ref.read(authControllerProvider.notifier)
              .uploadAvatar(bytes, f.name, contentType);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).profileAvatarUpdated)),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await ref.read(authControllerProvider.notifier).deleteAvatar();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    }
  }

  Future<void> _openChangePassword() async {
    final ok = await showChangePasswordDialog(context);
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).profilePasswordChangedLogout)),
      );
      // logout gia' avvenuto nel controller — redirect a /login dal router
      context.go('/login');
    }
  }

  Future<void> _exportMyData() async {
    final l10n = AppL10n.of(context);
    setState(() => _exporting = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileExportInProgress)),
    );
    try {
      final data = await ref.read(authControllerProvider.notifier).exportMyData();

      // Serializza pretty + scarica come file.
      final json     = const JsonEncoder.withIndent('  ').convert(data);
      final now      = DateTime.now();
      final ts       = '${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}';
      final filename = 'pg5e-export-$ts.json';
      downloadJsonFile(filename, json);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileExportDone)),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileExportFailed(e.detail))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileExportFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _openDeleteAccount() async {
    final user = ref.read(authControllerProvider).asData?.value;
    if (user == null) return;
    final ok = await showDeleteAccountDialog(context, expectedUsername: user.username);
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).deleteAccountDoneSnack)),
      );
      // l'auth controller ha gia' azzerato lo stato — redirect a landing
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureInit();
    final auth = ref.watch(authControllerProvider);
    final user = auth.asData?.value;

    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar + bottoni
                        const Center(child: AvatarWidget(size: 120)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.upload),
                              label: Text(l10n.profileAvatarChange),
                              onPressed: _pickAndUploadAvatar,
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l10n.profileAvatarRemove),
                              onPressed: _removeAvatar,
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Lingua: in alto perchè è ciò che gli utenti cercano per primo
                        const _LocaleSelector(),
                        const Divider(height: 40),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                initialValue: user.email,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: l10n.authEmailLabel,
                                  helperText: l10n.profileEmailHelper,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: user.username,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: l10n.authUsernameLabel,
                                  helperText: l10n.profileUsernameHelper,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _displayName,
                                decoration: InputDecoration(
                                  labelText: l10n.authDisplayNameLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return l10n.commonRequired;
                                  if (v.trim().length > 60) return l10n.commonMaxChars(60);
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _bio,
                                maxLines: 4,
                                maxLength: 500,
                                decoration: InputDecoration(
                                  labelText: l10n.profileBioLabel,
                                  alignLabelWithHint: true,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _submitting ? null : _saveProfile,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 18, width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2))
                                      : Text(l10n.profileSaveBtn),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 40),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          label: Text(l10n.profileChangePassword),
                          onPressed: _openChangePassword,
                        ),
                        if (user.isAdmin) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.admin_panel_settings_outlined),
                            label: Text(l10n.adminMenuLink),
                            onPressed: () => context.push('/admin'),
                          ),
                        ],
                        const Divider(height: 40),
                        const _ThemeModeSelector(),
                        const Divider(height: 40),
                        _AboutSection(isPremium: user.isPremium),
                        const Divider(height: 40),
                        _PrivacySection(
                          exporting: _exporting,
                          onExport: _exportMyData,
                        ),
                        const Divider(height: 40),
                        _DangerZone(onDelete: _openDeleteAccount),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// "Zona pericolosa": azioni irreversibili. Visivamente separata col colore
/// error e un bordo per scoraggiare il click accidentale.
class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onDelete});
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: scheme.error),
              const SizedBox(width: 8),
              Text(l10n.dangerZoneTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: scheme.error)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.deleteAccountHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error),
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.deleteAccountButton),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final t    = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Text(l10n.aboutSectionTitle, style: t.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isPremium ? l10n.aboutPlanPremium : l10n.aboutPlanFree,
          style: t.bodyMedium,
        ),
        if (!isPremium) ...[
          const SizedBox(height: 4),
          Text(l10n.aboutPremiumComing, style: t.bodySmall),
        ],
        const SizedBox(height: 12),
        Text(l10n.aboutSrdCredit, style: t.bodySmall),
      ],
    );
  }
}

class _LocaleSelector extends ConsumerWidget {
  const _LocaleSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final loc  = ref.watch(localeProvider).asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.translate, size: 20),
            const SizedBox(width: 8),
            // Mostriamo entrambe le forme così che chi vede l'app nella lingua
            // sbagliata trovi comunque la sezione.
            Text('${l10n.languageSectionTitle} / App language',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.languageSectionHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'it',
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.languageIt),
            ),
            ButtonSegment(
              value: 'en',
              icon: const Icon(Icons.flag),
              label: Text(l10n.languageEn),
            ),
            ButtonSegment(
              value: 'system',
              icon: const Icon(Icons.language_outlined),
              label: Text(l10n.languageSystem),
            ),
          ],
          selected: {loc?.languageCode ?? 'system'},
          onSelectionChanged: (s) {
            final v = s.first;
            ref.read(localeProvider.notifier).setLocale(
                  v == 'system' ? null : Locale(v),
                );
          },
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final mode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appearance, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_outlined),
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_outlined),
              label: Text(l10n.themeDark),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.settings_brightness_outlined),
              label: Text(l10n.themeSystem),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) =>
              ref.read(themeModeProvider.notifier).setMode(s.first),
        ),
      ],
    );
  }
}

/// Sezione "Privacy e dati" — export GDPR + link a pagine legali.
class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.exporting, required this.onExport});
  final bool exporting;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final t    = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, size: 20),
            const SizedBox(width: 8),
            Text(l10n.profilePrivacySectionTitle, style: t.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.profilePrivacyHint, style: t.bodySmall),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: exporting
                ? const SizedBox(
                    height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(l10n.profileExportButton),
            onPressed: exporting ? null : onExport,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            TextButton(
              onPressed: () => context.push('/privacy'),
              child: Text(l10n.profileLegalPrivacyLink),
            ),
            TextButton(
              onPressed: () => context.push('/terms'),
              child: Text(l10n.profileLegalTermsLink),
            ),
            TextButton(
              onPressed: () => context.push('/cookies'),
              child: Text(l10n.profileLegalCookiesLink),
            ),
            TextButton(
              onPressed: () => context.push('/contact'),
              child: Text(l10n.profileLegalContactLink),
            ),
          ],
        ),
      ],
    );
  }
}
