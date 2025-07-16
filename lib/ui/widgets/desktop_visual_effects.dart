import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

/// Widget pour les effets visuels avancés sur desktop
class DesktopVisualEffects extends StatefulWidget {
  final Widget child;
  final bool enableEffects;
  final Color? primaryColor;

  const DesktopVisualEffects({
    Key? key,
    required this.child,
    this.enableEffects = true,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<DesktopVisualEffects> createState() => _DesktopVisualEffectsState();
}

class _DesktopVisualEffectsState extends State<DesktopVisualEffects>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late AnimationController _particleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _colorAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation pour les changements de couleur
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animation de transition de couleur
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOutCubic,
    ));

    // Animation de particules flottantes
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);
  }

  @override
  void didUpdateWidget(DesktopVisualEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.primaryColor != oldWidget.primaryColor && widget.enableEffects) {
      _triggerColorChangeEffect();
    }
  }

  void _triggerColorChangeEffect() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    _colorController.forward().then((_) {
      _colorController.reset();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _colorController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableEffects || !GetPlatform.isDesktop) {
      return widget.child;
    }

    return Stack(
      children: [
        // Effet de fond avec particules
        AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlesPainter(
                animation: _particleAnimation,
                primaryColor: widget.primaryColor ?? Theme.of(context).primaryColor,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Effet de pulsation lors des changements de couleur
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5 * _pulseAnimation.value,
                  colors: [
                    (widget.primaryColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1 * (1 - _pulseAnimation.value)),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Contenu principal avec effet de transition
        AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (0.02 * _colorAnimation.value * (1 - _colorAnimation.value) * 4),
              child: widget.child,
            );
          },
        ),
      ],
    );
  }
}

/// Painter pour les particules flottantes
class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final List<Particle> particles = [];

  ParticlesPainter({
    required this.animation,
    required this.primaryColor,
  }) : super(repaint: animation) {
    // Générer des particules si la liste est vide
    if (particles.isEmpty) {
      for (int i = 0; i < 15; i++) {
        particles.add(Particle(
          x: math.Random().nextDouble(),
          y: math.Random().nextDouble(),
          size: math.Random().nextDouble() * 3 + 1,
          speed: math.Random().nextDouble() * 0.5 + 0.1,
          opacity: math.Random().nextDouble() * 0.3 + 0.1,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = (particle.y + animation.value * particle.speed) % 1.0 * size.height;
      
      paint.color = primaryColor.withOpacity(particle.opacity * 
          (0.5 + 0.5 * math.sin(animation.value * 2 * math.pi + particle.x * 10)));
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Classe pour représenter une particule
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Widget pour les effets de transition de couleur
class ColorTransitionEffect extends StatefulWidget {
  final Widget child;
  final Color? fromColor;
  final Color? toColor;
  final Duration duration;

  const ColorTransitionEffect({
    Key? key,
    required this.child,
    this.fromColor,
    this.toColor,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<ColorTransitionEffect> createState() => _ColorTransitionEffectState();
}

class _ColorTransitionEffectState extends State<ColorTransitionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _updateColorAnimation();
    _controller.forward();
  }

  void _updateColorAnimation() {
    _colorAnimation = ColorTween(
      begin: widget.fromColor,
      end: widget.toColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(ColorTransitionEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toColor != oldWidget.toColor) {
      _updateColorAnimation();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (_colorAnimation.value ?? Colors.transparent).withOpacity(0.05),
                Colors.transparent,
                (_colorAnimation.value ?? Colors.transparent).withOpacity(0.02),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget pour les effets de glow/lueur
class GlowEffect extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final double glowOpacity;

  const GlowEffect({
    Key? key,
    required this.child,
    this.glowColor,
    this.glowRadius = 10.0,
    this.glowOpacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!GetPlatform.isDesktop) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? Theme.of(context).primaryColor).withOpacity(glowOpacity),
            blurRadius: glowRadius,
            spreadRadius: glowRadius / 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
