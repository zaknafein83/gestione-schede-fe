import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Breakpoint sopra il quale layout diventa desktop (hero a due colonne,
/// feature grid 4 colonne).
const double _kDesktopBreakpoint = 880;

/// Pagina iniziale pubblica: hero fantasy + CTA store + feature grid + footer.
///
/// CTA primario: "Apri l'app web" → /login (o /home se gia' loggato, gestito
/// dal redirect del router). Le opzioni mobile (iOS / Android) e il catalogo
/// spell pubblico rimandano a /coming-soon?for=...
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n     = AppL10n.of(context);
    final width    = MediaQuery.of(context).size.width;
    final isDesk   = width >= _kDesktopBreakpoint;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HeroSection(isDesktop: isDesk),
              _StoreCtaSection(isDesktop: isDesk),
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
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Gradient deepPurple → indigo notturno, robusto sia in light che dark
    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.primary,
        Color.lerp(scheme.primary, Colors.indigo.shade900, 0.65) ?? scheme.primary,
        Colors.black.withValues(alpha: 0.85),
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: bg),
      child: Stack(
        children: [
          // Scintille decorative di sfondo
          const Positioned.fill(
            child: IgnorePointer(child: _StarsBackground()),
          ),
          // Contenuto vero
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 24,
              vertical:   isDesktop ? 72 : 48,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: _HeroText(l10n: l10n)),
                        const SizedBox(width: 48),
                        const Expanded(flex: 4, child: Center(child: _D20Emblem(size: 240))),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _D20Emblem(size: 140),
                        const SizedBox(height: 24),
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
    final width    = MediaQuery.of(context).size.width;
    final isDesk   = width >= _kDesktopBreakpoint;
    final textAlign = isDesk ? TextAlign.left : TextAlign.center;
    final crossAlign = isDesk ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          l10n.appTitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.landingHeroTitle,
          textAlign: textAlign,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.landingHeroSubtitle,
          textAlign: textAlign,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        // CTA primaria: apri web app
        SizedBox(
          width: isDesk ? null : double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push('/login'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            icon: const Icon(Icons.rocket_launch),
            label: Text(l10n.landingCtaOpenWeb),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.landingCtaOpenWebSub,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}

/// Emblema d20 stilizzato (esagono regolare con sotto-triangoli e un numero "20").
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
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Vertici dell'esagono (punta in alto)
    final hex = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      hex.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    // Glow esterno
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius + 8, glow);

    // Riempimento corpo principale (gradient interno)
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final hexPath = Path()..addPolygon(hex, true);
    canvas.drawPath(hexPath, body);

    // Linee interne: dal centro a ogni vertice (suggerisce le sfaccettature di un d20)
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final v in hex) {
      canvas.drawLine(center, v, line);
    }

    // Triangolo interno (faccia in alto)
    final innerTri = Path()
      ..moveTo(hex[0].dx, hex[0].dy)
      ..lineTo(hex[1].dx, hex[1].dy)
      ..lineTo(hex[5].dx, hex[5].dy)
      ..close();
    canvas.drawPath(
      innerTri,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Bordo esterno
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    // Numero "20" al centro
    final textPainter = TextPainter(
      text: TextSpan(
        text: '20',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.55,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
          shadows: const [
            Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
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

/// Stelline/scintille decorative sullo sfondo dell'hero.
class _StarsBackground extends StatelessWidget {
  const _StarsBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarsPainter());
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // deterministico
    final p = Paint()..color = Colors.white;
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.4 + 0.3;
      p.color = Colors.white.withValues(alpha: rng.nextDouble() * 0.6 + 0.1);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
//                          STORE CTA SECTION
// ============================================================================

class _StoreCtaSection extends StatelessWidget {
  const _StoreCtaSection({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

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
      color: scheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical:   isDesktop ? 56 : 40,
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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 36, color: scheme.onSurface),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prefix.toUpperCase(),
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
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
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: scheme.outline),
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
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    final features = <_FeatureData>[
      _FeatureData(Icons.assignment_ind, l10n.landingFeatureSheetTitle,  l10n.landingFeatureSheetDesc),
      _FeatureData(Icons.casino,          l10n.landingFeatureDiceTitle,   l10n.landingFeatureDiceDesc),
      _FeatureData(Icons.share,           l10n.landingFeatureShareTitle,  l10n.landingFeatureShareDesc),
      _FeatureData(Icons.auto_stories,    l10n.landingFeatureSpellsTitle, l10n.landingFeatureSpellsDesc),
    ];

    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerLow,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical:   isDesktop ? 72 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.landingFeaturesTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, c) {
                  final cross = c.maxWidth >= 800 ? 4 : (c.maxWidth >= 520 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: cross == 1 ? 3.2 : (cross == 2 ? 1.6 : 1.0),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(f.icon, color: scheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            f.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              f.desc,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, height: 1.4),
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => context.push('/privacy'),
                    child: Text(l10n.landingFooterPrivacy),
                  ),
                  TextButton(
                    onPressed: () => context.push('/terms'),
                    child: Text(l10n.landingFooterTerms),
                  ),
                  TextButton(
                    onPressed: () => context.push('/cookies'),
                    child: const Text('Cookie'),
                  ),
                  TextButton(
                    onPressed: () => context.push('/contact'),
                    child: Text(l10n.landingFooterContact),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.aboutSrdCredit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
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
