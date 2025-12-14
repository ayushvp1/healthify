import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/providers.dart';
import 'widgets/widgets.dart';
import '../../services/water_service.dart';
import '../../services/water_reminder_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _displayName = 'User';
  String _greeting = 'Good Morning!';

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadUserName();
    _startWaterReminders();
  }

  void _startWaterReminders() {
    // Start water reminders after a short delay to ensure context is ready
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final token = ref.read(authProvider).user?.token;
      if (token != null) {
        final waterService = WaterService(token);
        WaterReminderManager.start(waterService, context);
      }
    });
  }

  @override
  void dispose() {
    WaterReminderManager.stop();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() => _displayName = savedName);
    } else {
      // Fallback to email prefix
      final authState = ref.read(authProvider);
      final userEmail = authState.user?.email ?? 'User';
      setState(() => _displayName = userEmail.split('@').first);
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning!';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon!';
    } else {
      _greeting = 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName;
    final greeting = _greeting;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(greeting, displayName),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildMedicineReminder()),
                        const SizedBox(width: 12),
                        const Expanded(flex: 2, child: WaterTrackingWidget()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTodaysPlan(context),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecommendedSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String greeting, String displayName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayName,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new notifications'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F6), // Even lighter pink
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5BCC5), // Thinner, softer border
                      width: 1.5,
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8), // Very light pinkish-white
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF5B0C23,
            ).withOpacity(0.08), // Subtle burgundy shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        style: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search Workouts',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade700, // Darker text as requested
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ), // Slightly more padding for the icon container
            child: Container(
              width: 44, // Slightly larger touch target
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF5B0C23), // Dark Burgundy
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 24),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMedicineReminder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medicine Reminder',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/medicine_reminders');
              },
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B0C23), // Dark Burgundy
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'No medicine reminders set',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/medicine_reminders');
              },
              child: Text(
                'Add',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B0C23), // Dark Burgundy
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaysPlan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Plan",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'See all',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5B0C23), // Dark Burgundy
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TodaysPlanCard(
          title: 'Russian Twist',
          description: 'Our intense ab set based on the ground.',
          calories: '350 Kcal',
          duration: '10 min',
          imagePath: 'assets/todays_plan.jpg',
          onTap: () => Navigator.of(context).pushNamed('/workout_detail'),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended for You',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Personalized workout suggestions',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        const RecommendedCard(
          backgroundColor: Color(0xFFAA3D50),
          accentColor: Color(0xFFD46A7A),
        ),
        const SizedBox(height: 16),
        const RecommendedCard(
          backgroundColor: Color(0xFFD46A7A),
          accentColor: Color(0xFFF2C3CC),
        ),
        const SizedBox(height: 16),
        const RecommendedCard(
          backgroundColor: Color(0xFFF2C3CC),
          accentColor: Color(0xFFAA3D50),
        ),
      ],
    );
  }
}
