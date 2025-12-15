import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api_config.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _exercises = [];
  List<dynamic> _filteredExercises = [];
  bool _loadingCategories = true;
  bool _loadingExercises = true;
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
    await Future.wait([_loadCategories(), _loadExercises(null)]);
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/categories?limit=50');
      debugPrint('Loading categories from: $uri');
      final res = await http.get(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final categories = data['data'] as List<dynamic>? ?? [];
        debugPrint('Loaded ${categories.length} categories');

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
      debugPrint('Loading exercises from: $uri');
      final res = await http.get(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final exercises = data['data'] as List<dynamic>? ?? [];
        debugPrint('Loaded ${exercises.length} exercises');

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

  void _selectCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _loadExercises(categoryId);
  }

  void _navigateToExerciseDetail(Map<String, dynamic> exercise) {
    Navigator.of(context).pushNamed('/exercise_detail', arguments: exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFAA3D50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workouts',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore exercises by category',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Functional Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Categories Section
                  _buildCategoriesSection(),

                  const SizedBox(height: 24),

                  // Exercises Section
                  _buildExercisesSection(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF5B0C23),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingCategories)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
            ),
          )
        else if (_categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No categories found',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryCard(
                    name: 'All',
                    imageUrl: '',
                    icon: Icons.apps,
                    isSelected: _selectedCategoryId == null,
                    onTap: () => _selectCategory(null),
                  );
                }
                final cat = _categories[index - 1];
                return _CategoryCard(
                  name: cat['name'] ?? 'Category',
                  imageUrl: cat['image'] ?? '',
                  isSelected: cat['_id'] == _selectedCategoryId,
                  onTap: () => _selectCategory(cat['_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    final categoryName = _selectedCategoryId == null
        ? 'All Exercises'
        : _categories.firstWhere(
            (c) => c['_id'] == _selectedCategoryId,
            orElse: () => {'name': 'Exercises'},
          )['name'];

    final displayExercises = _filteredExercises;
    final showingFiltered = _searchQuery.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showingFiltered ? 'Search Results' : categoryName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              '${displayExercises.length} found',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadingExercises)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
            ),
          )
        else if (displayExercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.search_off, color: Colors.grey.shade300, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    showingFiltered
                        ? 'No matching exercises'
                        : 'No exercises found',
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                  ),
                  if (!showingFiltered) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Add exercises in Admin Panel',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          ...displayExercises.map((ex) {
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
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.imageUrl,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF0F3)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: const Color(0xFFAA3D50), width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          icon ?? Icons.fitness_center,
                          color: isSelected
                              ? const Color(0xFFAA3D50)
                              : Colors.grey,
                          size: 28,
                        ),
                      )
                    : Icon(
                        icon ?? Icons.fitness_center,
                        color: isSelected
                            ? const Color(0xFFAA3D50)
                            : Colors.grey,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF5B0C23)
                    : Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFFAA3D50),
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFFAA3D50),
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        duration,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        difficulty[0].toUpperCase() + difficulty.substring(1),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
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
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
