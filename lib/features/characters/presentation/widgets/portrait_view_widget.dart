import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../character_portrait_widget.dart';

/// Pannello display-only del ritratto del personaggio.
/// Adatta automaticamente le dimensioni al frame disponibile.
/// Per l'upload del ritratto si va nell'editor classico (PortraitHeader).
class PortraitViewWidget extends ConsumerWidget {
  const PortraitViewWidget({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide.clamp(48.0, 320.0);
        return Center(
          child: CharacterPortraitWidget(id: characterId, size: size),
        );
      },
    );
  }
}
