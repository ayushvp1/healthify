import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardPageData(
      icon: Icons.health_and_safety_rounded,
      title: 'Track Your Health',
      subtitle:
          'Monitor your daily activities, workouts, and health metrics in one place.',
    ),
    _OnboardPageData(
      icon: Icons.track_changes_rounded,
      title: 'Set Goals',
      subtitle:
          'Create personalized health and fitness goals to stay motivated.',
    ),
    _OnboardPageData(
      icon: Icons.emoji_events_rounded,
      title: 'Stay Motivated',
      subtitle:
          'Get insights and recommendations to maintain a healthy lifestyle.',
    ),
  ];

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAA3D50),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return _OnboardPage(data: data);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isActive ? 1 : 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (_currentPage < _pages.length - 1) ...[
                    // Next button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFAA3D50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Skip button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _goToLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Last page: Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFAA3D50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardPageData data;

  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Icon circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 40, color: const Color(0xFFAA3D50)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
