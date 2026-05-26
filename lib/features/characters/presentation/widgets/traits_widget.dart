import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../character_editor_controller.dart';
import 'editor_form_fields.dart';

/// Tab "Tratti": personality/ideals/bonds/flaws, lingue, competenze, features.
class TraitsWidget extends StatelessWidget {
  const TraitsWidget({super.key, required this.controller});

  final CharacterEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          editorTextField(controller.personalityTraits, label: l10n.sheetTraitsPersonality, maxLines: 3),
          const SizedBox(height: 12),
          editorTextField(controller.ideals, label: l10n.sheetTraitsIdeals, maxLines: 3),
          const SizedBox(height: 12),
          editorTextField(controller.bonds,  label: l10n.sheetTraitsBonds,  maxLines: 3),
          const SizedBox(height: 12),
          editorTextField(controller.flaws,  label: l10n.sheetTraitsFlaws,  maxLines: 3),
          const SizedBox(height: 24),
          Text(l10n.sheetTraitsLanguages, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _LanguagesChips(
            languages: controller.languages,
            onChanged: controller.redrawTraits,
          ),
          const SizedBox(height: 24),
          Text(l10n.editorTraitsProficienciesTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorTextField(controller.armorProf,  label: l10n.sheetTraitsArmor),
          const SizedBox(height: 12),
          editorTextField(controller.weaponProf, label: l10n.sheetTraitsWeapons),
          const SizedBox(height: 12),
          editorTextField(controller.toolProf,   label: l10n.sheetTraitsTools),
          const SizedBox(height: 24),
          Text(l10n.sheetTraitsFeatures, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          editorTextField(controller.featuresAndTraits, label: l10n.editorTraitsFeaturesFieldLabel, maxLines: 8),
        ],
      ),
    );
  }
}

class _LanguagesChips extends StatefulWidget {
  const _LanguagesChips({required this.languages, required this.onChanged});
  final List<String> languages;
  final VoidCallback onChanged;

  @override
  State<_LanguagesChips> createState() => _LanguagesChipsState();
}

class _LanguagesChipsState extends State<_LanguagesChips> {
  final _newCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (widget.languages.any((e) => e.toLowerCase() == v.toLowerCase())) {
      _newCtrl.clear();
      return;
    }
    setState(() => widget.languages.add(v));
    widget.onChanged();
    _newCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.languages.length; i++)
              InputChip(
                label: Text(widget.languages[i]),
                onDeleted: () {
                  setState(() => widget.languages.removeAt(i));
                  widget.onChanged();
                },
              ),
            if (widget.languages.isEmpty)
              Text(l10n.editorTraitsLanguagesNone,
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newCtrl,
                decoration: InputDecoration(
                  labelText: l10n.editorTraitsAddLanguageLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: _add,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _add(_newCtrl.text),
              icon: const Icon(Icons.add),
              label: Text(l10n.actionAdd),
            ),
          ],
        ),
      ],
    );
  }
}
