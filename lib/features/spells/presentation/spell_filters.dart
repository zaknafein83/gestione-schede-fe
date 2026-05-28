import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/spell_models.dart';

/// Widget filtro condivisi tra `spell_picker_dialog` (selettore in editor scheda)
/// e `spell_catalog_screen` (catalogo pubblico).
///
/// Tutti `StatelessWidget` con `value` e `onChanged`: pattern controlled,
/// lo state vive nel parent.

class SpellLevelFilter extends StatelessWidget {
  const SpellLevelFilter({super.key, required this.value, required this.onChanged});

  final int?               value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DropdownButton<int?>(
      value: value,
      hint: Text(l10n.spellFilterLevelHint),
      items: <DropdownMenuItem<int?>>[
        DropdownMenuItem(value: null, child: Text(l10n.spellFilterLevelAll)),
        DropdownMenuItem(value: 0,    child: Text(l10n.spellFilterCantrips)),
        for (var l = 1; l <= 9; l++)
          DropdownMenuItem(value: l, child: Text(l10n.spellFilterLevelN(l))),
      ],
      onChanged: onChanged,
    );
  }
}

class SpellSchoolFilter extends StatelessWidget {
  const SpellSchoolFilter({super.key, required this.value, required this.onChanged});

  final String?               value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DropdownButton<String?>(
      value: value,
      hint: Text(l10n.spellFilterSchoolHint),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.spellFilterSchoolAll)),
        for (final s in spellSchools)
          DropdownMenuItem(value: s, child: Text(s)),
      ],
      onChanged: onChanged,
    );
  }
}

class SpellClassFilter extends StatelessWidget {
  const SpellClassFilter({super.key, required this.value, required this.onChanged});

  final String?               value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DropdownButton<String?>(
      value: value,
      hint: Text(l10n.spellFilterClassHint),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.spellFilterClassAll)),
        for (final c in spellcasterClasses)
          DropdownMenuItem(value: c, child: Text(c)),
      ],
      onChanged: onChanged,
    );
  }
}

/// FilterChip toggle per ritual/concentration con styling esplicito
/// che funziona col theme fantasy scuro (il default chip color aveva
/// labelStyle con contrasto pessimo sul background dark).
class SpellBoolFilterChip extends StatelessWidget {
  const SpellBoolFilterChip({
    super.key,
    required this.label,
    required this.avatarText,
    required this.selected,
    required this.onChanged,
  });

  final String             label;
  final String             avatarText;
  final bool               selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final selBg   = scheme.tertiary;
    final selFg   = scheme.onTertiary;
    final unselBg = scheme.surfaceContainerHighest;
    final unselFg = scheme.onSurface;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? selFg : unselFg,
          fontWeight: FontWeight.w600,
        ),
      ),
      avatar: CircleAvatar(
        backgroundColor: selected
            ? selFg.withValues(alpha: 0.18)
            : selBg.withValues(alpha: 0.18),
        foregroundColor: selected ? selFg : selBg,
        child: Text(
          avatarText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      selected: selected,
      selectedColor: selBg,
      backgroundColor: unselBg,
      checkmarkColor: selFg,
      side: BorderSide(
        color: selected ? selBg : scheme.outlineVariant,
        width: 1,
      ),
      onSelected: onChanged,
    );
  }
}
