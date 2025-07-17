import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingParticlesBackground extends StatefulWidget {
  final Widget child;
  final Color? particleColor;
  final int particleCount;
  final bool enabled;

  const FloatingParticlesBackground({
    super.key,
    required this.child,
    this.particleColor,
    this.particleCount = 20,
    this.enabled = true,
  });

  @override
  State<FloatingParticlesBackground> createState() => _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState extends State<FloatingParticlesBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _colorController;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _initializeParticles();
  }

  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 1,
        speed: _random.nextDouble() * 0.3 + 0.05,
        opacity: _random.nextDouble() * 0.4 + 0.1,
        direction: _random.nextDouble() * 2 * pi,
        hue: _random.nextDouble() * 360,
        phase: _random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        // Particules en arrière-plan
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(
                  particles: _particles,
                  animationValue: _controller.value,
                  colorAnimationValue: _colorController.value,
                  primaryColor: widget.particleColor ?? Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),
        // Contenu principal
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double direction;
  final double hue;
  final double phase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.direction,
    required this.hue,
    required this.phase,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final double colorAnimationValue;
  final Color primaryColor;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
    required this.colorAnimationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Mouvement en spirale avec oscillation
      final spiralRadius = 50 + sin(animationValue * 2 * pi + particle.phase) * 20;
      final spiralAngle = animationValue * 2 * pi * particle.speed + particle.phase;
      
      final baseX = particle.x * size.width;
      final baseY = particle.y * size.height;
      
      final x = baseX + cos(spiralAngle) * spiralRadius * 0.1;
      final y = baseY + sin(spiralAngle) * spiralRadius * 0.1 + 
                (animationValue * particle.speed * size.height * 0.1) % size.height;
      
      // Couleur dynamique basée sur la position et l'animation
      final hue = (particle.hue + colorAnimationValue * 60) % 360;
      final color = HSVColor.fromAHSV(
        particle.opacity * 0.6,
        hue,
        0.7,
        0.9,
      ).toColor();
      
      // Effet de glow
      final glowPaint = Paint()
        ..color = color.withOpacity(particle.opacity * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Taille dynamique avec pulsation
      final dynamicSize = particle.size * (1 + sin(animationValue * 4 * pi + particle.phase) * 0.3);
      
      // Dessiner l'effet de glow
      canvas.drawCircle(
        Offset(x, y),
        dynamicSize * 2,
        glowPaint,
      );
      
      // Dessiner la particule
      canvas.drawCircle(
        Offset(x, y),
        dynamicSize,
        paint,
      );
      
      // Ajouter un point central brillant
      final centerPaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        dynamicSize * 0.3,
        centerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}