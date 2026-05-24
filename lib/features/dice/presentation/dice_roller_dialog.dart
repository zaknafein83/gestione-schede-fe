import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/dice_history.dart';
import '../logic/dice.dart';

/// Mostra il dialog del dice roller. Se [initialFormula] e' fornita,
/// il campo formula viene pre-popolato. Se [characterId] e' fornito,
/// i tiri verranno persistiti collegati a quella scheda.
Future<void> showDiceRoller(
  BuildContext context, {
  String? initialFormula,
  String? characterId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DiceRollerDialog(
      initialFormula: initialFormula,
      characterId:    characterId,
    ),
  );
}

class _DiceRollerDialog extends ConsumerStatefulWidget {
  const _DiceRollerDialog({this.initialFormula, this.characterId});
  final String? initialFormula;
  final String? characterId;

  @override
  ConsumerState<_DiceRollerDialog> createState() => _DiceRollerDialogState();
}

class _DiceRollerDialogState extends ConsumerState<_DiceRollerDialog> {
  late final TextEditingController _formula;
  bool _advantage = false;
  bool _disadvantage = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _formula = TextEditingController(text: widget.initialFormula ?? '1d20');
  }

  @override
  void dispose() {
    _formula.dispose();
    super.dispose();
  }

  void _onAdv(bool v) => setState(() {
        _advantage = v;
        if (v) _disadvantage = false;
      });

  void _onDis(bool v) => setState(() {
        _disadvantage = v;
        if (v) _advantage = false;
      });

  void _roll() {
    setState(() => _error = null);
    try {
      final roll = rollFormula(
        _formula.text,
        advantage:    _advantage,
        disadvantage: _disadvantage,
      );
      ref.read(diceHistoryProvider.notifier)
          .add(roll, characterId: widget.characterId);
    } on DiceParseException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n         = AppL10n.of(context);
    final historyAsync = ref.watch(diceHistoryProvider);
    final history = historyAsync.asData?.value ?? const <DiceRoll>[];
    final loading = historyAsync.isLoading && history.isEmpty;
    final last    = history.isEmpty ? null : history.first;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.casino),
                  const SizedBox(width: 8),
                  Text(l10n.diceTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.actionClose,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _formula,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.diceFormulaLabel,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onSubmitted: (_) => _roll(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _advantage,
                      onChanged: (v) => _onAdv(v ?? false),
                      title: Text(l10n.diceAdvantage),
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _disadvantage,
                      onChanged: (v) => _onDis(v ?? false),
                      title: Text(l10n.diceDisadvantage),
                      dense: true,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _roll,
                  icon: const Icon(Icons.casino),
                  label: Text(l10n.diceRollButton),
                ),
              ),
              const SizedBox(height: 12),
              if (last != null) _LastResultCard(roll: last),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(l10n.diceHistory,
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  if (history.isNotEmpty)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(diceHistoryProvider.notifier).clear(),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: Text(l10n.diceClear),
                    ),
                ],
              ),
              Flexible(
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : history.length <= 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              history.isEmpty
                                  ? l10n.diceNoRollsYet
                                  : l10n.diceNoOtherRolls,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: history.length - 1,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (_, i) => _HistoryTile(roll: history[i + 1]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastResultCard extends StatelessWidget {
  const _LastResultCard({required this.roll});
  final DiceRoll roll;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(roll.formula,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (roll.advantage)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(label: Text(l10n.diceAdvantage), visualDensity: VisualDensity.compact),
                        ),
                      if (roll.disadvantage)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(label: Text(l10n.diceDisadvantage), visualDensity: VisualDensity.compact),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(roll.breakdown(),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${roll.total}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.roll});
  final DiceRoll roll;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text('${roll.formula} = ${roll.total}',
          style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(roll.breakdown(),
          style: Theme.of(context).textTheme.bodySmall),
      trailing: roll.advantage
          ? const Icon(Icons.trending_up, size: 18)
          : roll.disadvantage
              ? const Icon(Icons.trending_down, size: 18)
              : null,
    );
  }
}
