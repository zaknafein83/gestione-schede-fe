import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../character_editor_controller.dart';
import 'editor_form_fields.dart';

/// Tab "Note": backstory, alleati, simbolo, descrizione fisica, note libere.
class NotesWidget extends StatelessWidget {
  const NotesWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          editorTextField(controller.notes,                  label: l10n.editorNotesNotesLabel,     maxLines: 8),
          const SizedBox(height: 12),
          editorTextField(controller.backstory,              label: l10n.editorNotesBackstoryLabel, maxLines: 8),
          const SizedBox(height: 12),
          editorTextField(controller.alliesAndOrganizations, label: l10n.sheetNotesAllies,          maxLines: 5),
          const SizedBox(height: 12),
          editorTextField(controller.symbol,                 label: l10n.sheetNotesSymbol),
          const SizedBox(height: 12),
          editorTextField(controller.physicalDescription,    label: l10n.sheetNotesPhysical,        maxLines: 5),
        ],
      ),
    );
  }
}
