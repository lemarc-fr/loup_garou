import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NightScene extends StatefulWidget {
  const NightScene({super.key, this.horizon = 0.62, this.hillX = 0.3});

  /// Hauteur (0..1) de la crête sur laquelle se tient le loup.
  final double horizon;

  /// Position horizontale (0 = bord gauche, 1 = bord droit) du sommet de la colline.
  final double hillX;

  @override
  State<NightScene> createState() => _NightSceneState();
}

class _NightSceneState extends State<NightScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  Offset _tilt = Offset.zero; // valeur lissée, -1..1
  Offset _target = Offset.zero; // valeur visée (doigt)

  @override
  void initState() {
    super.initState();
    // Lissage du mouvement à chaque frame
    _c.addListener(() => _tilt = Offset.lerp(_tilt, _target, 0.06)!);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// depth : 0 = très loin (bouge peu), 1 = premier plan (bouge beaucoup)
  Widget _layer(double depth, Widget child) {
    final sway = math.sin(_c.value * 2 * math.pi * 2); // léger balancement
    final dx = (_tilt.dx * 18 + sway * 5) * depth;
    final dy = (_tilt.dy * 8) * depth;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(scale: 1.12, child: child), // évite les bords vides
    );
  }

  void _updateTilt(Offset p, Size s) {
    _target = Offset((p.dx / s.width) * 2 - 1, (p.dy / s.height) * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final size = box.biggest;
      final wolfH = size.height * 0.2;
      final wolfW = wolfH * 1.1;
      final bumpH = size.height * 0.035;
      const fg = Color(0xFF05060C);

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (d) => _updateTilt(d.localPosition, size),
        onPanEnd: (_) => _target = Offset.zero,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Ciel
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF05060F), Color(0xFF151A3A), Color(0xFF2B3265)],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                  _layer(0.05, CustomPaint(painter: _StarsPainter(t))),
                  _layer(0.15, CustomPaint(painter: _MoonPainter(t))),
                  _layer(0.25, CustomPaint(painter: _FogPainter(t, 0.50, 1, 0.10))),
                  // Montagnes lointaines
                  _layer(0.35, CustomPaint(painter: _RidgePainter(
                      color: const Color(0xFF1F2547), base: 0.50, amp: 50, seed: 3))),
                  // Forêt de sapins (2 plans)
                  _layer(0.55, CustomPaint(painter: _RidgePainter(
                      color: const Color(0xFF121631), base: 0.56, amp: 30, seed: 8, trees: true))),
                  _layer(0.75, CustomPaint(painter: _RidgePainter(
                      color: const Color(0xFF0A0C1E), base: 0.60, amp: 22, seed: 21, trees: true))),
                  _layer(0.85, CustomPaint(painter: _FogPainter(t, 0.60, 2, 0.12))),
                  // Premier plan : rocher + loup
                  _layer(
                    1.0,
                    Stack(children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RidgePainter(
                            color: fg,
                            base: widget.horizon,
                            amp: 0,
                            seed: 1,
                            bumpAt: widget.hillX,
                            bumpH: bumpH,
                            bumpW: 0.28,
                          ),
                        ),
                      ),
                      Positioned(
                        left: size.width * widget.hillX - wolfW / 2,
                        top: size.height * widget.horizon - bumpH - wolfH + wolfH * 0.07,
                        width: wolfW,
                        height: wolfH,
                        child: SvgPicture.asset(
                          'assets/images/wolf_howling.svg',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter, // ← les pattes touchent le bas de la boîte
                          colorFilter: const ColorFilter.mode(fg, BlendMode.srcIn),
                        ),
                      ),
                    ]),
                  ),
                  // Vignette pour assombrir les bords
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.1,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                          stops: const [0.6, 1],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

// ───────────── Étoiles qui scintillent ─────────────
class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(42);
    final paint = Paint();
    for (var i = 0; i < 110; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height * 0.55;
      final radius = 0.4 + r.nextDouble() * 1.2;
      final freq = 10 + r.nextInt(15); // entier => boucle parfaite
      final phase = r.nextDouble();
      final a = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(2 * math.pi * (t * freq + phase)));
      paint.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}

// ───────────── Lune + halo qui pulse ─────────────
class _MoonPainter extends CustomPainter {
  _MoonPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.32);
    final rad = math.min(size.width * 0.2, 153.toDouble());
    final pulse = 0.85 + 0.15 * math.sin(2 * math.pi * t * 6);

    const halo = Color(0xFFFFA070);   // ambre pour le halo
    const moonLight = Color(0xFFFFF1CC); // crème au centre
    const moonEdge = Color(0xFFF2C77E);  // doré sur les bords

    // Halo
    final glowRect = Rect.fromCircle(center: c, radius: rad * 3.2);
    canvas.drawCircle(
      c,
      rad * 3.2,
      Paint()
        ..shader = RadialGradient(colors: [
          halo.withValues(alpha: 0.38 * pulse),
          halo.withValues(alpha: 0.10 * pulse),
          Colors.transparent,
        ], stops: const [0, 0.45, 1])
            .createShader(glowRect),
    );

    // Disque avec un dégradé pour donner du volume
    final moonRect = Rect.fromCircle(center: c, radius: rad);
    canvas.drawCircle(
      c,
      rad,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [moonLight, moonEdge],
        ).createShader(moonRect),
    );

    // Cratères, teintés de brun chaud plutôt que de noir
    final crater = Paint()..color = const Color(0xFF8A5A1E).withValues(alpha: 0.14);
    canvas.drawCircle(c + Offset(-rad * .35, -rad * .25), rad * .18, crater);
    canvas.drawCircle(c + Offset(rad * .30, rad * .10), rad * .24, crater);
    canvas.drawCircle(c + Offset(-rad * .10, rad * .45), rad * .12, crater);
  }

  @override
  bool shouldRepaint(_MoonPainter old) => old.t != t;
}

// ───────────── Brume qui dérive ─────────────
class _FogPainter extends CustomPainter {
  _FogPainter(this.t, this.y, this.speed, this.opacity);
  final double t, y, opacity;
  final int speed; // entier => boucle sans saut

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    for (var i = 0; i < 4; i++) {
      final u = (t * speed + i / 4) % 1.0;
      final x = (u * 2 - 0.5) * size.width;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, size.height * y + (i.isEven ? 12 : -12)),
          width: size.width * 0.7,
          height: 70,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FogPainter old) => old.t != t;
}

// ───────────── Crêtes, sapins et rocher ─────────────
class _RidgePainter extends CustomPainter {
  _RidgePainter({
    required this.color,
    required this.base,
    required this.amp,
    required this.seed,
    this.trees = false,
    this.bumpAt = 0.5,
    this.bumpH = 0,
    this.bumpW = 0.2,
  });

  final Color color;
  final double base, amp, bumpAt, bumpH, bumpW;
  final int seed;
  final bool trees;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final p1 = r.nextDouble() * 6, p2 = r.nextDouble() * 6;

    double yAt(double x) {
      final u = x / size.width;
      final wave = amp * (0.6 * math.sin(u * 3 + p1) + 0.4 * math.sin(u * 7 + p2));
      final d = (u - bumpAt) / bumpW;
      final bump = bumpH * math.exp(-d * d);
      return size.height * base - wave - bump;
    }

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, yAt(0));
    for (double x = 0; x <= size.width; x += 4) {
      path.lineTo(x, yAt(x));
    }
    path
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    if (trees) {
      for (double x = 0; x < size.width; x += 10 + r.nextDouble() * 14) {
        final h = 22 + r.nextDouble() * 34;
        final w = h * 0.38;
        final y = yAt(x) + 4;
        canvas.drawPath(
          Path()
            ..moveTo(x, y - h)
            ..lineTo(x - w, y)
            ..lineTo(x + w, y)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RidgePainter old) => false;
}