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
  String _selectedBundleGroup = 'Arm';
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
                    _buildMedicineReminder(),
                    const SizedBox(height: 12),
                    const WaterTrackingWidget(),
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
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/medicine_reminders');
              },
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
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
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add medicine reminder - coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Text(
            'Add',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
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
        children: [
          _TabPill(
            label: 'Arm',
            selected: _selectedBundleGroup == 'Arm',
            onTap: () => setState(() => _selectedBundleGroup = 'Arm'),
          ),
          _TabPill(
            label: 'Chest',
            selected: _selectedBundleGroup == 'Chest',
            onTap: () => setState(() => _selectedBundleGroup = 'Chest'),
          ),
          _TabPill(
            label: 'Leg',
            selected: _selectedBundleGroup == 'Leg',
            onTap: () => setState(() => _selectedBundleGroup = 'Leg'),
          ),
          _TabPill(
            label: 'Shoulder',
            selected: _selectedBundleGroup == 'Shoulder',
            onTap: () => setState(() => _selectedBundleGroup = 'Shoulder'),
          ),
        ],
      ),
    );
  }

  Widget _buildBundlesList(BuildContext context) {
    // For now, show different hardcoded bundles per group and filter by search.
    // These can later be driven by API.
    if (_selectedBundleGroup == 'Arm') {
      final items = [
        {
          'title': '30 Days Arm Challenge',
          'subtitle': '7 Workouts  •  7 Exercises',
          'days': '30 Days',
          'level': 'Beginner',
          'color': const Color(0xFFAA3D50),
          'onTap': () => Navigator.of(context).pushNamed('/challenge'),
        },
        {
          'title': '10 Days Arm Blast',
          'subtitle': '5 Workouts  •  20 mins',
          'days': '10 Days',
          'level': 'Beginner',
          'color': const Color(0xFFD46A7A),
        },
        {
          'title': '5 Days Quick Arms',
          'subtitle': '3 Workouts  •  10 mins',
          'days': '5 Days',
          'level': 'Beginner',
          'color': const Color(0xFFF2C3CC),
        },
      ];

      final filtered = _filterBundles(items);
      if (filtered.isEmpty) {
        return _buildNoSearchResults();
      }

      return Column(
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            BundleCard(
              title: filtered[i]['title'] as String,
              subtitle: filtered[i]['subtitle'] as String,
              days: filtered[i]['days'] as String,
              level: filtered[i]['level'] as String,
              color: filtered[i]['color'] as Color,
              onTap: filtered[i]['onTap'] as void Function()?,
            ),
            if (i != filtered.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    } else if (_selectedBundleGroup == 'Chest') {
      final items = [
        {
          'title': 'Chest Strength Builder',
          'subtitle': '5 Workouts  •  15 mins',
          'days': '14 Days',
          'level': 'Intermediate',
          'color': const Color(0xFFAA3D50),
        },
        {
          'title': 'Push-up Power',
          'subtitle': '4 Workouts  •  12 mins',
          'days': '7 Days',
          'level': 'Beginner',
          'color': const Color(0xFFD46A7A),
        },
      ];
      final filtered = _filterBundles(items);
      if (filtered.isEmpty) {
        return _buildNoSearchResults();
      }
      return Column(
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            BundleCard(
              title: filtered[i]['title'] as String,
              subtitle: filtered[i]['subtitle'] as String,
              days: filtered[i]['days'] as String,
              level: filtered[i]['level'] as String,
              color: filtered[i]['color'] as Color,
            ),
            if (i != filtered.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    } else if (_selectedBundleGroup == 'Leg') {
      final items = [
        {
          'title': 'Leg Day Essentials',
          'subtitle': '6 Workouts  •  18 mins',
          'days': '21 Days',
          'level': 'Beginner',
          'color': const Color(0xFFAA3D50),
        },
        {
          'title': 'Glutes & Thighs',
          'subtitle': '5 Workouts  •  20 mins',
          'days': '10 Days',
          'level': 'Intermediate',
          'color': const Color(0xFFD46A7A),
        },
      ];
      final filtered = _filterBundles(items);
      if (filtered.isEmpty) {
        return _buildNoSearchResults();
      }
      return Column(
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            BundleCard(
              title: filtered[i]['title'] as String,
              subtitle: filtered[i]['subtitle'] as String,
              days: filtered[i]['days'] as String,
              level: filtered[i]['level'] as String,
              color: filtered[i]['color'] as Color,
            ),
            if (i != filtered.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    } else {
      // Shoulder
      final items = [
        {
          'title': 'Strong Shoulders',
          'subtitle': '4 Workouts  •  15 mins',
          'days': '12 Days',
          'level': 'Beginner',
          'color': const Color(0xFFAA3D50),
        },
        {
          'title': 'Posture Fix',
          'subtitle': '3 Workouts  •  10 mins',
          'days': '7 Days',
          'level': 'Beginner',
          'color': const Color(0xFFD46A7A),
        },
      ];
      final filtered = _filterBundles(items);
      if (filtered.isEmpty) {
        return _buildNoSearchResults();
      }
      return Column(
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            BundleCard(
              title: filtered[i]['title'] as String,
              subtitle: filtered[i]['subtitle'] as String,
              days: filtered[i]['days'] as String,
              level: filtered[i]['level'] as String,
              color: filtered[i]['color'] as Color,
            ),
            if (i != filtered.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
  }

  List<Map<String, Object?>> _filterBundles(List<Map<String, Object?>> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where(
          (item) =>
              (item['title'] as String).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  Widget _buildNoSearchResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'No workouts match your search',
        style: GoogleFonts.inter(
          textStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
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

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TabPill({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
