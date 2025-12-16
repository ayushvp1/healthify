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
            // Categories
            ..._groupedByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final meditations = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    categoryName,
                    onSeeAll: () {
                      // Handle see all action
                    },
                  ),
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
              fontWeight: FontWeight.w700, // Made bolder as per design
              color: AppTheme.black,
            ),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkRedText, // Matches red in design
                ),
              ),
            ),
          ),
      ],
    ); // _buildSectionHeader
  }

  Widget _buildMeditationCard(Meditation meditation) {
    return GestureDetector(
      onTap: () => _navigateToDetail(meditation),
      child: Container(
        height: 80, // Slightly reduced height to match compact design
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey200),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8), // Padding inside the card
        child: Row(
          children: [
            // Image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.grey100,
                image: meditation.image != null
                    ? DecorationImage(
                        image: NetworkImage(meditation.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: meditation.image == null
                  ? Icon(
                      Icons.image_not_supported,
                      color: AppTheme.grey400,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700, // Bold title
                        color: AppTheme.black,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation.formattedDuration,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey500, // Grey subtitle
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Play Button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.darkGreen, // Dark green play button
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
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
