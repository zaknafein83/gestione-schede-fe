import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../logic/conditions_catalog.dart';
import '../character_editor_controller.dart';
import 'conditions_dialog.dart';

/// Pannello standalone con le condizioni PHB toggleabili (riusato anche
/// nel Combat tab). Tap = attiva/disattiva. Long press = info dialog.
class ConditionsWidget extends StatelessWidget {
  const ConditionsWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editorCombatConditionsTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in conditionsCatalog)
                _ConditionChip(
                  entry: c,
                  active: controller.conditions.contains(c.key),
                  onToggle: (on) => controller.toggleCondition(c.key, on),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.entry,
    required this.active,
    required this.onToggle,
  });

  final ConditionEntry entry;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: active,
      onSelected: onToggle,
      label: Text(labelForCondition(entry.key, AppL10n.of(context))),
      avatar: active
          ? Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error)
          : null,
      selectedColor: scheme.errorContainer,
      deleteIcon: const Icon(Icons.info_outline, size: 18),
      onDeleted: () => showConditionInfo(context, entry),
    );
  }
}
