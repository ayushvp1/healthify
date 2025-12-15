import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../../providers/providers.dart';
import '../../../services/exercise_bundle_service.dart';

/// Widget showing workout bundles grouped by category tabs.
/// Ported from reference app's BodyFocus widget with improved styling.
class BodyFocusWidget extends ConsumerStatefulWidget {
  const BodyFocusWidget({super.key});

  @override
  ConsumerState<BodyFocusWidget> createState() => _BodyFocusWidgetState();
}

class _BodyFocusWidgetState extends ConsumerState<BodyFocusWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  String? _error;

  // Bundles grouped by category name
  Map<String, List<ExerciseBundle>> _bundlesByCategory = {};
  List<String> _categoryNames = [];

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadBundles() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please log in to view workouts';
      });
      return;
    }

    try {
      final service = ExerciseBundleService(token);
      final response = await service.getBundles(limit: 50);

      // Group bundles by category
      final grouped = <String, List<ExerciseBundle>>{};
      for (final bundle in response.bundles) {
        final categoryName = bundle.category?.name ?? 'Uncategorized';
        grouped.putIfAbsent(categoryName, () => []);
        grouped[categoryName]!.add(bundle);
      }

      // Sort categories alphabetically
      final sortedCategories = grouped.keys.toList()..sort();

      if (mounted) {
        _tabController?.dispose();
        _tabController = TabController(
          length: sortedCategories.length,
          vsync: this,
        );

        setState(() {
          _bundlesByCategory = grouped;
          _categoryNames = sortedCategories;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load workouts';
        });
      }
    }
  }

  int _getDifficultyStars(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null || _categoryNames.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'No workout bundles available',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: _loadBundles, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Programs',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/bundles'),
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Category Tabs
        Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            labelPadding: const EdgeInsets.only(right: 8),
            tabs: _categoryNames.map((categoryName) {
              return Tab(
                child: AnimatedBuilder(
                  animation: _tabController!.animation!,
                  builder: (context, child) {
                    final tabIndex = _categoryNames.indexOf(categoryName);
                    final isSelected = _tabController!.index == tabIndex;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Bundle List per Category Tab
        SizedBox(
          height: 280,
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: _categoryNames.map((categoryName) {
              final bundles = (_bundlesByCategory[categoryName] ?? [])
                  .take(3)
                  .toList();

              if (bundles.isEmpty) {
                return Center(
                  child: Text(
                    'No programs in $categoryName',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bundles.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 24, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final bundle = bundles[index];
                  final difficultyStars = _getDifficultyStars(
                    bundle.difficulty,
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/bundle/${bundle.id}');
                    },
                    child: Row(
                      children: [
                        // Bundle Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: bundle.thumbnail.isNotEmpty
                              ? Image.network(
                                  bundle.thumbnail,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),

                        const SizedBox(width: 16),

                        // Bundle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bundle Name
                              Text(
                                bundle.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Exercise Count and Duration
                              Text(
                                '${bundle.totalExercises} Exercises • ${bundle.totalDays} Days',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Difficulty Stars
                              Row(
                                children: [
                                  ...List.generate(3, (starIndex) {
                                    return Icon(
                                      Icons.bolt,
                                      size: 16,
                                      color: starIndex < difficultyStars
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade300,
                                    );
                                  }),
                                  const SizedBox(width: 6),
                                  Text(
                                    bundle.difficultyDisplay,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow Icon
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.fitness_center,
        size: 32,
        color: AppTheme.primaryColor.withOpacity(0.5),
      ),
    );
  }
}
