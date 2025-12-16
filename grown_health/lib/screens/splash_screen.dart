import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../widgets/widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      final isProfileComplete = authState.user?.isProfileComplete ?? false;
      if (isProfileComplete) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/profile_setup');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splashBackgroundColor,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SizedBox.expand(
            child: SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon/Logo background
                        Container(
                          width: 136,
                          height: 136,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(27),
                            // Optional: subtle shadow if needed, design looks clean
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                24,
                              ), // Adjusted padding for logo inside
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.favorite,
                                    size: 60,
                                    color: AppTheme.primaryColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // App Name
                        Text(
                          'Grown Health', // Hardcoded as per design or use AppConstants.appName if it matches
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.w600, // SemiBold
                              color: AppTheme.white,
                              height:
                                  1.0, // Tight line height usually helps match design
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          'Your Health Journey Starts Here',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400, // Regular
                              color: AppTheme.white,
                              height: 1.2,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Move loading indicator to bottom or hide if not in design?
                        // The design doesn't show a loader. I'll keep it subtle or remove it if strictly matching static design.
                        // User said "design my splash screen based on this design".
                        // Usually splash screens might have a loader. I'll add a spacer and put it at the bottom, or just keep it below with more space.
                        // The design is static. I'll add a bit of space and keep the loader small, as it's functional feedback.
                        const SizedBox(height: 48),
                        const LoadingWidget(
                          size: 32,
                          strokeWidth: 3,
                          color: AppTheme.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
