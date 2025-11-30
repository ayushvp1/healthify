import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    // Greeting + profile/icon row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning!',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jhon Doe',
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
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE4E8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 20,
                                  color: Color(0xFFAA3D50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
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
                    ),
                    const SizedBox(height: 24),
                    // Medicine Reminder
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
                        textStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
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
                    const SizedBox(height: 24),
                    // Today's Plan header
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
                    // Today's Plan main card (image + text + chips)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                'assets/todays_plan.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Russian Twist',
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Our intense ab set based on the ground.',
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _InfoChip(
                                      icon:
                                          Icons.local_fire_department_outlined,
                                      label: '350 Kcal',
                                      background: const Color(0xFFE9F8EE),
                                      iconColor: const Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoChip(
                                      icon: Icons.timer_outlined,
                                      label: '10 min',
                                      background: const Color(0xFFFFF5E5),
                                      iconColor: const Color(0xFFFFA726),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Workout Bundles header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Workout Bundles',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tabs (simple static row)
                    SizedBox(
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
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Workout bundles list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/challenge');
                      },
                      child: const _BundleCard(
                        title: '30 Days Challenge',
                        subtitle: '7 Workouts  •  7 Exercises',
                        days: '30 Days',
                        level: 'Beginner',
                        color: Color(0xFF4DD0E1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _BundleCard(
                      title: '10 Days Challenge',
                      subtitle: '5 Workouts  •  20 mins',
                      days: '10 Days',
                      level: 'Beginner',
                      color: Color(0xFF80DEEA),
                    ),
                    const SizedBox(height: 12),
                    const _BundleCard(
                      title: '5 Days Challenge',
                      subtitle: '3 Workouts  •  10 mins',
                      days: '5 Days',
                      level: 'Beginner',
                      color: Color(0xFFB39DDB),
                    ),
                    const SizedBox(height: 24),
                    // Recommended for You section
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
                        textStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _RecommendedCard(
                      backgroundColor: Color(0xFF9C27B0),
                      accentColor: Color(0xFFAB47BC),
                    ),
                    const SizedBox(height: 16),
                    const _RecommendedCard(
                      backgroundColor: Color(0xFF009688),
                      accentColor: Color(0xFF26A69A),
                    ),
                    const SizedBox(height: 16),
                    const _RecommendedCard(
                      backgroundColor: Color(0xFFFFA000),
                      accentColor: Color(0xFFFFB74D),
                    ),
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

class _BundleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String days;
  final String level;
  final Color color;

  const _BundleCard({
    required this.title,
    required this.subtitle,
    required this.days,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      days,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      level,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Color backgroundColor;
  final Color accentColor;

  const _RecommendedCard({
    required this.backgroundColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Based on your fitness level',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '30 Days Challenge',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '20 mins',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.fitness_center_outlined,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '7 Exercises',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.star_border_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Beginner',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  'Start Bundle',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
