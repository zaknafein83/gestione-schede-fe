import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';

/// Tipologie di campo supportate dall'editor scheda.
/// Determinano keyboard, input formatter e validator.
enum EditorFieldKind { text, intAny, intMin0, intRanged, decimalMin0 }

/// Campo testo/numerico standard dell'editor. Per i campi numerici applica
/// validator inline (min/max/range) — un value invalido fa fallire
/// `Form.validate()` e blocca l'autosave.
Widget editorTextField(
  TextEditingController c, {
  required String label,
  EditorFieldKind kind = EditorFieldKind.text,
  int? min,
  int? max,
  int maxLines = 1,
  String? helperText,
}) {
  final isInt     = kind == EditorFieldKind.intAny
      || kind == EditorFieldKind.intMin0
      || kind == EditorFieldKind.intRanged;
  final isDecimal = kind == EditorFieldKind.decimalMin0;
  return Builder(builder: (ctx) {
    final l10n = AppL10n.of(ctx);
    return TextFormField(
      controller: c,
      keyboardType: isInt
          ? TextInputType.numberWithOptions(decimal: false, signed: kind == EditorFieldKind.intAny)
          : isDecimal
              ? const TextInputType.numberWithOptions(decimal: true, signed: false)
              : TextInputType.multiline,
      inputFormatters: isInt
          ? [kind == EditorFieldKind.intAny
                ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                : FilteringTextInputFormatter.digitsOnly]
          : isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : null,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 2 : 1,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        helperText: helperText,
      ),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return null;
        if (isInt) {
          final n = int.tryParse(t);
          if (n == null) return l10n.editorValidatorEnterNumber;
          if (kind == EditorFieldKind.intMin0 && n < 0) return l10n.editorValidatorMinZero;
          if (kind == EditorFieldKind.intRanged) {
            if (min != null && n < min) return l10n.editorValidatorMinN(min);
            if (max != null && n > max) return l10n.editorValidatorMaxN(max);
          }
        } else if (isDecimal) {
          final d = double.tryParse(t);
          if (d == null) return l10n.editorValidatorEnterNumber;
          if (d < 0)     return l10n.editorValidatorMinZero;
        }
        return null;
      },
    );
  });
}

/// Riga responsive: si comporta come Row su layout >= 500px (con Expanded e
/// gap fra elementi), si rompe in Column quando lo spazio è insufficiente.
/// I SizedBox spaziatori vengono omessi nel layout Column.
Widget editorRow(List<Widget> children) {
  return LayoutBuilder(builder: (context, c) {
    if (c.maxWidth < 500) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in children)
            if (w is! SizedBox)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: w,
              ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  });
}
