import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../shared/providers/session_provider.dart';

/// Simple institutional splash: plain Primary Blue background, clear white
/// text, shield emblem, and a minimal processing indicator.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;

  bool _navigated = false;
  bool _showFailsafe = false;
  bool _logoPrecached = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entrance,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _entrance,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _entrance,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entrance,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _entrance.forward();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _resolveNextRoute());
  }

  Future<void> _resolveNextRoute() async {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && !_navigated) setState(() => _showFailsafe = true);
    });

    bool restored = false;
    try {
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 4)),
        ref
            .read(sessionProvider.notifier)
            .restoreSession()
            .timeout(const Duration(seconds: 8), onTimeout: () {
          debugPrint('SPLASH: session restore timed out, continuing');
          return false;
        }),
      ]).timeout(const Duration(seconds: 12), onTimeout: () {
        debugPrint('SPLASH: overall resolve timed out, continuing');
        return [true, false];
      });
      restored = results[1] as bool;
    } catch (e) {
      debugPrint('SPLASH resolve failed (continuing anyway): $e');
      restored = false;
    }
    if (!mounted || _navigated) return;
    _navigated = true;
    debugPrint('SPLASH: navigating (restored=$restored)');
    context.go(restored ? AppRoutes.pointOfEntry : AppRoutes.login);
  }

  void _manualContinue() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final loggedIn = ref.read(sessionProvider).isLoggedIn;
    context.go(loggedIn ? AppRoutes.pointOfEntry : AppRoutes.login);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache so the emblem is visible on the first frame, not popping in.
    if (!_logoPrecached) {
      _logoPrecached = true;
      precacheImage(
        const AssetImage(
            'assets/images/coat-of-arms-of-tanzania-seeklogo.png'),
        context,
      );
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Ministry header row.
              Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ministry of Health • Tanzania',
                          style: text.labelMedium?.copyWith(
                            color: Colors.white
                                .withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Wizara ya Afya',
                          style: text.labelSmall?.copyWith(
                            color: Colors.white
                                .withValues(alpha: 0.65),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Main logo: Tanzania coat of arms in a white circular badge.
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/images/coat-of-arms-of-tanzania-seeklogo.png',
                          fit: BoxFit.contain,
                          semanticLabel:
                              'Coat of arms of Tanzania',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Clear bilingual title.
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    children: [
                      Text(
                        'AfyaMsafiri',
                        textAlign: TextAlign.center,
                        style: text.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Point of Entry Health Screening',
                        textAlign: TextAlign.center,
                        style: text.titleMedium?.copyWith(
                          color: Colors.white
                              .withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _FlagStrip(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Simple processing indicator (no card/tab container).
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Processing…',
                style: text.bodyMedium?.copyWith(
                  color:
                      Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (_showFailsafe && !_navigated)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _manualContinue,
                      icon:
                          const Icon(Icons.arrow_forward_outlined),
                      label:
                          const Text('Endelea • Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                'v1.0.0 ',
                style: text.labelSmall?.copyWith(
                  color:
                      Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green / yellow / black / blue Tanzanian flag accent.
class _FlagStrip extends StatelessWidget {
  const _FlagStrip();

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF1EB53A), // green
      Color(0xFFFCD116), // yellow
      Color(0xFF000000), // black
      Color(0xFF00A3DD), // blue
    ];
    return Center(
      child: SizedBox(
        width: 120,
        height: 5,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(AppRadius.full),
          child: Row(
            children: colors
                .map((c) => Expanded(
                      child: Container(color: c),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _PoeBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PoeBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: Colors.white.withValues(alpha: 0.75),
              size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
          ),
        ],
      ),
    );
  }
}
