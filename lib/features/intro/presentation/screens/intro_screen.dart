import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';
import '../../../../config/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../../login/presentation/screens/login_screen.dart';
import '../cubit/intro_cubit.dart';
import '../cubit/intro_state.dart';
import '../widgets/animated_dots_indicator.dart';
import '../widgets/intro_page.dart';
import '../widgets/language_switch_button.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = "/intro";
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final IntroCubit _cubit;
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final AnimationController _loopController;
  late final AnimationController _buttonController;
  double _pageOffset = 0;

  static const _gradients = [
    [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF7C3AED)], // Purple
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)], // Green
    [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)], // Blue
  ];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<IntroCubit>();

    _pageController = PageController()..addListener(_onPageScroll);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onPageScroll() {
    if (!mounted) return;
    setState(() {
      _pageOffset = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _loopController.dispose();
    _buttonController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onPageChanged(int page) {
    _cubit.onPageChanged(page);
    _entranceController.reset();
    _entranceController.forward();

    if (page == 2) {
      _buttonController.forward();
    } else {
      _buttonController.reverse();
    }
  }

  void _nextPage() {
    if (_cubit.state.isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _skip() => _completeOnboarding();

  void _completeOnboarding() {
    _cubit.completeOnboarding();
  }

  List<Color> _interpolatedGradient() {
    final page = _pageOffset.clamp(0.0, 2.0);
    final fromIndex = page.floor().clamp(0, 1);
    final toIndex = (fromIndex + 1).clamp(0, 2);
    final t = page - fromIndex;

    return List.generate(3, (i) {
      return Color.lerp(_gradients[fromIndex][i], _gradients[toIndex][i], t)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<IntroCubit, IntroState>(
        listener: (context, state) {
          if (state.isCompleted) {
            AppRouter.toAndRemoveUntil(LoginScreen.routeName);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              _buildDecorativeShapes(context),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return IntroPage(
                            index: index,
                            pageOffset: _pageOffset,
                            entranceAnimation: _entranceController,
                            loopAnimation: _loopController,
                          );
                        },
                      ),
                    ),
                    BlocBuilder<IntroCubit, IntroState>(
                      builder: (context, state) {
                        return _buildBottomSection(state);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final colors = _interpolatedGradient();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scroll = _pageOffset * 30;

    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.25 + scroll,
          right: -size.width * 0.15,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.2 - scroll,
          left: -size.width * 0.15,
          child: Transform.rotate(
            angle: pi / 6 + _pageOffset * 0.1,
            child: Container(
              width: size.width * 0.45,
              height: size.width * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.35,
          left: -30 + scroll * 0.5,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<IntroCubit, IntroState>(
            builder: (context, state) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: state.isLastPage ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: state.isLastPage,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      context.tr('intro_skip'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const LanguageSwitchButton(),
        ],
      ),
    );
  }

  Widget _buildBottomSection(IntroState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDotsIndicator(currentPage: state.currentPage),
          const SizedBox(height: 32),
          _buildActionButton(state),
        ],
      ),
    );
  }

  Widget _buildActionButton(IntroState state) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        final expand = CurvedAnimation(
          parent: _buttonController,
          curve: Curves.easeOutCubic,
        ).value;

        final width = lerpDouble(180, 240, expand)!;
        final height = lerpDouble(52, 56, expand)!;

        return GestureDetector(
          onTap: _nextPage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Text(
                  state.isLastPage
                      ? context.tr('intro_get_started')
                      : context.tr('intro_next'),
                  key: ValueKey(state.isLastPage),
                  style: TextStyle(
                    fontSize: state.isLastPage ? 17 : 16,
                    fontWeight: FontWeight.w700,
                    color: _interpolatedGradient()[1],
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
