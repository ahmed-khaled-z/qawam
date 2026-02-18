import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';
import '../../../../config/router/app_router.dart';
import '../../../login/presentation/screens/login_screen.dart';
import '../cubit/spalsh_cubit.dart';
import '../cubit/spalsh_state.dart';

class SpalshScreen extends StatefulWidget {
  static const routeName = "/";
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen>
    with SingleTickerProviderStateMixin {
  late final SpalshCubit _cubit;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _cubit = SpalshCubit();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _animationController.forward();
    _cubit.checkAuthStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SpalshCubit, SpalshState>(
        listener: (context, state) {
          if (state.status == SpalshStatus.authenticated) {
            AppRouter.toAndRemoveUntil('/home');
          } else if (state.status == SpalshStatus.unauthenticated) {
            AppRouter.toAndRemoveUntil(LoginScreen.routeName);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildBackground(),
              _buildDecorativeElements(context),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildContent(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        Positioned(
          top: -size.width * 0.2,
          right: -size.width * 0.1,
          child: Container(
            width: size.width * 0.5,
            height: size.width * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.15,
          left: -size.width * 0.1,
          child: Transform.rotate(
            angle: pi / 6,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo
        Container(
          width: size.width * 0.32,
          height: size.width * 0.32,
          constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 28),

        // App Name — use translated app name
        Text(
          context.tr('app_name'),
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Tagline — translated
        Text(
          context.tr('splash_tagline'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
