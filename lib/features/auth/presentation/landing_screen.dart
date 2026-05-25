import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart' show kFontDisplay;
import '../../../l10n/app_localizations.dart';

/// Sopra questa larghezza il layout diventa "desktop":
/// hero a due colonne, feature grid 4 colonne.
const double _kDesktopBreakpoint = 880;

/// Palette fantasy condivisa dalla landing.
class _Palette {
  // Sfondo profondo
  static const ink       = Color(0xFF0B0712); // quasi nero, leggermente viola
  static const violet    = Color(0xFF2D1657); // viola scuro
  static const violet2   = Color(0xFF1A0E33); // ancora più scuro

  // Oro per accenti, glow, runi
  static const gold      = Color(0xFFD4AF37); // oro classico
  static const goldSoft  = Color(0xFFE6C56C); // ambra luminosa
  static const goldDim   = Color(0xFFB4912F); // oro spento
}

/// Alias locale del font display globale (vedi theme.dart). Lo manteniamo
/// solo per i CustomPaint dove abbiamo bisogno della costante a livello di
/// codice (TextSpan/TextPainter non leggono dal theme automaticamente).
const String _fontDisplay = kFontDisplay;

/// Pagina iniziale pubblica con estetica fantasy: hero "epico" + CTA store +
/// griglia delle arti del Cronista + footer ornamentale.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final width  = MediaQuery.of(context).size.width;
    final isDesk = width >= _kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: _Palette.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HeroSection(isDesktop: isDesk),
              const _OrnamentDivider(),
              _StoreCtaSection(isDesktop: isDesk),
              const _OrnamentDivider(),
              _FeaturesSection(isDesktop: isDesk),
              _Footer(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//                              HERO SECTION
// ============================================================================

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Gradient profondo: viola → nero. È il livello base che sta sotto la
    // foto, così se l'immagine è lenta a caricare l'utente vede comunque
    // qualcosa di "epico".
    final bg = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_Palette.violet, _Palette.violet2, _Palette.ink],
      stops: [0.0, 0.55, 1.0],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: bg),
      child: Stack(
        children: [
          // 1. Foto Pixabay: paesaggio fantasy (torrente nevoso) sfumato col
          //    nero in basso e con un overlay scuro per garantire contrasto
          //    sul testo. "Image by Placidplace from Pixabay".
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCCFFFFFF), // foto al ~80% in alto
                    Color(0x66FFFFFF), // sfuma verso il basso
                    Color(0x00FFFFFF), // trasparente in fondo
                  ],
                  stops: [0.0, 0.6, 1.0],
                ).createShader(rect),
                child: Image.asset(
                  'assets/landing/hero_scenery.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // 2. Overlay scuro per leggibilità: gradiente nero ~50% al centro
          //    e quasi opaco ai bordi, così il testo (specialmente bianco)
          //    resta sempre leggibile sopra qualsiasi punto della foto.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _Palette.ink.withValues(alpha: 0.55),
                      _Palette.ink.withValues(alpha: 0.45),
                      _Palette.ink.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // 3. Scintille + glow centrale + silhouette montagne in basso
          const Positioned.fill(
            child: IgnorePointer(child: _FantasyBackground()),
          ),
          // Contenuto vero
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 24,
              vertical:   isDesktop ? 88 : 56,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: _HeroText(l10n: l10n)),
                        const SizedBox(width: 56),
                        const Expanded(flex: 4, child: Center(child: _D20Emblem(size: 280))),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _D20Emblem(size: 160),
                        const SizedBox(height: 32),
                        _HeroText(l10n: l10n),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.l10n});
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesk = width >= _kDesktopBreakpoint;
    final align  = isDesk ? TextAlign.left : TextAlign.center;
    final cross  = isDesk ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: cross,
      children: [
        // Eyebrow: linee + label in oro
        _Eyebrow(text: l10n.landingHeroEyebrow.toUpperCase(), centered: !isDesk),
        const SizedBox(height: 18),
        Text(
          l10n.landingHeroTitle,
          textAlign: align,
          style: const TextStyle(
            fontFamily: _fontDisplay,
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: 1.5,
            shadows: [
              Shadow(blurRadius: 16, color: Colors.black87, offset: Offset(0, 2)),
              Shadow(blurRadius: 32, color: Color(0x66D4AF37), offset: Offset(0, 0)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.landingHeroSubtitle,
          textAlign: align,
          style: const TextStyle(
            color: Color(0xFFD8CFE8), // lavanda chiara, più calda del white70
            fontSize: 17,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // CTA primario: fondo oro + testo viola scuro
        SizedBox(
          width: isDesk ? null : double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push('/login'),
            style: FilledButton.styleFrom(
              backgroundColor: _Palette.gold,
              foregroundColor: _Palette.ink,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: _Palette.goldSoft, width: 1.5),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(l10n.landingCtaOpenWeb),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.landingCtaOpenWebSub,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
        ),
      ],
    );
  }
}

/// "Eyebrow" decorativa: linee orizzontali oro + testo piccolo letterSpaced.
/// Stile da quarta di copertina di un libro fantasy.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text, this.centered = false});
  final String text;
  final bool   centered;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 36,
      height: 1,
      color: _Palette.gold.withValues(alpha: 0.7),
    );
    final children = <Widget>[
      line,
      const SizedBox(width: 12),
      Text(
        text,
        style: const TextStyle(
          fontFamily: _fontDisplay,
          color: _Palette.goldSoft,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      const SizedBox(width: 12),
      line,
    ];
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.min,
      children: children,
    );
  }
}

// ============================================================================
//                              D20 EMBLEM
// ============================================================================

/// Emblema d20 con glow dorato, sfaccettature, bordo oro e "20" centrale.
class _D20Emblem extends StatelessWidget {
  const _D20Emblem({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size,
      height: size,
      child: CustomPaint(painter: _D20Painter()),
    );
  }
}

class _D20Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;

    // Vertici dell'esagono (punta in alto)
    final hex = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      hex.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    // Glow esterno dorato (multi-pass per soft halo)
    for (final r in [radius + 32, radius + 18, radius + 8]) {
      final alpha = (radius + 32 - r) / 24 * 0.16;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = _Palette.goldSoft.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Corpo del d20: gradient interno scuro con sfumatura dorata
    final body = Paint()
      ..shader = RadialGradient(
        colors: [
          _Palette.violet.withValues(alpha: 0.85),
          _Palette.violet2.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final hexPath = Path()..addPolygon(hex, true);
    canvas.drawPath(hexPath, body);

    // Sfaccettature: linee dal centro a ogni vertice
    final line = Paint()
      ..color = _Palette.gold.withValues(alpha: 0.55)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final v in hex) {
      canvas.drawLine(center, v, line);
    }

    // Faccia in alto in evidenza (triangolo)
    final innerTri = Path()
      ..moveTo(hex[0].dx, hex[0].dy)
      ..lineTo(hex[1].dx, hex[1].dy)
      ..lineTo(hex[5].dx, hex[5].dy)
      ..close();
    canvas.drawPath(
      innerTri,
      Paint()
        ..color = _Palette.gold.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Bordo esterno oro brillante
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = _Palette.goldSoft
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.miter,
    );

    // Punti rune ai vertici esterni
    for (final v in hex) {
      canvas.drawCircle(
        v,
        3.5,
        Paint()..color = _Palette.goldSoft,
      );
      canvas.drawCircle(
        v,
        6,
        Paint()
          ..color = _Palette.goldSoft.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Numero "20" centrale in oro
    final textPainter = TextPainter(
      text: TextSpan(
        text: '20',
        style: TextStyle(
          fontFamily: 'Cinzel',
          color: _Palette.goldSoft,
          fontSize: radius * 0.66,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          shadows: const [
            Shadow(blurRadius: 12, color: Colors.black87, offset: Offset(0, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width  / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
//                  Background fantasy: scintille + glow + montagne
// ============================================================================

class _FantasyBackground extends StatelessWidget {
  const _FantasyBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FantasyBgPainter());
  }
}

class _FantasyBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Alone caldo al centro-alto
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.35),
      h * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _Palette.goldSoft.withValues(alpha: 0.10),
            _Palette.goldSoft.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.35),
          radius: h * 0.5,
        )),
    );

    // 2. Scintille / stelle (deterministiche)
    final rng = math.Random(7);
    for (int i = 0; i < 110; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.85; // evita la zona montagne in basso
      final r = rng.nextDouble() * 1.4 + 0.3;
      final color = i % 7 == 0
          ? _Palette.goldSoft.withValues(alpha: rng.nextDouble() * 0.8 + 0.2)
          : Colors.white.withValues(alpha: rng.nextDouble() * 0.55 + 0.15);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
      // halo sottile per i punti più grossi
      if (r > 1.2) {
        canvas.drawCircle(
          Offset(x, y),
          r * 2.5,
          Paint()
            ..color = color.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }

    // 3. Silhouette di montagne in basso (più scure davanti, più chiare dietro)
    void drawRange(double baseY, double amp, double freq, Color color, math.Random r) {
      final path = Path()..moveTo(0, h);
      const step = 14.0;
      double x = 0;
      // peak points pseudo-casuali
      double y = baseY;
      path.lineTo(0, y);
      while (x <= w) {
        // alterna picchi alti e bassi con jitter
        final peakX = x + step + r.nextDouble() * step;
        final peakY = baseY - amp - r.nextDouble() * amp * freq;
        path.lineTo(peakX, peakY);
        x = peakX + step + r.nextDouble() * step;
        path.lineTo(x, baseY + r.nextDouble() * 6);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    // Range lontane (più chiare, viola tendente al lilla)
    drawRange(h * 0.78, 32, 1.2,
        const Color(0xFF1F1136).withValues(alpha: 0.85), math.Random(11));
    // Range medie
    drawRange(h * 0.86, 42, 1.5,
        const Color(0xFF130823).withValues(alpha: 0.95), math.Random(23));
    // Range in primo piano (quasi nere)
    drawRange(h * 0.94, 28, 1.0,
        _Palette.ink, math.Random(37));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
//                          ORNAMENT DIVIDER
// ============================================================================

/// Separatore decorativo: due linee oro che si avvicinano a un simbolo rombico
/// centrale. Usato tra le sezioni.
class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Palette.ink,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _gradientLine()),
              const SizedBox(width: 12),
              const _DiamondMark(),
              const SizedBox(width: 12),
              Expanded(child: _gradientLine(reverse: true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientLine({bool reverse = false}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse
              ? [_Palette.goldDim, Colors.transparent]
              : [Colors.transparent, _Palette.goldDim],
        ),
      ),
    );
  }
}

class _DiamondMark extends StatelessWidget {
  const _DiamondMark();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: _Palette.gold,
          boxShadow: [
            BoxShadow(
              color: _Palette.goldSoft.withValues(alpha: 0.55),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//                          STORE CTA SECTION
// ============================================================================

class _StoreCtaSection extends StatelessWidget {
  const _StoreCtaSection({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final tiles = [
      _StoreTile(
        icon: Icons.phone_iphone,
        prefix: l10n.landingCtaStorePrefix,
        label: l10n.landingCtaAppStore,
        onTap: () => context.push('/coming-soon?for=ios'),
      ),
      _StoreTile(
        icon: Icons.android,
        prefix: l10n.landingCtaStorePrefix,
        label: l10n.landingCtaGooglePlay,
        onTap: () => context.push('/coming-soon?for=android'),
      ),
      _StoreTile(
        icon: Icons.auto_stories,
        prefix: l10n.landingCtaStorePrefix,
        label: l10n.landingCtaSpells,
        sublabel: l10n.landingCtaSpellsSub,
        onTap: () => context.push('/coming-soon?for=spells'),
      ),
    ];

    return Container(
      width: double.infinity,
      color: _Palette.ink,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical:   isDesktop ? 48 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isDesktop
              ? Row(
                  children: [
                    for (int i = 0; i < tiles.length; i++) ...[
                      Expanded(child: tiles[i]),
                      if (i < tiles.length - 1) const SizedBox(width: 16),
                    ],
                  ],
                )
              : Column(
                  children: [
                    for (int i = 0; i < tiles.length; i++) ...[
                      tiles[i],
                      if (i < tiles.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.icon,
    required this.prefix,
    required this.label,
    required this.onTap,
    this.sublabel,
  });

  final IconData icon;
  final String   prefix;
  final String   label;
  final String?  sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.violet2.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _Palette.gold.withValues(alpha: 0.35), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Icona dentro un quadrato dorato traslucido
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _Palette.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _Palette.gold.withValues(alpha: 0.5)),
                ),
                child: Icon(icon, size: 24, color: _Palette.goldSoft),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prefix.toUpperCase(),
                      style: const TextStyle(
                        color: _Palette.goldSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sublabel!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: _Palette.gold.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//                          FEATURES SECTION
// ============================================================================

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final features = <_FeatureData>[
      _FeatureData(Icons.assignment_ind, l10n.landingFeatureSheetTitle,  l10n.landingFeatureSheetDesc),
      _FeatureData(Icons.casino,          l10n.landingFeatureDiceTitle,   l10n.landingFeatureDiceDesc),
      _FeatureData(Icons.share,           l10n.landingFeatureShareTitle,  l10n.landingFeatureShareDesc),
      _FeatureData(Icons.auto_stories,    l10n.landingFeatureSpellsTitle, l10n.landingFeatureSpellsDesc),
    ];

    return Container(
      width: double.infinity,
      color: _Palette.ink,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical:   isDesktop ? 64 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _DiamondMark(),
              const SizedBox(height: 18),
              Text(
                l10n.landingFeaturesTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _fontDisplay,
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  l10n.landingFeaturesSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, c) {
                  final cross = c.maxWidth >= 800 ? 4 : (c.maxWidth >= 520 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: cross == 1 ? 3.2 : (cross == 2 ? 1.55 : 0.95),
                    children: features.map((f) => _FeatureCard(f: f)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String   title;
  final String   desc;
  const _FeatureData(this.icon, this.title, this.desc);
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.f});
  final _FeatureData f;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.violet2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.gold.withValues(alpha: 0.30)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container ambrato (con glow leggero)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _Palette.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _Palette.gold.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: _Palette.goldSoft.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(f.icon, color: _Palette.goldSoft, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            f.title,
            style: const TextStyle(
              fontFamily: _fontDisplay,
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              f.desc,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//                              FOOTER
// ============================================================================

class _Footer extends StatelessWidget {
  const _Footer({required this.l10n});
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final dimWhite = Colors.white.withValues(alpha: 0.55);
    final dotStyle = TextStyle(color: _Palette.gold.withValues(alpha: 0.7));

    Widget link(String label, String to) => TextButton(
          onPressed: () => context.push(to),
          style: TextButton.styleFrom(
            foregroundColor: _Palette.goldSoft,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        );

    return Container(
      width: double.infinity,
      color: _Palette.ink,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Brand "Made by Zaknafein": logo Z piccolo + scritta in Cinzel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    // L'immagine è nera; invertita diventa color crema. Aggiungo
                    // poi una sfumatura gold via tint per integrarsi col tema.
                    colorFilter: const ColorFilter.mode(
                      _Palette.goldSoft,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/brand/brand-z.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.landingMadeBy,
                    style: const TextStyle(
                      fontFamily:    kFontDisplay,
                      color:         _Palette.goldSoft,
                      fontSize:      13,
                      fontWeight:    FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  link(l10n.landingFooterPrivacy, '/privacy'),
                  Text(' ✦ ', style: dotStyle),
                  link(l10n.landingFooterTerms, '/terms'),
                  Text(' ✦ ', style: dotStyle),
                  link('Cookie', '/cookies'),
                  Text(' ✦ ', style: dotStyle),
                  link(l10n.landingFooterContact, '/contact'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.aboutSrdCredit,
                style: TextStyle(
                  color: dimWhite,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.landingImageCredit,
                style: TextStyle(
                  color: dimWhite,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
