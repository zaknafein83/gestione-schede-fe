import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/locale.dart';
import '../../../core/smart_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../data/spells_api.dart';
import '../models/spell_models.dart';
import 'spell_detail_dialog.dart';

/// Schermata pubblica del catalogo SRD. Accessibile sia da loggati che da
/// non-loggati (route `/spells`). Riutilizza lo stesso pattern del picker
/// dialog ma è full-screen e senza azione di "select" (sola consultazione).
///
/// L'accessToken viene preso da storage se presente: l'endpoint backend è
/// pubblico, ma per consistenza passiamo l'header se l'utente è autenticato.
class SpellCatalogScreen extends ConsumerStatefulWidget {
  const SpellCatalogScreen({super.key});

  @override
  ConsumerState<SpellCatalogScreen> createState() => _SpellCatalogScreenState();
}

class _SpellCatalogScreenState extends ConsumerState<SpellCatalogScreen> {
  final _query = TextEditingController();
  int?    _level;
  String? _school;
  String? _className;
  /// Tri-state: null = nessun filtro, true = solo rituali, false = non gestito.
  bool?   _ritualOnly;
  /// Tri-state: null = nessun filtro, true = solo concentrazione, false = non gestito.
  bool?   _concentrationOnly;
  Timer?  _debounce;

  bool               _loading = false;
  String?            _error;
  List<SpellSummary> _results = const [];
  int                _total   = 0;

  @override
  void initState() {
    super.initState();
    _query.addListener(_scheduleFetch);
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
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error   = null;
    });
    final access = await ref.read(authStorageProvider).loadAccess();
    try {
      final api = ref.read(spellsApiProvider);
      // Fetch lista + count in parallelo.
      final results = await api.search(
        access,
        q:             _query.text,
        level:         _level,
        school:        _school,
        className:     _className,
        ritual:        _ritualOnly,
        concentration: _concentrationOnly,
        limit:         100,
      );
      final total = await api.count(
        access,
        q:             _query.text,
        level:         _level,
        school:        _school,
        className:     _className,
        ritual:        _ritualOnly,
        concentration: _concentrationOnly,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _total   = total;
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
    return Scaffold(
      appBar: AppBar(
        leading: smartBackButton(context, fallback: '/'),
        title: Text(l10n.spellCatalogTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _query,
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
                        FilterChip(
                          label: Text(l10n.spellFilterRitualOnly),
                          avatar: const Text('R'),
                          selected: _ritualOnly == true,
                          onSelected: (sel) {
                            setState(() => _ritualOnly = sel ? true : null);
                            _fetch();
                          },
                        ),
                        FilterChip(
                          label: Text(l10n.spellFilterConcentrationOnly),
                          avatar: const Text('C'),
                          selected: _concentrationOnly == true,
                          onSelected: (sel) {
                            setState(() => _concentrationOnly = sel ? true : null);
                            _fetch();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.spellCatalogResultsCount(_total, _results.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
                                    itemBuilder: (_, i) => _SpellRow(
                                      entry: _results[i],
                                      lang:  lang,
                                      onTap: () => showSpellDetail(context, _results[i].id),
                                    ),
                                  );
                                },
                              ),
              ),
              if (_loading && _results.isNotEmpty)
                const LinearProgressIndicator(minHeight: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget locali — duplicati dal picker dialog (vedi TODO refactor).
// ---------------------------------------------------------------------------

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

/// Tile semplificato per il browse pubblico: tap apre il dialog di
/// dettaglio. Niente bottone "select" (non c'è una scheda dove aggiungere).
class _SpellRow extends StatelessWidget {
  const _SpellRow({
    required this.entry,
    required this.lang,
    required this.onTap,
  });

  final SpellSummary entry;
  final String       lang;
  final VoidCallback onTap;

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
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
