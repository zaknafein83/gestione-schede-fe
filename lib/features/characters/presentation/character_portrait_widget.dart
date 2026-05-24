import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/portrait_providers.dart';

/// Mostra il ritratto della scheda con id dato. CircleAvatar rotondo,
/// placeholder Icon se assente, spinner durante il fetch.
class CharacterPortraitWidget extends ConsumerWidget {
  const CharacterPortraitWidget({super.key, required this.id, this.size = 64});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(characterPortraitBytesProvider(id));

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
        child: Icon(Icons.person, size: size * 0.55),
      );
}
