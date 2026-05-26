import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../character_editor_controller.dart';
import 'editor_form_fields.dart';

/// Tab "Anagrafica": nome, razza, classe, livello, allineamento, ispirazione.
class AnagraficaWidget extends StatelessWidget {
  const AnagraficaWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          editorRow([
            editorTextField(controller.name,      label: l10n.editorAnagraficaName),
            editorTextField(controller.level,     label: l10n.editorAnagraficaLevel, kind: EditorFieldKind.intRanged, min: 1, max: 20),
          ]),
          editorRow([
            editorTextField(controller.race,      label: l10n.editorAnagraficaRace),
            editorTextField(controller.subrace,   label: l10n.editorAnagraficaSubrace),
          ]),
          editorRow([
            editorTextField(controller.className, label: l10n.editorAnagraficaClass),
            editorTextField(controller.subclass,  label: l10n.editorAnagraficaSubclass),
          ]),
          editorRow([
            editorTextField(controller.background, label: l10n.sheetHeaderBackground),
            editorTextField(controller.alignment,  label: l10n.sheetHeaderAlignment),
          ]),
          editorRow([
            editorTextField(controller.experience, label: l10n.editorAnagraficaExperience, kind: EditorFieldKind.intMin0),
            const SizedBox.shrink(),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(l10n.editorAnagraficaInspiration),
            contentPadding: EdgeInsets.zero,
            value: controller.inspiration,
            onChanged: controller.setInspiration,
          ),
        ],
      ),
    );
  }
}
