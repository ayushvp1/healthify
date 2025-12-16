import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/providers.dart';

import 'widgets/widgets.dart';
import '../../services/water_service.dart';
import '../../services/water_reminder_service.dart';

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
                    const TodaysPlanSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Body Focus - Workout Programs by Category
            const SliverToBoxAdapter(child: BodyFocusWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
            // IconButton(
            //   icon: const Icon(Icons.notifications_none_rounded),
            //   onPressed: () {
            //     SnackBarUtils.showInfo(
            //       context,
            //       'No new notifications',
            //       duration: const Duration(seconds: 1),
            //     );
            //   },
            // ),
            // const SizedBox(width: 4),
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
