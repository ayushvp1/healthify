import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/exercise_bundle_service.dart';
import '../../providers/auth_provider.dart';

class InitialWorkoutSelectionScreen extends ConsumerStatefulWidget {
  const InitialWorkoutSelectionScreen({super.key});

  @override
  ConsumerState<InitialWorkoutSelectionScreen> createState() => _InitialWorkoutSelectionScreenState();
}

class _InitialWorkoutSelectionScreenState extends ConsumerState<InitialWorkoutSelectionScreen> {
  bool _loading = true;
  List<ExerciseBundle> _bundles = [];
  String? _error;

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
      final response = await service.getBundles(limit: 6); // Just get a few recommendations

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

  Future<void> _startProgram(String bundleId) async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
    );

    try {
      final service = ExerciseBundleService(token);
      await service.startWorkout(programId: bundleId, day: 1);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        SnackBarUtils.showError(context, 'Failed to start program: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick your first workout program',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plan that fits your goals and we\'ll set up your daily tasks.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.grey500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                  : _error != null
                      ? _buildError()
                      : _buildBundlesGrid(),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                child: Text(
                  'I\'ll choose later',
                  style: GoogleFonts.inter(
                    color: AppTheme.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _bundles.length,
      itemBuilder: (context, index) {
        final bundle = _bundles[index];
        return _SelectedBundleCard(
          bundle: bundle,
          onTap: () => _startProgram(bundle.id),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.grey400, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          TextButton(onPressed: _loadBundles, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SelectedBundleCard extends StatelessWidget {
  final ExerciseBundle bundle;
  final VoidCallback onTap;

  const _SelectedBundleCard({required this.bundle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                image: bundle.thumbnail.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(bundle.thumbnail),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppTheme.cardBackground,
              ),
              child: bundle.thumbnail.isEmpty
                  ? const Icon(Icons.fitness_center, color: AppTheme.grey400)
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bundle.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bundle.totalDays} Days • ${bundle.difficultyDisplay}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Start Now',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
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
