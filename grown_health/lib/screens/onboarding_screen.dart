import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.health_and_safety_rounded,
      title: 'Track Your Health',
      subtitle:
          'Monitor your daily activities, workouts, and health metrics in one place.',
      color: AppTheme.successColor,
    ),
    OnboardingPageData(
      icon: Icons.track_changes_rounded,
      title: 'Set Goals',
      subtitle:
          'Create personalized health and fitness goals to stay motivated.',
      color: AppTheme.infoColor,
    ),
    OnboardingPageData(
      icon: Icons.emoji_events_rounded,
      title: 'Stay Motivated',
      subtitle:
          'Get insights and recommendations to maintain a healthy lifestyle.',
      color: AppTheme.warningColor,
    ),
  ];

  void _goToLogin() {
    SnackBarUtils.showSuccess(context, 'Welcome to Grown Health!');
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _skipOnboarding() {
    _goToLogin();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Page indicator dots
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: _currentPage == _pages.length - 1
                    ? AppConstants.paddingLarge
                    : 0,
              ),
              child: CustomButton(
                onPressed: _nextPage,
                isFullWidth: true,
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                backgroundColor: AppTheme.white,
                textColor: AppTheme.accentColor,
                height: 48,
              ),
            ),

            // Skip button (hidden on last page)
            if (_currentPage != _pages.length - 1)
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: CustomButton(
                  onPressed: _skipOnboarding,
                  isFullWidth: true,
                  text: 'Skip',
                  type: ButtonType.outline,
                  backgroundColor: AppTheme.white,
                  textColor: AppTheme.white,
                  height: 48,
                ),
              )
            else
              const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Icon with colored background circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 50, color: page.color),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),

          // Title
          Text(
            page.title,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              page.subtitle,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontSize: 16,
                  color: AppTheme.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: isActive ? 1 : 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Data class for onboarding pages
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
