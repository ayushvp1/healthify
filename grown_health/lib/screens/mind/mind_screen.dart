import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/providers.dart';
import '../../services/meditation_service.dart';
import 'mind_detail_screen.dart';
import 'audio_player_screen.dart';

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
  String? _selectedCategory;

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

  List<Meditation> get _filteredMeditations {
    if (_selectedCategory == null) return _meditations;
    return _meditations
        .where((m) => m.categoryName == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Minimal Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mind',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Find your calm',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Refresh Button
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: _loadMeditations,
                  ),
                ],
              ),
            ),
          ),
          // Body content
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading meditations...',
                style: GoogleFonts.inter(color: AppTheme.grey500),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.grey400),
              const SizedBox(height: 16),
              Text(_error!, style: GoogleFonts.inter(color: AppTheme.grey600)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMeditations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_meditations.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement_rounded,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No meditations available',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new sessions',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        if (_groupedByCategory.keys.length > 1) ...[
          const SizedBox(height: 20),
          _buildCategoryChips(),
        ],

        // Meditations List
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _selectedCategory ?? 'All Sessions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Display filtered meditations
        ..._filteredMeditations.map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _buildMeditationCard(m),
          ),
        ),

        const SizedBox(height: 100), // Bottom padding for nav bar
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', ..._groupedByCategory.keys];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              (category == 'All' && _selectedCategory == null) ||
              category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.grey700,
              ),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryColor, // Primary maroon
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme
                            .primaryColor // Primary maroon
                      : AppTheme.grey300,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category == 'All' ? null : category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeditationCard(Meditation meditation) {
    return GestureDetector(
      onTap: () => _navigateToDetail(meditation),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Thumbnail
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(meditation.categoryName),
                    _getCategoryColor(meditation.categoryName).withOpacity(0.7),
                  ],
                ),
              ),
              child: meditation.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        meditation.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.self_improvement_rounded,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.self_improvement_rounded,
                      color: Colors.white70,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 14),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppTheme.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meditation.formattedDuration,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.grey500,
                        ),
                      ),
                      if (meditation.categoryName != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              meditation.categoryName,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meditation.categoryName!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(meditation.categoryName),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Play Button
            GestureDetector(
              onTap: () => _playMeditation(meditation),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor, // Primary maroon
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
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

  void _playMeditation(Meditation meditation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(
          meditationId: meditation.id,
          title: meditation.title,
          audioUrl: meditation.audioUrl,
          thumbnailUrl: meditation.image,
          durationSeconds: meditation.duration,
          categoryName: meditation.categoryName,
        ),
      ),
    );
  }

  Color _getCategoryColor(String? categoryName) {
    final colors = {
      'Relaxation': const Color(0xFF667eea),
      'Focus': const Color(0xFF764ba2),
      'Sleep': const Color(0xFF0F3460),
      'Stress': const Color(0xFF11998e),
      'Anxiety': const Color(0xFF38ef7d),
      'Energy': const Color(0xFFfc4a1a),
      'Breathing': const Color(0xFF00b4db),
    };
    return colors[categoryName] ?? const Color(0xFF667eea);
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
      image: json['thumbnail'] as String? ?? json['image'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  String get formattedDuration {
    final mins = (duration / 60).floor();
    if (mins < 1) return '< 1 min';
    return '$mins min';
  }
}
