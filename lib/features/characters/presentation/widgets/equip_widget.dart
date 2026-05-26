import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../character_editor_controller.dart';
import '../character_editor_models.dart';
import 'editor_form_fields.dart';

/// Tab "Equipaggiamento": monete, inventario.
class EquipWidget extends StatelessWidget {
  const EquipWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editorEquipCoinsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: editorTextField(controller.coinCp, label: 'CP', kind: EditorFieldKind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: editorTextField(controller.coinSp, label: 'SP', kind: EditorFieldKind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: editorTextField(controller.coinEp, label: 'EP', kind: EditorFieldKind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: editorTextField(controller.coinGp, label: 'GP', kind: EditorFieldKind.intMin0)),
              const SizedBox(width: 8),
              Expanded(child: editorTextField(controller.coinPp, label: 'PP', kind: EditorFieldKind.intMin0)),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.sheetEquipmentInventory, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var i = 0; i < controller.inventory.length; i++)
            _InventoryCard(
              row:      controller.inventory[i],
              onRemove: () => controller.removeInventory(i),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: controller.addInventory,
            icon: const Icon(Icons.add),
            label: Text(l10n.editorEquipAddItem),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.row, required this.onRemove});
  final InventoryRow row;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            editorRow([
              editorTextField(row.name,     label: l10n.editorEquipItemName),
              editorTextField(row.qty,      label: l10n.editorEquipItemQty, kind: EditorFieldKind.intMin0),
            ]),
            editorRow([
              editorTextField(row.weightLb, label: l10n.editorEquipItemWeight, kind: EditorFieldKind.decimalMin0),
              const SizedBox.shrink(),
            ]),
            editorTextField(row.notes, label: l10n.editorEquipItemNotes, maxLines: 2),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionRemove),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
