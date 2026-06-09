import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../core/locale.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../data/spells_api.dart';
import '../models/spell_models.dart';

/// Mostra il dettaglio completo di uno spell (fetch via API).
Future<void> showSpellDetail(BuildContext context, String spellId) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: _SpellDetailBody(spellId: spellId),
      ),
    ),
  );
}

/// Variante che mostra un detail gia' caricato (es. dalla scheda con i campi
/// snapshot espansi). Non fa fetch — utile per spell del catalogo che il
/// frontend ha gia' ricevuto dentro la response /characters/{id}.
Future<void> showSpellDetailFromData(BuildContext context, SpellDetail detail) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: _DetailContent(detail: detail),
      ),
    ),
  );
}

class _SpellDetailBody extends ConsumerStatefulWidget {
  const _SpellDetailBody({required this.spellId});
  final String spellId;

  @override
  ConsumerState<_SpellDetailBody> createState() => _SpellDetailBodyState();
}

class _SpellDetailBodyState extends ConsumerState<_SpellDetailBody> {
  late Future<SpellDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<SpellDetail> _load() async {
    // accessToken opzionale: l'endpoint è pubblico. Lo allego se l'utente è
    // loggato, ma il dialog funziona anche senza (chiamata dalla landing).
    final access = await ref.read(authStorageProvider).loadAccess();
    return ref.read(spellsApiProvider).get(access, widget.spellId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SpellDetail>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final msg = snap.error is ApiError
              ? (snap.error as ApiError).detail
              : snap.error.toString();
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          );
        }
        return _DetailContent(detail: snap.data!);
      },
    );
  }
}

class _DetailContent extends ConsumerStatefulWidget {
  const _DetailContent({required this.detail});
  final SpellDetail detail;

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  /// Lingua selezionata per la visualizzazione. null = segui app locale.
  String? _langOverride;

  String _resolveLang() {
    if (_langOverride != null) return _langOverride!;
    final appLocale = ref.read(localeProvider).asData?.value?.languageCode
        ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return appLocale == 'it' ? 'it' : 'en';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t      = Theme.of(context).textTheme;

    final lang = _resolveLang();
    final view = widget.detail.view(lang);
    final hasIt = widget.detail.translations.containsKey('it');

    final l10n = AppL10n.of(context);
    final chips = <Widget>[
      if (view.ritual)
        Chip(label: Text(l10n.customSpellRitual), backgroundColor: scheme.tertiaryContainer),
      if (view.concentration)
        Chip(label: Text(l10n.customSpellConcentration), backgroundColor: scheme.secondaryContainer),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(view.name, style: t.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${formatSpellLevel(view.level)}'
                      '${view.school != null ? " · ${view.school}" : ""}',
                      style: t.bodyMedium?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              if (hasIt)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _LangToggle(
                    current: lang,
                    onChanged: (l) => setState(() => _langOverride = l),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: l10n.actionClose,
              ),
            ],
          ),
        ),
        if (chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 6, runSpacing: 4, children: chips),
          ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lang == 'it' && hasIt)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: scheme.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.spellAiTranslationNotice,
                            style: t.bodySmall?.copyWith(
                              color: scheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _row(_l(lang, 'Casting Time', 'Tempo di lancio'), view.castingTime),
                _row(_l(lang, 'Range',        'Gittata'),         view.range),
                _row(_l(lang, 'Components',   'Componenti'),
                     view.components.short(materialOverride: view.materialDescription)),
                _row(_l(lang, 'Duration',     'Durata'),          view.duration),
                if (view.classes.isNotEmpty)
                  _row(_l(lang, 'Classes', 'Classi'), view.classes.join(', ')),
                if (view.source != null) _row(_l(lang, 'Source', 'Fonte'), view.source),
                const SizedBox(height: 16),
                if (view.description != null) ...[
                  Text(_l(lang, 'Description', 'Descrizione'), style: t.titleSmall),
                  const SizedBox(height: 6),
                  Text(view.description!, style: t.bodyMedium),
                ],
                if (view.atHigherLevels != null) ...[
                  const SizedBox(height: 16),
                  Text(_l(lang, 'At Higher Levels', 'A livelli superiori'),
                       style: t.titleSmall),
                  const SizedBox(height: 6),
                  Text(view.atHigherLevels!, style: t.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _l(String lang, String en, String it) => lang == 'it' ? it : en;

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Builder(
        builder: (context) {
          final t = Theme.of(context).textTheme;
          return RichText(
            text: TextSpan(
              style: t.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Toggle compatto IT/EN. Mostra solo se la lingua corrente è 'it' o 'en'.
class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: const [
        ButtonSegment(value: 'it', label: Text('IT')),
        ButtonSegment(value: 'en', label: Text('EN')),
      ],
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
