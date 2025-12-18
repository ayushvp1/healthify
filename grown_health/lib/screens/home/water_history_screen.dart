import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../providers/providers.dart';
import '../../services/water_service.dart';

class WaterHistoryScreen extends ConsumerStatefulWidget {
  const WaterHistoryScreen({super.key});

  @override
  ConsumerState<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends ConsumerState<WaterHistoryScreen> {
  bool _isLoading = true;
  WaterHistoryResponse? _historyData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token;
      if (token == null) throw Exception('User not authenticated');

      final waterService = WaterService(token);
      final data = await waterService.getWaterHistory(days: 30);

      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildErrorState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Hydration History',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.grey500),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_historyData == null || _historyData!.history.isEmpty) {
      return const Center(child: Text('No water data available yet.'));
    }

    final summary = _historyData!.summary;
    final history = _historyData!.history.reversed.toList();

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(summary),
          const SizedBox(height: 24),
          _buildChart(history.take(7).toList().reversed.toList()),
          const SizedBox(height: 24),
          Text(
            'Past 30 Days',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          ...history.map((record) => _buildHistoryItem(record)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(WaterSummary summary) {
    return Row(
      children: [
        _buildStatCard(
          'Average',
          '${(summary.averagePerDay * 250).toInt()}',
          'ml / day',
          const Color(0xFFE1F5FE),
          const Color(0xFF0288D1),
          Icons.analytics_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Goal Hit',
          '${summary.completedDays}',
          '/${summary.totalDays} days',
          const Color(0xFFE8F5E9),
          const Color(0xFF388E3C),
          Icons.emoji_events_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Total',
          '${summary.totalGlasses * 250}',
          'ml total',
          const Color(0xFFFFF3E0),
          const Color(0xFFF57C00),
          Icons.water_drop_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    Color bgColor,
    Color iconColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<WaterDayRecord> last7Days) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress (ml)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF0288D1),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7Days.map((record) {
                final heightFactor = (record.count / record.goal).clamp(
                  0.1,
                  1.2,
                );
                final date = DateTime.parse(record.date);
                final dayLabel = DateFormat('E').format(date);
                final isToday =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                    record.date;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${record.count * 250}',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: record.completed
                            ? const Color(0xFF388E3C)
                            : AppTheme.grey500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 100 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: record.completed
                              ? [
                                  const Color(0xFF4CAF50),
                                  const Color(0xFF81C784),
                                ]
                              : [
                                  const Color(0xFF03A9F4).withOpacity(0.6),
                                  const Color(0xFF81D4FA).withOpacity(0.6),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? AppTheme.primaryColor
                            : AppTheme.grey500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(WaterDayRecord record) {
    final date = DateTime.parse(record.date);
    final isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == record.date;
    final formattedDate = isToday
        ? 'Today'
        : DateFormat('MMM dd, yyyy').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: record.completed
              ? const Color(0xFFE8F5E9)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: record.completed
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFE1F5FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record.completed
                  ? Icons.check_circle_rounded
                  : Icons.water_drop_rounded,
              color: record.completed
                  ? const Color(0xFF43A047)
                  : const Color(0xFF0288D1),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                Text(
                  '${record.count * 250} / ${record.goal * 250} ml',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: record.completed
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : AppTheme.grey100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${record.percentage}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: record.completed
                    ? const Color(0xFF2E7D32)
                    : AppTheme.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
