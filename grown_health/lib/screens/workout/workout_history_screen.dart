import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_config.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _weeklyStats;
  Map<String, dynamic>? _monthlyStats;
  Map<String, dynamic>? _allTimeStats;
  List<dynamic> _allWorkouts = [];

  bool _loadingWeekly = true;
  bool _loadingMonthly = true;
  bool _loadingAllTime = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadWeeklyStats(),
      _loadMonthlyStats(),
      _loadAllTimeStats(),
      _loadFullHistory(),
    ]);
  }

  Map<String, String> get _headers {
    final token = ref.read(authProvider).user?.token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _loadWeeklyStats() async {
    setState(() => _loadingWeekly = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workout-progress/stats/weekly'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _weeklyStats = data['data'];
          _loadingWeekly = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weekly stats: $e');
      setState(() => _loadingWeekly = false);
    }
  }

  Future<void> _loadMonthlyStats() async {
    setState(() => _loadingMonthly = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workout-progress/stats/monthly'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _monthlyStats = data['data'];
          _loadingMonthly = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monthly stats: $e');
      setState(() => _loadingMonthly = false);
    }
  }

  Future<void> _loadAllTimeStats() async {
    setState(() => _loadingAllTime = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workout-progress/stats/all-time'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _allTimeStats = data['data'];
          _loadingAllTime = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading all-time stats: $e');
      setState(() => _loadingAllTime = false);
    }
  }

  Future<void> _loadFullHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workout-progress/history?days=90'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _allWorkouts = data['data']?['sessions'] ?? [];
          _loadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _loadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Workout History',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.grey500,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWeeklyTab(), _buildMonthlyTab(), _buildAllTimeTab()],
      ),
    );
  }

  // ================= WEEKLY TAB =================
  Widget _buildWeeklyTab() {
    if (_loadingWeekly) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_weeklyStats == null) {
      return _buildEmptyState('No data available');
    }

    final summary = _weeklyStats!['summary'] as Map<String, dynamic>? ?? {};
    final dailyData = _weeklyStats!['dailyData'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadWeeklyStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryRow([
              _SummaryCard(
                title: 'Workouts',
                value: '${summary['totalWorkouts'] ?? 0}',
                icon: Icons.fitness_center,
                color: AppTheme.primaryColor,
              ),
              _SummaryCard(
                title: 'Active Days',
                value: '${summary['activeDays'] ?? 0}/7',
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
            ]),
            const SizedBox(height: 12),
            _buildSummaryRow([
              _SummaryCard(
                title: 'Total Time',
                value: _formatDuration(summary['totalDuration'] ?? 0),
                icon: Icons.timer,
                color: Colors.orange,
              ),
              _SummaryCard(
                title: 'Exercises',
                value: '${summary['totalExercises'] ?? 0}',
                icon: Icons.repeat,
                color: Colors.green,
              ),
            ]),
            const SizedBox(height: 24),

            // Weekly Chart
            Text(
              'This Week',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(dailyData),
            const SizedBox(height: 24),

            // Recent workouts this week
            Text(
              'Recent Sessions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildRecentWorkoutsList(7),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<dynamic> dailyData) {
    final maxWorkouts = dailyData.fold<int>(0, (max, d) {
      final val = (d['workouts'] as int?) ?? 0;
      return val > max ? val : max;
    });
    final chartHeight = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailyData.map((day) {
          final workouts = (day['workouts'] as int?) ?? 0;
          final dayName = day['dayName'] ?? '';
          final barHeight = maxWorkouts > 0
              ? (workouts / maxWorkouts) * chartHeight
              : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$workouts',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: workouts > 0
                      ? AppTheme.primaryColor
                      : AppTheme.grey400,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: barHeight > 8 ? barHeight : 8,
                decoration: BoxDecoration(
                  color: workouts > 0
                      ? AppTheme.primaryColor
                      : AppTheme.grey300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayName,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ================= MONTHLY TAB =================
  Widget _buildMonthlyTab() {
    if (_loadingMonthly) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_monthlyStats == null) {
      return _buildEmptyState('No data available');
    }

    final summary = _monthlyStats!['summary'] as Map<String, dynamic>? ?? {};
    final weeklyData = _monthlyStats!['weeklyData'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadMonthlyStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryRow([
              _SummaryCard(
                title: 'Workouts',
                value: '${summary['totalWorkouts'] ?? 0}',
                icon: Icons.fitness_center,
                color: AppTheme.primaryColor,
              ),
              _SummaryCard(
                title: 'Streak',
                value: '${summary['streak'] ?? 0} days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ]),
            const SizedBox(height: 12),
            _buildSummaryRow([
              _SummaryCard(
                title: 'Total Time',
                value: _formatDuration(summary['totalDuration'] ?? 0),
                icon: Icons.timer,
                color: Colors.blue,
              ),
              _SummaryCard(
                title: 'Active Days',
                value: '${summary['activeDays'] ?? 0}/30',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
            ]),
            const SizedBox(height: 24),

            // Weekly comparison chart
            Text(
              'Weekly Breakdown',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyComparisonChart(weeklyData),
            const SizedBox(height: 24),

            // Stats grid
            Text(
              'Monthly Stats',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(summary),
            const SizedBox(height: 24),

            // All workouts this month
            Text(
              'All Sessions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildRecentWorkoutsList(30),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyComparisonChart(List<dynamic> weeklyData) {
    final maxWorkouts = weeklyData.fold<int>(0, (max, w) {
      final val = (w['workouts'] as int?) ?? 0;
      return val > max ? val : max;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: weeklyData.map((week) {
          final workouts = (week['workouts'] as int?) ?? 0;
          final label = week['label'] ?? '';
          final duration = (week['duration'] as int?) ?? 0;
          final progress = maxWorkouts > 0 ? workouts / maxWorkouts : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey600,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: Text(
                    '$workouts • ${_formatDuration(duration)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                label: 'Avg Duration',
                value: _formatDuration(summary['avgDuration'] ?? 0),
              ),
              _StatItem(
                label: 'Exercises Done',
                value: '${summary['totalExercises'] ?? 0}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                label: 'Avg Workouts/Day',
                value: '${summary['avgWorkoutsPerDay'] ?? 0}',
              ),
              _StatItem(
                label: 'Avg Rating',
                value: '${summary['avgRating'] ?? 0}⭐',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ALL TIME TAB =================
  Widget _buildAllTimeTab() {
    if (_loadingAllTime) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_allTimeStats == null) {
      return _buildEmptyState('No data available');
    }

    final summary = _allTimeStats!['summary'] as Map<String, dynamic>? ?? {};
    final monthlyBreakdown =
        _allTimeStats!['monthlyBreakdown'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadAllTimeStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero stats
            _buildHeroStats(summary),
            const SizedBox(height: 24),

            // Monthly breakdown
            Text(
              'Last 6 Months',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildMonthlyChart(monthlyBreakdown),
            const SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildAchievements(summary),
            const SizedBox(height: 24),

            // All stats
            Text(
              'Lifetime Stats',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildLifetimeStats(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStats(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HeroStat(
                value: '${summary['totalWorkouts'] ?? 0}',
                label: 'Workouts',
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.white.withOpacity(0.3),
              ),
              _HeroStat(
                value: '${summary['totalHours'] ?? 0}h',
                label: 'Total Hours',
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.white.withOpacity(0.3),
              ),
              _HeroStat(
                value: '${summary['currentStreak'] ?? 0}',
                label: 'Current Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(List<dynamic> monthlyBreakdown) {
    final maxWorkouts = monthlyBreakdown.fold<int>(0, (max, m) {
      final val = (m['workouts'] as int?) ?? 0;
      return val > max ? val : max;
    });

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlyBreakdown.map((month) {
          final workouts = (month['workouts'] as int?) ?? 0;
          final monthName = month['month'] ?? '';
          final barHeight = maxWorkouts > 0
              ? (workouts / maxWorkouts) * 100
              : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$workouts',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: workouts > 0
                      ? AppTheme.primaryColor
                      : AppTheme.grey400,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: barHeight > 8 ? barHeight : 8,
                decoration: BoxDecoration(
                  gradient: workouts > 0
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: workouts > 0 ? null : AppTheme.grey300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                monthName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievements(Map<String, dynamic> summary) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if ((summary['totalWorkouts'] ?? 0) >= 1)
          _AchievementBadge(icon: Icons.fitness_center, label: 'First Workout'),
        if ((summary['totalWorkouts'] ?? 0) >= 10)
          _AchievementBadge(icon: Icons.star, label: '10 Workouts'),
        if ((summary['totalWorkouts'] ?? 0) >= 50)
          _AchievementBadge(icon: Icons.emoji_events, label: '50 Workouts'),
        if ((summary['bestStreak'] ?? 0) >= 7)
          _AchievementBadge(
            icon: Icons.local_fire_department,
            label: '7-Day Streak',
          ),
        if ((summary['totalHours'] ?? 0) >= 10)
          _AchievementBadge(icon: Icons.timer, label: '10+ Hours'),
      ],
    );
  }

  Widget _buildLifetimeStats(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          _LifetimeStatRow(
            label: 'Total Workouts',
            value: '${summary['totalWorkouts'] ?? 0}',
          ),
          _LifetimeStatRow(
            label: 'Total Time',
            value: _formatDuration(summary['totalDuration'] ?? 0),
          ),
          _LifetimeStatRow(
            label: 'Total Exercises',
            value: '${summary['totalExercises'] ?? 0}',
          ),
          _LifetimeStatRow(
            label: 'Programs Tried',
            value: '${summary['uniquePrograms'] ?? 0}',
          ),
          _LifetimeStatRow(
            label: 'Best Streak',
            value: '${summary['bestStreak'] ?? 0} days',
          ),
          _LifetimeStatRow(
            label: 'First Workout',
            value: summary['firstWorkoutDate'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _buildSummaryRow(List<Widget> children) {
    return Row(
      children: children
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: c != children.last ? 12 : 0),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildRecentWorkoutsList(int days) {
    final filtered = _allWorkouts
        .where((w) {
          try {
            final date = DateTime.parse(w['date'] ?? '');
            return DateTime.now().difference(date).inDays <= days;
          } catch (_) {
            return false;
          }
        })
        .take(10)
        .toList();

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No workouts in this period',
              style: GoogleFonts.inter(color: AppTheme.grey500),
            ),
          ),
        ),
      ];
    }

    return filtered.map((w) => _WorkoutHistoryCard(session: w)).toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: AppTheme.grey300),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.grey500),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete workouts to see your stats',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey400),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final mins = seconds ~/ 60;
    if (mins < 60) return '${mins}m';
    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    return '${hours}h ${remainingMins}m';
  }
}

// ================= SUPPORTING WIDGETS =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AchievementBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber[700], size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifetimeStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _LifetimeStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final Map<String, dynamic> session;

  const _WorkoutHistoryCard({required this.session});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0m';
    final mins = (seconds / 60).ceil();
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final title = session['title'] ?? 'Workout';
    final date = session['date'] as String?;
    final duration = session['totalDuration'] as int? ?? 0;
    final exercises = session['completedExercises'] ?? 0;
    final status = session['status'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: status == 'completed'
                  ? AppTheme.checkGreen.withOpacity(0.15)
                  : AppTheme.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == 'completed' ? Icons.check_circle : Icons.close,
              color: status == 'completed'
                  ? AppTheme.checkGreen
                  : AppTheme.grey500,
              size: 22,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDate(date)} • ${_formatDuration(duration)} • $exercises exercises',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
