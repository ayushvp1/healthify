import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api_config.dart';
import '../../widgets/widgets.dart';
import '../../providers/auth_provider.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _exercises = [];
  List<dynamic> _filteredExercises = [];
  List<dynamic> _recentWorkouts = [];
  bool _loadingCategories = true;
  bool _loadingExercises = true;
  bool _loadingHistory = true;
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showAllExercises = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _searchQuery = query;
      _filterExercises();
    });
  }

  void _filterExercises() {
    if (_searchQuery.isEmpty) {
      _filteredExercises = List.from(_exercises);
    } else {
      _filteredExercises = _exercises.where((ex) {
        final title = (ex['title'] ?? '').toString().toLowerCase();
        final desc = (ex['description'] ?? '').toString().toLowerCase();
        final category = (ex['category']?['name'] ?? '')
            .toString()
            .toLowerCase();
        return title.contains(_searchQuery) ||
            desc.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadExercises(null),
      _loadRecentWorkouts(),
    ]);
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/categories?limit=50');
      final res = await http.get(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final categories = data['data'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _categories = categories;
            _loadingCategories = false;
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadExercises(String? categoryId) async {
    setState(() => _loadingExercises = true);

    try {
      String url = '${ApiConfig.baseUrl}/exercises?limit=50';
      if (categoryId != null) {
        url += '&category=$categoryId';
      }
      final uri = Uri.parse(url);
      final res = await http.get(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final exercises = data['data'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _exercises = exercises;
            _loadingExercises = false;
            _filterExercises();
          });
        }
      } else {
        throw Exception('Failed: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      if (mounted) {
        setState(() {
          _exercises = [];
          _filteredExercises = [];
          _loadingExercises = false;
        });
      }
    }
  }

  Future<void> _loadRecentWorkouts() async {
    setState(() => _loadingHistory = true);

    try {
      final token = ref.read(authProvider).user?.token;
      if (token == null) {
        setState(() => _loadingHistory = false);
        return;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/workout-progress/history?days=30&status=completed',
      );
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final sessions = data['data']?['sessions'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _recentWorkouts = sessions.take(5).toList(); // Show last 5
            _loadingHistory = false;
          });
        }
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      debugPrint('Error loading workout history: $e');
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  void _selectCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _loadExercises(categoryId);
  }

  void _navigateToExerciseDetail(Map<String, dynamic> exercise) async {
    // Navigate to exercise detail and wait for result
    await Navigator.of(
      context,
    ).pushNamed('/exercise_detail', arguments: exercise);
    // Refresh recent workouts when returning (in case user completed an exercise)
    _loadRecentWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.accentColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
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
                              'Workouts',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Build your strength, one rep at a time',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.grey500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // History Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkoutHistoryScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bar_chart_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: _buildSearchBar(),
                  ),
                ),

                // Recent Workouts Section
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 8,
                //     ),
                //     child: _buildRecentWorkoutsSection(),
                //   ),
                // ),

                // Exercise Library Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: _buildExerciseLibrarySection(),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppTheme.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.grey500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.grey500,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.grey500,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== RECENT WORKOUTS SECTION ====================
  Widget _buildRecentWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            // Always show View History button
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WorkoutHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart, size: 18),
              label: Text(
                _recentWorkouts.isEmpty ? 'View History' : 'See All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          )
        else if (_recentWorkouts.isEmpty)
          _buildEmptyRecentWorkouts()
        else
          // Show only 2 most recent workouts
          ..._recentWorkouts
              .take(2)
              .map((session) => _RecentWorkoutCard(session: session))
              .toList(),
      ],
    );
  }

  Widget _buildEmptyRecentWorkouts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No workouts yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete your first workout to see it here',
                  style: GoogleFonts.inter(
                    fontSize: 13,
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

  // ==================== EXERCISE LIBRARY SECTION ====================
  Widget _buildExerciseLibrarySection() {
    final displayExercises = _filteredExercises;
    final showingFiltered = _searchQuery.isNotEmpty;
    final exercisesToShow = _showAllExercises
        ? displayExercises
        : displayExercises.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercise Library',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _showAllExercises = !_showAllExercises);
              },
              child: Text(
                _showAllExercises ? 'Show Less' : 'Browse All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Categories
        if (!showingFiltered) ...[
          _buildCategoriesRow(),
          const SizedBox(height: 16),
        ],

        // Exercises count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showingFiltered
                  ? 'Search Results'
                  : _selectedCategoryId == null
                  ? 'All Exercises'
                  : _categories.firstWhere(
                      (c) => c['_id'] == _selectedCategoryId,
                      orElse: () => {'name': 'Exercises'},
                    )['name'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
            Text(
              '${displayExercises.length} found',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Exercises grid or list
        if (_loadingExercises)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          )
        else if (displayExercises.isEmpty)
          _buildEmptyExercises(showingFiltered)
        else
          ...exercisesToShow.map((ex) {
            final exerciseMap = ex as Map<String, dynamic>;
            return _ExerciseRow(
              title: exerciseMap['title'] ?? 'Exercise',
              duration: '${exerciseMap['duration'] ?? 30}s',
              difficulty: exerciseMap['difficulty'] ?? 'beginner',
              imageUrl: exerciseMap['gif']?.isNotEmpty == true
                  ? exerciseMap['gif']
                  : (exerciseMap['image'] ?? ''),
              onTap: () => _navigateToExerciseDetail(exerciseMap),
            );
          }),

        // Show more button if there are more exercises
        if (!_showAllExercises && displayExercises.length > 4)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () => setState(() => _showAllExercises = true),
                icon: const Icon(Icons.expand_more, size: 20),
                label: Text(
                  'Show ${displayExercises.length - 4} more',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesRow() {
    if (_loadingCategories) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              name: 'All',
              isSelected: _selectedCategoryId == null,
              onTap: () => _selectCategory(null),
            );
          }
          final cat = _categories[index - 1];
          return _CategoryChip(
            name: cat['name'] ?? 'Category',
            isSelected: cat['_id'] == _selectedCategoryId,
            onTap: () => _selectCategory(cat['_id']),
          );
        },
      ),
    );
  }

  Widget _buildEmptyExercises(bool showingFiltered) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: EmptyStateWidget(
        icon: showingFiltered ? Icons.search_off : Icons.fitness_center_rounded,
        title: showingFiltered ? 'No matching exercises' : 'No exercises found',
        description: showingFiltered
            ? 'Try adjusting your search or filters'
            : 'Add exercises in the admin panel to see them here.',
      ),
    );
  }
}

// ==================== RECENT WORKOUT CARD ====================
class _RecentWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> session;

  const _RecentWorkoutCard({required this.session});

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0 min';
    final mins = (seconds / 60).ceil();
    return '$mins min';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) return 'Today';
      if (dateOnly == yesterday) return 'Yesterday';

      final diff = today.difference(dateOnly).inDays;
      if (diff < 7) return '$diff days ago';

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

  @override
  Widget build(BuildContext context) {
    final title = session['title'] ?? session['programDayTitle'] ?? 'Workout';
    final duration = session['totalDuration'] as int? ?? 0;
    final completedExercises = session['completedExercises'] ?? 0;
    final totalExercises = session['totalExercises'] ?? 0;
    final date = session['date'] as String?;
    final rating = session['rating'] as int?;

    return GestureDetector(
      onTap: () {
        // If we have an exercise ID (single exercise), navigate to detail
        // Note: The history API might return partial exercise data.
        // We'll try to reconstruct minimal exercise object or fetch it.
        // For now, if we have exerciseId/exerciseTitle, we try to navigate.
        if (session['exerciseId'] != null) {
          final exercise = {
            '_id': session['exerciseId'],
            'title': session['title'] ?? 'Exercise',
            'duration': duration,
            // Add defaults or other available fields
          };
          Navigator.of(
            context,
          ).pushNamed('/exercise_detail', arguments: exercise);
        } else {
          // If it's a full workout program, we might navigate elsewhere,
          // but for now we just show a snackbar or do nothing.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detail view not available for this session type'),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.checkGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.checkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.grey500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: AppTheme.grey400,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.grey500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: AppTheme.grey400,
                        ),
                      ),
                      Text(
                        '$completedExercises/$totalExercises',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 2),
                  Text(
                    '$rating',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== CATEGORY CHIP ====================
class _CategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.grey100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppTheme.grey200, width: 1),
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.white : AppTheme.grey600,
          ),
        ),
      ),
    );
  }
}

// ==================== EXERCISE ROW ====================
class _ExerciseRow extends StatelessWidget {
  final String title;
  final String duration;
  final String difficulty;
  final String imageUrl;
  final VoidCallback onTap;

  const _ExerciseRow({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.highlightPink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fitness_center_rounded,
                          color: AppTheme.accentColor,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center_rounded,
                        color: AppTheme.accentColor,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        duration,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: AppTheme.grey400,
                        ),
                      ),
                      Text(
                        difficulty[0].toUpperCase() + difficulty.substring(1),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
