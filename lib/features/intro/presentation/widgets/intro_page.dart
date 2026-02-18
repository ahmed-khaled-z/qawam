import 'package:flutter/material.dart';

import '../../../../config/language/language_manager.dart';
import 'intro_illustration.dart';

class IntroPage extends StatelessWidget {
  final int index;
  final double pageOffset;
  final Animation<double> entranceAnimation;
  final Animation<double> loopAnimation;

  const IntroPage({
    super.key,
    required this.index,
    required this.pageOffset,
    required this.entranceAnimation,
    required this.loopAnimation,
  });

  static const _titleKeys = [
    'intro_slide1_title',
    'intro_slide2_title',
    'intro_slide3_title',
  ];

  static const _descKeys = [
    'intro_slide1_desc',
    'intro_slide2_desc',
    'intro_slide3_desc',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final parallax = (pageOffset - index) * size.width * 0.3;

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, child) {
        final titleCurve = CurvedAnimation(
          parent: entranceAnimation,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
        );
        final descCurve = CurvedAnimation(
          parent: entranceAnimation,
          curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              IntroIllustration(
                index: index,
                entranceAnimation: entranceAnimation,
                loopAnimation: loopAnimation,
                parallaxOffset: parallax,
              ),
              const SizedBox(height: 48),
              Transform.translate(
                offset: Offset(0, 20 * (1 - titleCurve.value)),
                child: Opacity(
                  opacity: titleCurve.value.clamp(0.0, 1.0),
                  child: Text(
                    context.tr(_titleKeys[index]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Transform.translate(
                offset: Offset(0, 20 * (1 - descCurve.value)),
                child: Opacity(
                  opacity: descCurve.value.clamp(0.0, 1.0),
                  child: Text(
                    context.tr(_descKeys[index]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}
