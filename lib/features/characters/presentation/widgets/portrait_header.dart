import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/portrait_providers.dart';
import '../character_portrait_widget.dart';

/// Header con ritratto della scheda + bottoni upload/change/remove.
class PortraitHeader extends ConsumerWidget {
  const PortraitHeader({
    super.key,
    required this.characterId,
    required this.onPick,
    required this.onRemove,
  });

  final String       characterId;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPortrait =
        ref.watch(characterPortraitBytesProvider(characterId)).asData?.value != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CharacterPortraitWidget(id: characterId, size: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onPick,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(hasPortrait
                      ? AppL10n.of(context).editorPortraitChange
                      : AppL10n.of(context).editorPortraitUpload),
                ),
                if (hasPortrait)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(AppL10n.of(context).actionRemove),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
