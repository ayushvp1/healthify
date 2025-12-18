import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

/// Exercise Detail Screen - Shows details of a specific exercise
/// Receives exercise data as arguments via Navigator
class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isVideoLoading = false;
  Map<String, dynamic>? _exercise;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exercise == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _exercise =
          args ??
          {
            'title': 'Exercise',
            'description': 'No description available',
            'instructions': '',
            'duration': 30,
            'difficulty': 'beginner',
            'image': '',
            'gif': '',
            'video': '',
            'category': {'name': 'General'},
          };
      // Debug: Check what data is received
      debugPrint('=== Exercise Detail Screen ===');
      debugPrint('Title: ${_exercise!['title']}');
      debugPrint('Video URL: "${_exercise!['video'] ?? 'NULL'}"');
      debugPrint('Image URL: "${_exercise!['image'] ?? 'NULL'}"');
      _initializeVideo();
    }
  }

  void _initializeVideo() async {
    final videoUrl = _exercise?['video'] ?? '';
    debugPrint('Attempting to load video: $videoUrl');

    if (videoUrl.isNotEmpty) {
      // Mark that we're loading video
      setState(() {
        _isVideoLoading = true;
      });

      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );

        // Increase timeout for mobile networks
        await _videoController!.initialize().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('Video initialization timed out after 30 seconds');
            throw Exception('Video load timeout');
          },
        );

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isVideoLoading = false;
          });
          debugPrint('Video initialized successfully');
        }
      } catch (e) {
        debugPrint('Video initialization failed: $e');
        // Dispose controller and fall back to image
        _videoController?.dispose();
        _videoController = null;
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
            _isVideoLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _isVideoPlaying = false;
        } else {
          _videoController!.play();
          _isVideoPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = _exercise!['title'] ?? 'Exercise';
    final description = _exercise!['description'] ?? 'No description available';
    final instructions = _exercise!['instructions'] ?? '';
    final duration = _exercise!['duration'] ?? 30;
    final difficulty = _exercise!['difficulty'] ?? 'beginner';
    final categoryName = _exercise!['category']?['name'] ?? 'General';
    final gifUrl = _exercise!['gif'] ?? '';
    final imageUrl = _exercise!['image'] ?? '';
    final videoUrl = _exercise!['video'] ?? '';
    final hasVideo = videoUrl.isNotEmpty;
    final visualUrl = gifUrl.isNotEmpty ? gifUrl : imageUrl;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.grey100,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video or Image/GIF - show image if video failed to load
              if (hasVideo && _isVideoInitialized && _videoController != null)
                _buildVideoPlayer()
              else if (hasVideo && _isVideoLoading)
                _buildVideoLoading(visualUrl)
              else
                _buildIllustration(visualUrl),
              const SizedBox(height: 20),

              // Title and Category
              _buildTitle(title, categoryName),
              const SizedBox(height: 24),

              // Stats Card
              _buildStatsCard(duration, difficulty),
              const SizedBox(height: 24),

              // Description
              if (description.isNotEmpty) ...[
                _buildDescriptionCard(description),
                const SizedBox(height: 24),
              ],

              // How to do it (Instructions)
              if (instructions.isNotEmpty) ...[
                _buildHowToSection(instructions),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 80), // Space for bottom button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildStartButton(context, _exercise!),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            // Play/Pause overlay
            GestureDetector(
              onTap: _toggleVideo,
              child: Container(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: _isVideoPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLoading(String imageUrl) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show image as background while video loads
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          // Loading overlay
          Container(
            decoration: BoxDecoration(
              color: AppTheme.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.white),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(String imageUrl) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: AppTheme.highlightPink,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.accentColor,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppTheme.accentColor,
                    );
                  },
                )
              : const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppTheme.accentColor,
                ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightPinkBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            categoryName,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.darkRedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int duration, String difficulty) {
    String difficultyLabel =
        difficulty[0].toUpperCase() + difficulty.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DetailStat(
            icon: Icons.access_time_filled_rounded,
            value: '${duration}s',
            label: 'Duration',
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _DetailStat(
            icon: Icons.local_fire_department_rounded,
            value: '${(duration * 0.1).round()} cal',
            label: 'Calories',
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _DetailStat(
            icon: Icons.fitness_center_rounded,
            value: difficultyLabel,
            label: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.grey700,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection(String instructions) {
    // Split instructions by newlines or numbered list patterns
    final steps = instructions
        .split(RegExp(r'\n|\d+\.\s*'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to do it',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 16),
        if (steps.isEmpty)
          Text(
            instructions,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.grey800,
              height: 1.5,
            ),
          )
        else
          ...steps.asMap().entries.map(
            (entry) =>
                _HowToStep(index: entry.key + 1, text: entry.value.trim()),
          ),
      ],
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/player', arguments: exercise);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: AppTheme.white,
            size: 28,
          ),
          label: Text(
            'Start Exercise',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.darkGreen, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HowToStep extends StatelessWidget {
  final int index;
  final String text;

  const _HowToStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.darkGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.grey800,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
