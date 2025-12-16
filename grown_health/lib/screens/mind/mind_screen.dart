import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/core.dart';
import '../../providers/providers.dart';
import '../../services/meditation_service.dart';
import 'mind_detail_screen.dart';

/// Mind/Meditation screen with featured section and category grouping.
/// Fetches meditations from backend API.
class MindScreen extends ConsumerStatefulWidget {
  const MindScreen({super.key});

  @override
  ConsumerState<MindScreen> createState() => _MindScreenState();
}

class _MindScreenState extends ConsumerState<MindScreen> {
  bool _isLoading = true;
  String? _error;
  List<Meditation> _meditations = [];
  Map<String, List<Meditation>> _groupedByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadMeditations();
  }

  Future<void> _loadMeditations() async {
    final token = ref.read(authProvider).user?.token;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = MeditationService(token);
      final response = await service.getMeditations(limit: 50);

      final data = response['data'] as List? ?? [];
      final meditations = data.map((e) => Meditation.fromJson(e)).toList();

      // Group by category
      final grouped = <String, List<Meditation>>{};
      for (final meditation in meditations) {
        final categoryName = meditation.categoryName ?? 'Uncategorized';
        grouped.putIfAbsent(categoryName, () => []);
        grouped[categoryName]!.add(meditation);
      }

      if (mounted) {
        setState(() {
          _meditations = meditations;
          _groupedByCategory = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load meditations';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mind',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        foregroundColor: AppTheme.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeditations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.inter(color: AppTheme.grey600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeditations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_meditations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 64, color: AppTheme.grey300),
            const SizedBox(height: 16),
            Text(
              'No meditations available',
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.grey600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeditations,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Section (first 3 meditations)
            if (_meditations.isNotEmpty) ...[
              _buildSectionHeader('Featured', onSeeAll: null),
              const SizedBox(height: 12),
              _buildFeaturedSection(),
              const SizedBox(height: 24),
            ],

            // Categories
            ..._groupedByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final meditations = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(categoryName, onSeeAll: null),
                  const SizedBox(height: 12),
                  ...meditations
                      .take(3)
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMeditationCard(m),
                        ),
                      ),
                  const SizedBox(height: 12),
                ],
              );
            }),

            const SizedBox(height: 80), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    final featured = _meditations.take(3).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final meditation = featured[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index < featured.length - 1 ? 16 : 0,
            ),
            child: _buildFeaturedCard(meditation),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(Meditation meditation) {
    return GestureDetector(
      onTap: () => _navigateToDetail(meditation),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCategoryColor(meditation.categoryName).withOpacity(0.8),
              _getCategoryColor(meditation.categoryName).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (meditation.hasVideo)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam,
                      color: AppTheme.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              meditation.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meditation.formattedDuration,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (meditation.difficulty != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meditation.difficulty!.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationCard(Meditation meditation) {
    return GestureDetector(
      onTap: () => _navigateToDetail(meditation),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: _getCategoryColor(meditation.categoryName).withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getCategoryColor(meditation.categoryName),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          meditation.title,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meditation.hasVideo) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.videocam,
                          size: 16,
                          color: AppTheme.errorColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation.formattedDuration,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppTheme.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Meditation meditation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MindDetailScreen(meditationId: meditation.id),
      ),
    );
  }

  Color _getCategoryColor(String? categoryName) {
    final colors = {
      'Relaxation': AppTheme.blue400,
      'Focus': AppTheme.purple400,
      'Sleep': AppTheme.indigo400,
      'Stress': AppTheme.teal400,
      'Anxiety': AppTheme.green400,
      'Energy': AppTheme.orange400,
    };
    return colors[categoryName] ?? AppTheme.orange300;
  }
}

/// Meditation model for parsing API response
class Meditation {
  final String id;
  final String title;
  final String? description;
  final int duration; // in seconds
  final String? difficulty;
  final String? categoryName;
  final String? categoryId;
  final String? image;
  final String? videoUrl;
  final String? audioUrl;

  Meditation({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    this.difficulty,
    this.categoryName,
    this.categoryId,
    this.image,
    this.videoUrl,
    this.audioUrl,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    String? categoryName;
    String? categoryId;

    if (category is Map<String, dynamic>) {
      categoryName = category['name'] as String?;
      categoryId = category['_id'] as String?;
    } else if (category is String) {
      categoryId = category;
    }

    return Meditation(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      duration: json['duration'] as int? ?? 0,
      difficulty: json['difficulty'] as String?,
      categoryName: categoryName,
      categoryId: categoryId,
      image: json['image'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  String get formattedDuration {
    final mins = (duration / 60).floor();
    if (mins < 1) return '< 1 min';
    return '$mins min';
  }
}
