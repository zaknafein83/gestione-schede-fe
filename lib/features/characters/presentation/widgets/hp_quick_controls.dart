import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../logic/conditions_catalog.dart';
import '../character_editor_controller.dart';
import 'conditions_dialog.dart';

/// Modalità di visualizzazione dell'HP quick controls.
///  - compact: usato sopra il TabBar dell'editor classico
///  - expanded: usato dentro il Combat tab
enum HpControlsMode { compact, expanded }

/// Mostra HP correnti/max + temp HP + bottoni rapidi -1/+1 + bottone
/// "Modifica" che apre un dialog cura/danno. Reattivo ai controllers HP
/// del controller.
class HpQuickControlsWidget extends StatelessWidget {
  const HpQuickControlsWidget({
    super.key,
    required this.controller,
    required this.mode,
  });

  final CharacterEditorController controller;
  final HpControlsMode mode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.hpCurrent, controller.hpMax, controller.hpTemp,
      ]),
      builder: (context, _) {
        final cur  = controller.hpCurrentValue;
        final max  = controller.hpMaxValue;
        final temp = controller.hpTempValue ?? 0;

        final hpText = '${cur ?? "—"} / ${max ?? "—"}';

        final scheme = Theme.of(context).colorScheme;
        final isAtZero = cur != null && cur <= 0;
        final lowHp    = cur != null && max != null && cur > 0 && cur <= (max / 4);

        Color color = scheme.onSurface;
        if (isAtZero) {
          color = scheme.error;
        } else if (lowHp) {
          color = scheme.tertiary;
        }

        final hpStyle = (mode == HpControlsMode.compact
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(color: color, fontWeight: FontWeight.bold);

        final activeConditions = controller.conditions
            .map((k) => findCondition(k))
            .whereType<ConditionEntry>()
            .toList();

        return Card(
          color: scheme.surfaceContainerHighest,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mode == HpControlsMode.compact ? 12 : 16,
              vertical:   mode == HpControlsMode.compact ? 6  : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: 20, color: scheme.error),
                    const SizedBox(width: 8),
                    Text(AppL10n.of(context).sheetHpLabel,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Text(hpText, style: hpStyle),
                    if (temp > 0) ...[
                      const SizedBox(width: 8),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text('+$temp temp'),
                        backgroundColor: scheme.tertiaryContainer,
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: '-1',
                      icon: const Icon(Icons.remove),
                      onPressed: () => controller.adjustHp(-1),
                    ),
                    IconButton(
                      tooltip: '+1',
                      icon: const Icon(Icons.add),
                      onPressed: () => controller.adjustHp(1),
                    ),
                    if (mode == HpControlsMode.expanded) ...[
                      const SizedBox(width: 4),
                      FilledButton.tonalIcon(
                        onPressed: () => _showHpDialog(context, controller),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(AppL10n.of(context).actionEdit),
                      ),
                    ] else
                      IconButton(
                        tooltip: AppL10n.of(context).editorHpDialogTitle,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showHpDialog(context, controller),
                      ),
                  ],
                ),
                if (activeConditions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final c in activeConditions)
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(Icons.warning_amber_rounded,
                              size: 14, color: scheme.error),
                          label: Text(labelForCondition(c.key, AppL10n.of(context)),
                              style: Theme.of(context).textTheme.bodySmall),
                          backgroundColor: scheme.errorContainer,
                          onPressed: () => showConditionInfo(context, c),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showHpDialog(BuildContext context, CharacterEditorController controller) {
  return showDialog<void>(
    context: context,
    builder: (_) => _HpDialog(controller: controller),
  );
}

class _HpDialog extends StatefulWidget {
  const _HpDialog({required this.controller});
  final CharacterEditorController controller;

  @override
  State<_HpDialog> createState() => _HpDialogState();
}

class _HpDialogState extends State<_HpDialog> {
  final _amount   = TextEditingController();
  final _tempCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempCtrl.text = widget.controller.hpTemp.text;
  }

  @override
  void dispose() {
    _amount.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  int? get _value => int.tryParse(_amount.text.trim());

  void _heal() {
    final v = _value;
    if (v == null || v <= 0) return;
    widget.controller.applyHealing(v);
    Navigator.pop(context);
  }

  void _damage() {
    final v = _value;
    if (v == null || v <= 0) return;
    widget.controller.applyDamage(v);
    Navigator.pop(context);
  }

  void _applyTemp() {
    final v = int.tryParse(_tempCtrl.text.trim());
    // PHB: i PF temporanei non si stackano, prendi il massimo
    final cur = widget.controller.hpTempValue ?? 0;
    final next = (v == null || v < 0) ? 0 : (v > cur ? v : cur);
    widget.controller.setHpTemp(next);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(l10n.editorHpDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.editorHpQuantityLabel,
                hintText: l10n.editorHpQuantityHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _heal,
                    icon: const Icon(Icons.healing_outlined),
                    label: Text(l10n.editorHpHeal),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _damage,
                    icon: const Icon(Icons.local_fire_department_outlined),
                    label: Text(l10n.editorHpDamage),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _tempCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.editorHpTempLabel,
                helperText: l10n.editorHpTempHelper,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _applyTemp,
                child: Text(l10n.editorHpTempApply),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}
