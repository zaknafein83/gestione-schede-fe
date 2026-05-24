import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/locale.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../data/spells_api.dart';
import '../models/spell_models.dart';
import 'spell_detail_dialog.dart';

/// Dialog di ricerca nel catalogo SRD. Restituisce uno [SpellSummary]
/// quando l'utente seleziona un incantesimo, null se annulla.
///
/// Esempio:
/// ```dart
/// final picked = await showSpellPicker(context);
/// if (picked != null) {
///   // aggiungi picked.id alla scheda...
/// }
/// ```
Future<SpellSummary?> showSpellPicker(BuildContext context, {String? initialClass}) {
  return showDialog<SpellSummary>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: _SpellPickerBody(initialClass: initialClass),
      ),
    ),
  );
}

class _SpellPickerBody extends ConsumerStatefulWidget {
  const _SpellPickerBody({this.initialClass});
  final String? initialClass;

  @override
  ConsumerState<_SpellPickerBody> createState() => _SpellPickerBodyState();
}

class _SpellPickerBodyState extends ConsumerState<_SpellPickerBody> {
  final _query = TextEditingController();
  int?    _level;
  String? _school;
  String? _className;
  Timer?  _debounce;

  bool                _loading = false;
  String?             _error;
  List<SpellSummary>  _results = const [];

  @override
  void initState() {
    super.initState();
    _className = widget.initialClass;
    _query.addListener(_scheduleFetch);
    // primo fetch
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _scheduleFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _fetch);
  }

  Future<void> _fetch() async {
    final access = await ref.read(authStorageProvider).loadAccess();
    if (access == null) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      final list = await ref.read(spellsApiProvider).search(
        access,
        q:         _query.text,
        level:     _level,
        school:    _school,
        className: _className,
        limit:     50,
      );
      if (!mounted) return;
      setState(() {
        _results = list;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Text(l10n.spellPickerTitle, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: l10n.actionClose,
              ),
            ],
          ),
        ),
        // Filtri
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: _query,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.spellPickerSearchHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LevelFilter(
                    value: _level,
                    onChanged: (v) {
                      setState(() => _level = v);
                      _fetch();
                    },
                  ),
                  _SchoolFilter(
                    value: _school,
                    onChanged: (v) {
                      setState(() => _school = v);
                      _fetch();
                    },
                  ),
                  _ClassFilter(
                    value: _className,
                    onChanged: (v) {
                      setState(() => _className = v);
                      _fetch();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // Risultati
        Expanded(
          child: _loading && _results.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: TextStyle(color: scheme.error)))
                  : _results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.spellPickerNoResults,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      : Consumer(
                          builder: (context, ref, _) {
                            final lang = ref.watch(localeProvider).asData?.value?.languageCode
                                ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
                            return ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (_, i) => _SpellTile(
                                entry: _results[i],
                                lang:  lang,
                                onSelect: () => Navigator.pop(context, _results[i]),
                                onShowDetail: () => showSpellDetail(context, _results[i].id),
                              ),
                            );
                          },
                        ),
        ),
        if (_loading && _results.isNotEmpty)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.value, required this.onChanged});
  final int? value;
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

class _SchoolFilter extends StatelessWidget {
  const _SchoolFilter({required this.value, required this.onChanged});
  final String? value;
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

class _ClassFilter extends StatelessWidget {
  const _ClassFilter({required this.value, required this.onChanged});
  final String? value;
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

class _SpellTile extends StatelessWidget {
  const _SpellTile({
    required this.entry,
    required this.lang,
    required this.onSelect,
    required this.onShowDetail,
  });

  final SpellSummary entry;
  final String       lang;
  final VoidCallback onSelect;
  final VoidCallback onShowDetail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = <Widget>[
      if (entry.ritual)
        const Chip(label: Text('R'), visualDensity: VisualDensity.compact),
      if (entry.concentration)
        const Chip(label: Text('C'), visualDensity: VisualDensity.compact),
    ];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text(entry.level == 0 ? 'T' : '${entry.level}'),
      ),
      title: Text(entry.displayName(lang)),
      subtitle: Text(
        '${entry.school ?? '—'} · ${entry.classes.join(", ")}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          ...chips,
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: AppL10n.of(context).spellPickerDetails,
            onPressed: onShowDetail,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: AppL10n.of(context).spellPickerAdd,
            onPressed: onSelect,
          ),
        ],
      ),
      onTap: onSelect,
    );
  }
}
