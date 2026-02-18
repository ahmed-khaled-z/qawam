import 'dart:math';

import 'package:flutter/material.dart';

class IntroIllustration extends StatelessWidget {
  final int index;
  final Animation<double> entranceAnimation;
  final Animation<double> loopAnimation;
  final double parallaxOffset;

  const IntroIllustration({
    super.key,
    required this.index,
    required this.entranceAnimation,
    required this.loopAnimation,
    this.parallaxOffset = 0,
  });

  static const _slideColors = [
    [Color(0xFF7C3AED), Color(0xFF9F67FF)], // Purple
    [Color(0xFF059669), Color(0xFF34D399)], // Green
    [Color(0xFF2563EB), Color(0xFF60A5FA)], // Blue
  ];

  static const _slideIcons = [
    Icons.account_balance_wallet_rounded,
    Icons.cloud_off_rounded,
    Icons.shield_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _slideColors[index];

    return AnimatedBuilder(
      animation: Listenable.merge([entranceAnimation, loopAnimation]),
      builder: (context, child) {
        final entrance = CurvedAnimation(
          parent: entranceAnimation,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
        ).value;

        final loop = loopAnimation.value;

        return Transform.translate(
          offset: Offset(parallaxOffset, 0),
          child: Transform.scale(
            scale: 0.3 + (entrance * 0.7),
            child: Opacity(
              opacity: entrance.clamp(0.0, 1.0),
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildOuterGlow(colors, loop),
                    _buildOrbitingElements(colors, loop, index),
                    _buildMainCircle(colors),
                    _buildIcon(index),
                    if (index == 2) _buildSecurityBadge(loop),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOuterGlow(List<Color> colors, double loop) {
    final pulse = 0.95 + sin(loop * 2 * pi) * 0.05;
    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colors[0].withValues(alpha: 0.15),
              colors[1].withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCircle(List<Color> colors) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(int index) {
    return Icon(
      _slideIcons[index],
      size: 64,
      color: Colors.white.withValues(alpha: 0.95),
    );
  }

  Widget _buildOrbitingElements(List<Color> colors, double loop, int index) {
    switch (index) {
      case 0:
        return _buildFloatingCoins(colors, loop);
      case 1:
        return _buildSignalWaves(colors, loop);
      case 2:
        return _buildRotatingDots(colors, loop);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingCoins(List<Color> colors, double loop) {
    const count = 4;
    const radius = 120.0;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(count, (i) {
          final baseAngle = (i / count) * 2 * pi;
          final floatY = sin(loop * 2 * pi + i * 1.2) * 8;
          final x = cos(baseAngle) * radius;
          final y = sin(baseAngle) * radius + floatY;
          final coinSize = 32.0 + (i % 2) * 8;

          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: coinSize,
              height: coinSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[1].withValues(alpha: 0.7),
                    colors[0].withValues(alpha: 0.5),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: coinSize * 0.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSignalWaves(List<Color> colors, double loop) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (i) {
          final delay = i * 0.33;
          final progress = ((loop + delay) % 1.0);
          final scale = 1.0 + progress * 0.6;
          final opacity = (1.0 - progress).clamp(0.0, 0.4);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors[1].withValues(alpha: opacity),
                  width: 2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRotatingDots(List<Color> colors, double loop) {
    const dotCount = 8;
    const radius = 110.0;
    final rotation = loop * 2 * pi;

    return SizedBox(
      width: 280,
      height: 280,
      child: Transform.rotate(
        angle: rotation,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(dotCount, (i) {
            final angle = (i / dotCount) * 2 * pi;
            final x = cos(angle) * radius;
            final y = sin(angle) * radius;
            final dotSize = 6.0 + (i % 3) * 2;

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[1].withValues(alpha: 0.5 + (i % 2) * 0.3),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(double loop) {
    final pulse = 0.9 + sin(loop * 2 * pi * 2) * 0.1;
    return Positioned(
      right: 55,
      top: 55,
      child: Transform.scale(
        scale: pulse,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF22C55E),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
