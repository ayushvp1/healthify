import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/exercise_bundle_service.dart';
import '../../providers/auth_provider.dart';

class BundlesListScreen extends ConsumerStatefulWidget {
  const BundlesListScreen({super.key});

  @override
  ConsumerState<BundlesListScreen> createState() => _BundlesListScreenState();
}

class _BundlesListScreenState extends ConsumerState<BundlesListScreen> {
  bool _loading = true;
  List<ExerciseBundle> _bundles = [];
  String? _error;
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ExerciseBundleService(token);
      final response = await service.getBundles(
        limit: 50,
        difficulty: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
      );

      if (mounted) {
        setState(() {
          _bundles = response.bundles;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Workout Programs',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Difficulty Filter
          _buildDifficultyFilter(),

          // Content
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
                  )
                : _error != null
                ? _buildError()
                : _bundles.isEmpty
                ? _buildEmpty()
                : _buildBundlesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedDifficulty == 'all',
              onTap: () {
                setState(() => _selectedDifficulty = 'all');
                _loadBundles();
              },
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Beginner',
              isSelected: _selectedDifficulty == 'beginner',
              onTap: () {
                setState(() => _selectedDifficulty = 'beginner');
                _loadBundles();
              },
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Intermediate',
              isSelected: _selectedDifficulty == 'intermediate',
              onTap: () {
                setState(() => _selectedDifficulty = 'intermediate');
                _loadBundles();
              },
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Advanced',
              isSelected: _selectedDifficulty == 'advanced',
              onTap: () {
                setState(() => _selectedDifficulty = 'advanced');
                _loadBundles();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlesList() {
    return RefreshIndicator(
      onRefresh: _loadBundles,
      color: const Color(0xFFAA3D50),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bundles.length,
        itemBuilder: (context, index) {
          final bundle = _bundles[index];
          return _BundleCard(
            bundle: bundle,
            onTap: () {
              Navigator.pushNamed(context, '/bundle/${bundle.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            Text(
              'Failed to load programs',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBundles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA3D50),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, color: Colors.grey.shade300, size: 80),
            const SizedBox(height: 16),
            Text(
              'No programs available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new workout programs!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B0C23) : const Color(0xFFFFF5F6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B0C23)
                : const Color(0xFFE8B4BD),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF5B0C23),
          ),
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final ExerciseBundle bundle;
  final VoidCallback onTap;

  const _BundleCard({required this.bundle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Header
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: _getDifficultyGradient(bundle.difficulty),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: bundle.thumbnail.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            bundle.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                // Difficulty Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bundle.difficultyDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Days Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAA3D50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bundle.totalDays} Days',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (bundle.description.isNotEmpty)
                    Text(
                      bundle.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.fitness_center,
                        label: '${bundle.totalExercises} exercises',
                      ),
                      const SizedBox(width: 12),
                      if (bundle.category != null)
                        _InfoPill(
                          icon: Icons.category_outlined,
                          label: bundle.category!.name,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDifficultyGradient(bundle.difficulty),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center, color: Colors.white54, size: 48),
      ),
    );
  }

  List<Color> _getDifficultyGradient(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case 'intermediate':
        return [const Color(0xFFAA3D50), const Color(0xFFD46A7A)];
      case 'advanced':
        return [const Color(0xFF5B0C23), const Color(0xFFAA3D50)];
      default:
        return [const Color(0xFFAA3D50), const Color(0xFFD46A7A)];
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFAA3D50)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5B0C23),
            ),
          ),
        ],
      ),
    );
  }
}
