import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/external_link.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../profile/presentation/avatar_widget.dart';

const String _kBuyCoffeeUrl = 'https://buymeacoffee.com/franksisca';

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
          IconButton(
            tooltip: AppL10n.of(context).homeBuyCoffeeTooltip,
            icon: Icon(
              Icons.local_cafe,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: () => openExternalUrl(_kBuyCoffeeUrl),
          ),
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
            return Column(
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
              ],
            );
          },
        ),
      ),
    );
  }
}
