import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../logic/conditions_catalog.dart';

/// Mostra in dialog la descrizione di una condizione PHB. Utility condivisa
/// da [HpQuickControlsWidget] (chip nelle condizioni attive) e dal Combat tab.
Future<void> showConditionInfo(BuildContext context, ConditionEntry e) {
  final l10n = AppL10n.of(context);
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          Text(labelForCondition(e.key, l10n)),
        ],
      ),
      content: Text(descriptionForCondition(e.key, l10n)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    ),
  );
}
