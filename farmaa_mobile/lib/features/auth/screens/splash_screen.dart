import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Animated splash screen — checks auth session and routes accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // ── DATA WARMUP ──
    // Start authenticating and finding backend early (while animation plays)
    unawaited(ref.read(authProvider.notifier).refreshProfile());

    // Navigate smoothly using the reactive router pattern
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    // Safety check for state resolve; GoRouter redirect uses this flag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(splashFinishedProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: _decorativeCircle(240, Colors.white.withValues(alpha: 0.05)),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _decorativeCircle(200, Colors.white.withValues(alpha: 0.05)),
            ),
            Positioned(
              top: 200,
              left: -40,
              child: _decorativeCircle(120, Colors.white.withValues(alpha: 0.04)),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppTheme.radiusXLarge,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text('🌾', style: TextStyle(fontSize: 52)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'FARMAA',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  AnimatedBuilder(
                    animation: _taglineOpacity,
                    builder: (_, __) => Opacity(
                      opacity: _taglineOpacity.value,
                      child: const Text(
                        'From Farm to Future',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

            // Version at very bottom
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(fontSize: 11, color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
