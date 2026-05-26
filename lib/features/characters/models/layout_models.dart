/// Modelli per il layout dashboard custom.
/// Corrispondono ai DTO Java in `it.fsisca.dndsheets.character.dto`.
library;

/// Tipi widget supportati dal canvas. Stesso set definito server-side in
/// `LayoutWidget.VALID_TYPES`. Il backend rifiuta tipi non in questo set
/// con 400 INVALID_WIDGET_TYPE.
enum LayoutWidgetType {
  anagrafica('ANAGRAFICA'),
  stats('STATS'),
  abilities('ABILITIES'),
  saves('SAVES'),
  combat('COMBAT'),
  conditions('CONDITIONS'),
  spellcasting('SPELLCASTING'),
  equip('EQUIP'),
  traits('TRAITS'),
  notes('NOTES'),
  hpTracker('HP_TRACKER'),
  portrait('PORTRAIT');

  const LayoutWidgetType(this.wire);

  /// Stringa serializzata accettata dal backend.
  final String wire;

  static LayoutWidgetType? fromWire(String? s) {
    if (s == null) return null;
    for (final t in values) {
      if (t.wire == s) return t;
    }
    return null;
  }
}

/// Singolo widget posizionato sul canvas.
class LayoutWidget {
  LayoutWidget({
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.z = 0,
    this.configJson,
  });

  LayoutWidgetType type;
  int x;
  int y;
  int w;
  int h;
  int z;
  String? configJson;

  factory LayoutWidget.fromJson(Map<String, dynamic> json) {
    final t = LayoutWidgetType.fromWire(json['type'] as String?);
    if (t == null) {
      throw ArgumentError('LayoutWidget type sconosciuto: ${json['type']}');
    }
    return LayoutWidget(
      type:       t,
      x:          (json['x'] as num?)?.toInt() ?? 0,
      y:          (json['y'] as num?)?.toInt() ?? 0,
      w:          (json['w'] as num?)?.toInt() ?? 1,
      h:          (json['h'] as num?)?.toInt() ?? 1,
      z:          (json['z'] as num?)?.toInt() ?? 0,
      configJson: json['configJson'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.wire,
        'x':    x,
        'y':    y,
        'w':    w,
        'h':    h,
        'z':    z,
        if (configJson != null) 'configJson': configJson,
      };

  LayoutWidget copyWith({int? x, int? y, int? w, int? h, int? z, String? configJson}) =>
      LayoutWidget(
        type:       type,
        x:          x          ?? this.x,
        y:          y          ?? this.y,
        w:          w          ?? this.w,
        h:          h          ?? this.h,
        z:          z          ?? this.z,
        configJson: configJson ?? this.configJson,
      );
}

/// Layout completo della scheda. `isDefault=true` quando l'utente non ha
/// mai salvato un layout custom — il client può renderizzare la vista
/// classica a tab.
class CharacterLayout {
  CharacterLayout({
    required this.id,
    required this.isDefault,
    required this.version,
    required this.widgets,
    this.createdAt,
    this.updatedAt,
  });

  final String?       id;
  final bool          isDefault;
  final int           version;
  final List<LayoutWidget> widgets;
  final DateTime?     createdAt;
  final DateTime?     updatedAt;

  factory CharacterLayout.fromJson(Map<String, dynamic> json) {
    final raws = (json['widgets'] as List<dynamic>?) ?? const [];
    return CharacterLayout(
      id:        json['id']        as String?,
      isDefault: (json['isDefault'] as bool?) ?? false,
      version:   (json['version']  as num?)?.toInt() ?? 1,
      widgets:   raws
          .map((e) => LayoutWidget.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}
