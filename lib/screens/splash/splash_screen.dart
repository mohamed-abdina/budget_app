import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _textController;
  late final AnimationController _taglineController;
  late final AnimationController _progressController;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    // Icon: scale up + fade in
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // App name: slide up + fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Tagline: fade in
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    // Progress indicator: fade in
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    debugPrint('SPLASH: Starting animation');
    await Future.delayed(const Duration(milliseconds: 500));
    _iconController.forward();
    debugPrint('SPLASH: Icon animation started');

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    debugPrint('SPLASH: Text animation started');

    await Future.delayed(const Duration(milliseconds: 500));
    _taglineController.forward();
    debugPrint('SPLASH: Tagline animation started');

    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    debugPrint('SPLASH: Progress animation started');

    await Future.delayed(const Duration(milliseconds: 2000));
    debugPrint('SPLASH: Navigating away');
    widget.onComplete();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2A1F0A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFFBF2E2), const Color(0xFFF5F5F5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Animated icon
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Opacity(
                  opacity: _iconFade.value,
                  child: Transform.scale(
                    scale: _iconScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8862F),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB8862F).withOpacity(0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.castle_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Animated app name
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Text(
                  'Ledgerline',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Animated tagline
            FadeTransition(
              opacity: _taglineFade,
              child: Text(
                'Smart Budget Management',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey[600],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Animated progress indicator
            FadeTransition(
              opacity: _progressFade,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFB8862F),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
