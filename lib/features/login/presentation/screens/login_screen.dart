import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_helper/app_gaps.dart';
import '../../../../config/app_helper/app_padding.dart';
import '../../../../config/language/language_manager.dart';
import '../../../../config/router/app_router.dart';
import '../../../../features/device_authorization/presentation/screens/device_authorization_waiting_screen.dart';
import '../../../../injection_container.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            AppRouter.toAndRemoveUntil('/home');
          }
          if (state.status == LoginStatus.needsDeviceAuthorization &&
              state.user != null) {
            AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              DeviceAuthorizationWaitingScreen.routeName,
              (route) => false,
              arguments: {'userId': state.user!.uid},
            );
          }
          if (state.status == LoginStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? context.tr('error_occurred'),
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(AppPadding.defaultPadding),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                // Background gradient
                _buildBackground(),

                // Decorative elements
                _buildDecorativeElements(context),

                // Arabic geometric pattern overlay
                _buildGeometricPattern(context),

                // Main content
                SafeArea(
                  child: Stack(
                    children: [
                      // Language switcher in top corner
                      _buildLanguageSwitcher(context),

                      // Center content
                      _buildContent(context, state),
                    ],
                  ),
                ),

                // Loading overlay
                if (state.status == LoginStatus.loading)
                  _buildLoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D7377),
            Color(0xFF14919B),
            Color(0xFF1DA8A8),
            Color(0xFF0D7377),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildDecorativeElements(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Large top-right circle
        Positioned(
          top: -size.width * 0.25,
          right: -size.width * 0.15,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Small top-left circle
        Positioned(
          top: size.height * 0.12,
          left: -size.width * 0.1,
          child: Container(
            width: size.width * 0.3,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Bottom-left geometric shape
        Positioned(
          bottom: size.height * 0.08,
          left: -30,
          child: Transform.rotate(
            angle: pi / 6,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
        // Bottom-right diamond
        Positioned(
          bottom: size.height * 0.25,
          right: -20,
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
        // Subtle pattern dots
        ..._buildPatternDots(size),
      ],
    );
  }

  /// Subtle Arabic-inspired geometric pattern overlay
  Widget _buildGeometricPattern(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: CustomPaint(
        painter: _ArabicPatternPainter(size: size),
      ),
    );
  }

  List<Widget> _buildPatternDots(Size size) {
    final dots = <Widget>[];
    final random = Random(42);
    for (int i = 0; i < 12; i++) {
      dots.add(
        Positioned(
          top: random.nextDouble() * size.height,
          left: random.nextDouble() * size.width,
          child: Container(
            width: 4 + random.nextDouble() * 4,
            height: 4 + random.nextDouble() * 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.06 + random.nextDouble() * 0.04,
              ),
            ),
          ),
        ),
      );
    }
    return dots;
  }

  /// Language switcher pill — top-end corner
  Widget _buildLanguageSwitcher(BuildContext context) {
    final isArabic = languageManager.isArabic;
    return Positioned(
      top: 12,
      right: languageManager.isArabic ? null : 16,
      left: languageManager.isArabic ? 16 : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Material(
          key: ValueKey(isArabic),
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              languageManager.toggleLanguage();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LoginState state) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.defaultPadding * 1.5,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                _buildLogo(size),

                AppGaps.bigGap,

                // Headline
                _buildHeadline(context),

                AppGaps.smallGap,

                // Subtext
                _buildSubtext(context),

                SizedBox(height: size.height * 0.08),

                // Google Sign-In Button
                _buildGoogleButton(context, state),

                AppGaps.defaultGap,

                // Terms text
                _buildTermsText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Container(
      width: size.width * 0.3,
      height: size.width * 0.3,
      constraints: const BoxConstraints(maxWidth: 140, maxHeight: 140),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppPadding.defaultPadding),
      child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Text(
      context.tr('login_headline'),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.3,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtext(BuildContext context) {
    return Text(
      context.tr('login_subtext'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.8),
        height: 1.5,
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context, LoginState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.status == LoginStatus.loading
            ? null
            : () => context.read<LoginCubit>().signInWithGoogle(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF333333),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('continue_with_google'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.defaultPadding,
      ),
      child: Text(
        context.tr('terms_text'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.55),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Subtle Arabic-inspired geometric pattern overlay
class _ArabicPatternPainter extends CustomPainter {
  final Size size;
  _ArabicPatternPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 60.0;
    final cols = (canvasSize.width / spacing).ceil() + 1;
    final rows = (canvasSize.height / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * spacing + (r.isOdd ? spacing / 2 : 0);
        final cy = r * spacing;
        final center = Offset(cx, cy);

        // 8-pointed star pattern
        _drawStar(canvas, center, 8, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 2;
      final outerX = center.dx + cos(angle) * radius;
      final outerY = center.dy + sin(angle) * radius;
      final innerAngle = angle + pi / 8;
      final innerX = center.dx + cos(innerAngle) * (radius * 0.4);
      final innerY = center.dy + sin(innerAngle) * (radius * 0.4);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the Google "G" logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -0.5, 1.2, true, bluePaint);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.7, 1.2, true, redPaint);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        1.9, 1.2, true, yellowPaint);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.7, 1.2, true, greenPaint);

    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white);

    canvas.drawRect(
        Rect.fromLTWH(w * 0.48, h * 0.35, w * 0.52, h * 0.3), bluePaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.48, h * 0.35, w * 0.52, h * 0.12),
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
