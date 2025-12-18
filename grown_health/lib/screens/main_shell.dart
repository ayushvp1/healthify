import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home/home_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'mind/mind_screen.dart';
import 'help/help_screen.dart';
import 'workout/workouts_screen.dart';

class MainShell extends StatefulWidget {
  static final GlobalKey homeKey = GlobalKey();
  static final GlobalKey workoutsKey = GlobalKey();
  static final GlobalKey nutritionKey = GlobalKey();
  static final GlobalKey profileKey =
      GlobalKey(); // Using 'Help' as profile for now as per UI
  static final GlobalKey mindKey = GlobalKey();

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(), // index 0: Home
    WorkoutsScreen(), // index 1: Body (Workouts page)
    NutritionScreen(), // index 2: Nutrition
    HelpScreen(), // index 3: Help
    MindScreen(), // index 4: Mind
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      extendBody: true, // Allows body to scroll behind the nav bar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _SharedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _SharedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SharedBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFA03E4E), // Deep dusty red/maroon
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomNavItem(
                key: MainShell.homeKey,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
                icon: Icons.home_filled,
                selectedIcon: Icons.home_filled,
              ),
              _BottomNavItem(
                key: MainShell.workoutsKey,
                label: 'Body',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
                icon: Icons.accessibility_new_rounded,
                selectedIcon: Icons.accessibility_new_rounded,
              ),
              _BottomNavItem(
                key: MainShell.nutritionKey,
                label: 'Nutrition',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
                icon: Icons.rice_bowl_outlined,
                selectedIcon: Icons.rice_bowl,
              ),
              _BottomNavItem(
                key: MainShell.profileKey,
                label: 'Help',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
                icon: Icons.account_circle_outlined,
                selectedIcon: Icons.account_circle,
              ),
              _BottomNavItem(
                key: MainShell.mindKey,
                label: 'Mind',
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
                icon: Icons.sentiment_satisfied_rounded,
                selectedIcon: Icons.sentiment_satisfied_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData icon;
  final IconData selectedIcon;

  const _BottomNavItem({
    super.key,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.icon,
    required this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;

    // Selected State: White Stadium/Capsule with Icon + Name
    if (isSelected) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedIcon,
                size: 20,
                color: const Color(0xFFA03E4E), // Match nav background
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA03E4E),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Unselected State: Icon only
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(icon, size: 26, color: AppTheme.white.withOpacity(0.6)),
      ),
    );
  }
}
