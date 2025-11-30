import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/providers.dart';
import 'widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
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

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName;

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
                    _buildHeader(displayName),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildMedicineReminder(),
                    const SizedBox(height: 24),
                    _buildTodaysPlan(context),
                    const SizedBox(height: 24),
                    _buildWorkoutBundlesHeader(),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 16),
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
                    _buildBundlesList(context),
                    const SizedBox(height: 24),
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

  Widget _buildHeader(String displayName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
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
              onPressed: () {},
            ),
            const SizedBox(width: 4),
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE4E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Color(0xFFAA3D50),
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
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Workouts',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
            Text(
              'See all',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'No medicine reminders set',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
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

  Widget _buildWorkoutBundlesHeader() {
    return Text(
      'Workout Bundles',
      style: GoogleFonts.inter(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _TabPill(label: 'Arm', selected: true),
          _TabPill(label: 'Chest'),
          _TabPill(label: 'Leg'),
          _TabPill(label: 'Shoulder'),
        ],
      ),
    );
  }

  Widget _buildBundlesList(BuildContext context) {
    return Column(
      children: [
        BundleCard(
          title: '30 Days Challenge',
          subtitle: '7 Workouts  •  7 Exercises',
          days: '30 Days',
          level: 'Beginner',
          color: const Color(0xFF4DD0E1),
          onTap: () => Navigator.of(context).pushNamed('/challenge'),
        ),
        const SizedBox(height: 12),
        const BundleCard(
          title: '10 Days Challenge',
          subtitle: '5 Workouts  •  20 mins',
          days: '10 Days',
          level: 'Beginner',
          color: Color(0xFF80DEEA),
        ),
        const SizedBox(height: 12),
        const BundleCard(
          title: '5 Days Challenge',
          subtitle: '3 Workouts  •  10 mins',
          days: '5 Days',
          level: 'Beginner',
          color: Color(0xFFB39DDB),
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
          backgroundColor: Color(0xFF9C27B0),
          accentColor: Color(0xFFAB47BC),
        ),
        const SizedBox(height: 16),
        const RecommendedCard(
          backgroundColor: Color(0xFF009688),
          accentColor: Color(0xFF26A69A),
        ),
        const SizedBox(height: 16),
        const RecommendedCard(
          backgroundColor: Color(0xFFFFA000),
          accentColor: Color(0xFFFFB74D),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabPill({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFAA3D50) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
