import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/avatar_providers.dart';

/// Mostra l'avatar dell'utente loggato. I bytes vengono caricati una volta
/// e cachati nel provider Riverpod; l'invalidazione e' globale tramite
/// `avatarVersionProvider`, cosi' tutte le istanze del widget si aggiornano
/// dopo un upload/delete.
class AvatarWidget extends ConsumerWidget {
  const AvatarWidget({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(avatarBytesProvider);

    return async.when(
      loading: () => SizedBox(
        width: size, height: size,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => _placeholder(context),
      data: (bytes) {
        if (bytes == null) return _placeholder(context);
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          backgroundImage: MemoryImage(bytes),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) => CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(Icons.person, size: size * 0.6),
      );
}
