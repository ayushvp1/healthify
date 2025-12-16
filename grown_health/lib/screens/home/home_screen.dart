import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/providers.dart';

import 'widgets/widgets.dart';
import '../../services/water_service.dart';
import '../../services/water_reminder_service.dart';
import '../../services/exercise_bundle_service.dart';

import '../about/about_screen.dart';
import '../contact/contact_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _displayName = 'User';
  String _greeting = 'Good Morning!';
  String _searchQuery = '';

  // Bundles for recommended section
  List<ExerciseBundle> _bundles = [];
  bool _bundlesLoading = true;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadUserName();
    _startWaterReminders();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      setState(() => _bundlesLoading = false);
      return;
    }

    try {
      final service = ExerciseBundleService(token);
      final response = await service.getBundles(limit: 3);
      if (mounted) {
        setState(() {
          _bundles = response.bundles;
          _bundlesLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load bundles: $e');
      if (mounted) {
        setState(() => _bundlesLoading = false);
      }
    }
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
      key: _scaffoldKey,
      backgroundColor: AppTheme.white,
      drawer: _buildDrawer(),
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
                    // const SizedBox(height: 16),
                    // _buildSearchBar(),
                    const SizedBox(height: 24),
                    const WellnessSection(),
                    const SizedBox(height: 24),
                    _buildTodaysPlan(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Body Focus - Workout Programs by Category
            const SliverToBoxAdapter(child: BodyFocusWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.black),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.grey500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                SnackBarUtils.showInfo(
                  context,
                  'No new notifications',
                  duration: const Duration(seconds: 1),
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
                    color: AppTheme.cardBackground, // Even lighter pink
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
          color: AppTheme.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search Workouts',
          hintStyle: GoogleFonts.inter(
            color: AppTheme.grey700, // Darker text as requested
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
                color: AppTheme.primaryColor, // Dark Burgundy
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: AppTheme.white, size: 24),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
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
                  color: AppTheme.primaryColor, // Dark Burgundy
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/bundles'),
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Personalized workout suggestions',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 13, color: AppTheme.grey500),
          ),
        ),
        const SizedBox(height: 16),

        // Show loading or bundles
        if (_bundlesLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          )
        else
          // Display actual bundles or static fallback
          Column(
            children: [
              // Purple Card (Static or mapped from bundle 1)
              RecommendedCard(
                title: _bundles.isNotEmpty
                    ? _bundles[0].name
                    : '30 Days Challenge',
                duration: _bundles.isNotEmpty
                    ? '${_bundles[0].totalDays} Days'
                    : '20 mins',
                exercises: _bundles.isNotEmpty
                    ? '${_bundles[0].totalExercises} Exercises'
                    : '7 Exercises',
                level: _bundles.isNotEmpty
                    ? _bundles[0].difficultyDisplay
                    : 'Beginner',
                backgroundColor: const Color(0xFF8E44AD), // Deep Purple
                accentColor: const Color(0xFFD980FA), // Light Magenta
                onStart: () => _bundles.isNotEmpty
                    ? Navigator.pushNamed(context, '/bundle/${_bundles[0].id}')
                    : Navigator.pushNamed(context, '/bundles'),
              ),
              const SizedBox(height: 16),

              // Teal Card (Static or mapped from bundle 2)
              RecommendedCard(
                title: _bundles.length > 1
                    ? _bundles[1].name
                    : '30 Days Challenge',
                duration: _bundles.length > 1
                    ? '${_bundles[1].totalDays} Days'
                    : '20 mins',
                exercises: _bundles.length > 1
                    ? '${_bundles[1].totalExercises} Exercises'
                    : '7 Exercises',
                level: _bundles.length > 1
                    ? _bundles[1].difficultyDisplay
                    : 'Beginner',
                backgroundColor: const Color(0xFF1ABC9C), // Teal
                accentColor: const Color(0xFF16A085), // Dark teal/Green mix
                onStart: () => _bundles.length > 1
                    ? Navigator.pushNamed(context, '/bundle/${_bundles[1].id}')
                    : Navigator.pushNamed(context, '/bundles'),
              ),
              const SizedBox(height: 16),

              // Orange Card (Static or mapped from bundle 3)
              RecommendedCard(
                title: _bundles.length > 2
                    ? _bundles[2].name
                    : '30 Days Challenge',
                duration: _bundles.length > 2
                    ? '${_bundles[2].totalDays} Days'
                    : '20 mins',
                exercises: _bundles.length > 2
                    ? '${_bundles[2].totalExercises} Exercises'
                    : '7 Exercises',
                level: _bundles.length > 2
                    ? _bundles[2].difficultyDisplay
                    : 'Beginner',
                backgroundColor: const Color(0xFFF39C12), // Orange
                accentColor: const Color(0xFFF1C40F), // Yellow/Amber
                onStart: () => _bundles.length > 2
                    ? Navigator.pushNamed(context, '/bundle/${_bundles[2].id}')
                    : Navigator.pushNamed(context, '/bundles'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDrawer() {
    final user = ref.watch(authProvider).user;

    return Drawer(
      backgroundColor: AppTheme.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor, // Maroon
            ),
            accountName: Text(
              user?.name ?? _displayName,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? '', style: GoogleFonts.inter()),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppTheme.white,
              child: Icon(Icons.person, color: AppTheme.primaryColor, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('Home', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: Text('Contact', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text('Share', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Share App'),
                  content: const Text(
                    'Check out Grown Health app! (Link functionality placeholder)',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Copy Link'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: Text(
              'Logout',
              style: GoogleFonts.inter(color: AppTheme.errorColor),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
