import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../profile/presentation/avatar_widget.dart';

/// Schermata accessibile solo se loggati. Placeholder per ora — verra'
/// ampliata nelle feature successive (lista personaggi, navigazione, ecc.).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.of(context).appTitle),
        actions: [
          // Avatar cliccabile → profilo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/profile'),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: AvatarWidget(size: 36),
              ),
            ),
          ),
          IconButton(
            tooltip: AppL10n.of(context).actionLogout,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: Center(
        child: auth.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text(AppL10n.of(context).commonErrorPrefix(e.toString())),
          data: (user) {
            final l10n = AppL10n.of(context);
            if (user == null) {
              return Text(l10n.commonNotAuthenticated);
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AvatarWidget(size: 120),
                  const SizedBox(height: 12),
                  Text(
                    l10n.homeGreeting(user.displayName),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.push('/characters'),
                    icon: const Icon(Icons.menu_book),
                    label: Text(l10n.navCharacters),
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _CustomDashboardTeaser(
                      onOpen: () => context.push('/characters'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Card di annuncio della feature "Dashboard personalizzata" in homepage.
class _CustomDashboardTeaser extends StatelessWidget {
  const _CustomDashboardTeaser({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.space_dashboard, size: 32, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.homeCustomDashboardBadge,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeCustomDashboardTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeCustomDashboardSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.homeCustomDashboardOpen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
