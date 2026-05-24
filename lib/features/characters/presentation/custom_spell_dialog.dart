import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../spells/models/spell_models.dart';

/// Dialog per creare/modificare uno spell custom (homebrew).
///
/// Riceve un [initial] (mappa piatta dei campi: name/level/school/...) e
/// restituisce una mappa simile quando l'utente conferma; null se annulla.
/// Mappa di output: solo campi non vuoti, con strutture annidate per
/// `components` e `classes`.
Future<Map<String, dynamic>?> showCustomSpellDialog(
  BuildContext context, {
  Map<String, dynamic>? initial,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: _Body(initial: initial),
      ),
    ),
  );
}

class _Body extends StatefulWidget {
  const _Body({this.initial});
  final Map<String, dynamic>? initial;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final TextEditingController _name, _level, _castingTime, _range,
      _materialDesc, _duration, _description, _atHigherLevels;
  late String? _school;
  late bool _verbal, _somatic, _material, _concentration, _ritual;
  late final List<String> _classes;

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? const <String, dynamic>{};
    _name           = TextEditingController(text: (i['name']        as String?) ?? '');
    _level          = TextEditingController(text: (i['level']       as num?)?.toString() ?? '');
    _castingTime    = TextEditingController(text: (i['castingTime'] as String?) ?? '');
    _range          = TextEditingController(text: (i['range']       as String?) ?? '');
    _duration       = TextEditingController(text: (i['duration']    as String?) ?? '');
    _description    = TextEditingController(text: (i['description'] as String?) ?? '');
    _atHigherLevels = TextEditingController(text: (i['atHigherLevels'] as String?) ?? '');
    _school         = i['school'] as String?;
    if (_school != null && !spellSchools.contains(_school)) {
      // permetti scuole custom: le lasciamo nel dropdown extra come "Altra"
      // ma di default impostiamo a null per non rompere il list.
      _school = null;
    }
    _concentration = (i['concentration'] as bool?) ?? false;
    _ritual        = (i['ritual']        as bool?) ?? false;
    final comps = (i['components'] as Map?)?.cast<String, dynamic>() ?? const {};
    _verbal       = (comps['verbal']   as bool?) ?? false;
    _somatic      = (comps['somatic']  as bool?) ?? false;
    _material     = (comps['material'] as bool?) ?? false;
    _materialDesc = TextEditingController(text: (comps['materialDescription'] as String?) ?? '');
    _classes      = ((i['classes'] as List?) ?? const []).cast<String>().toList();
  }

  @override
  void dispose() {
    _name.dispose();
    _level.dispose();
    _castingTime.dispose();
    _range.dispose();
    _materialDesc.dispose();
    _duration.dispose();
    _description.dispose();
    _atHigherLevels.dispose();
    super.dispose();
  }

  void _submit() {
    final out = <String, dynamic>{};
    final n = _name.text.trim();
    if (n.isNotEmpty) out['name'] = n;
    final lv = int.tryParse(_level.text.trim());
    if (lv != null) out['level'] = lv;
    if (_school != null && _school!.isNotEmpty) out['school'] = _school;
    final ct = _castingTime.text.trim();
    if (ct.isNotEmpty) out['castingTime'] = ct;
    final rg = _range.text.trim();
    if (rg.isNotEmpty) out['range'] = rg;
    final dur = _duration.text.trim();
    if (dur.isNotEmpty) out['duration'] = dur;
    out['concentration'] = _concentration;
    out['ritual']        = _ritual;
    final comps = <String, dynamic>{
      'verbal':   _verbal,
      'somatic':  _somatic,
      'material': _material,
    };
    final mat = _materialDesc.text.trim();
    if (_material && mat.isNotEmpty) comps['materialDescription'] = mat;
    out['components'] = comps;
    if (_classes.isNotEmpty) out['classes'] = List<String>.from(_classes);
    final desc = _description.text.trim();
    if (desc.isNotEmpty) out['description'] = desc;
    final hl = _atHigherLevels.text.trim();
    if (hl.isNotEmpty) out['atHigherLevels'] = hl;
    Navigator.pop(context, out);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final t    = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_outlined),
              const SizedBox(width: 8),
              Text(widget.initial == null
                      ? l10n.customSpellDialogTitleNew
                      : l10n.customSpellDialogTitleEdit,
                  style: t.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: l10n.actionCancel,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: l10n.customSpellFieldName,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _level,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: l10n.customSpellFieldLevel,
                          helperText: l10n.customSpellFieldLevelHelper,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _school,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.customSpellFieldSchool,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('—')),
                          for (final s in spellSchools)
                            DropdownMenuItem(value: s, child: Text(s)),
                        ],
                        onChanged: (v) => setState(() => _school = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _castingTime,
                        decoration: InputDecoration(
                          labelText: l10n.customSpellFieldCastingTime,
                          hintText: l10n.customSpellHintCastingTime,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _range,
                        decoration: InputDecoration(
                          labelText: l10n.customSpellFieldRange,
                          hintText: l10n.customSpellHintRange,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _duration,
                  decoration: InputDecoration(
                    labelText: l10n.customSpellFieldDuration,
                    hintText: l10n.customSpellHintDuration,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.customSpellComponents, style: t.titleSmall),
                Wrap(
                  spacing: 4,
                  children: [
                    FilterChip(
                      label: const Text('V'),
                      selected: _verbal,
                      onSelected: (v) => setState(() => _verbal = v),
                    ),
                    FilterChip(
                      label: const Text('S'),
                      selected: _somatic,
                      onSelected: (v) => setState(() => _somatic = v),
                    ),
                    FilterChip(
                      label: const Text('M'),
                      selected: _material,
                      onSelected: (v) => setState(() => _material = v),
                    ),
                  ],
                ),
                if (_material) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _materialDesc,
                    decoration: InputDecoration(
                      labelText: l10n.customSpellMaterials,
                      hintText: l10n.customSpellMaterialsHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.customSpellConcentration),
                        value: _concentration,
                        onChanged: (v) => setState(() => _concentration = v ?? false),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.customSpellRitual),
                        value: _ritual,
                        onChanged: (v) => setState(() => _ritual = v ?? false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.customSpellClasses, style: t.titleSmall),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final c in spellcasterClasses)
                      FilterChip(
                        label: Text(c),
                        selected: _classes.contains(c),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _classes.add(c);
                          } else {
                            _classes.remove(c);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _description,
                  minLines: 4,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: l10n.customSpellDescription,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _atHigherLevels,
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.customSpellHigherLevels,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
