import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home/home_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'mind/mind_screen.dart';
import 'help/help_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    NutritionScreen(),
    HelpScreen(),
    MindScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFAA3D50),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left white pill for Body/Home
            GestureDetector(
              onTap: () => onTap(0),
              child: Container(
                width: 64,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.home_rounded, color: Color(0xFFAA3D50)),
                ),
              ),
            ),
            _BottomNavLabelShared(
              label: 'Body',
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _BottomNavLabelShared(
              label: 'Nutrition',
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _BottomNavLabelShared(
              label: 'Help',
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _BottomNavLabelShared(
              label: 'Mind',
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavLabelShared extends StatelessWidget {
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavLabelShared({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFFF6C5CF);

    IconData icon;
    switch (label) {
      case 'Body':
        icon = Icons.person_outline_rounded;
        break;
      case 'Nutrition':
        icon = Icons.rice_bowl_outlined;
        break;
      case 'Help':
        icon = Icons.account_circle_outlined;
        break;
      case 'Mind':
        icon = Icons.emoji_emotions_outlined;
        break;
      default:
        icon = Icons.circle_outlined;
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(fontSize: 11, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
