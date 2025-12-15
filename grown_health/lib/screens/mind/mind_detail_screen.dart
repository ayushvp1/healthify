import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/core.dart';
import '../../providers/providers.dart';
import '../../services/meditation_service.dart';

/// Meditation detail screen that fetches meditation by ID from backend.
class MindDetailScreen extends ConsumerStatefulWidget {
  final String? meditationId;

  const MindDetailScreen({super.key, this.meditationId});

  @override
  ConsumerState<MindDetailScreen> createState() => _MindDetailScreenState();
}

class _MindDetailScreenState extends ConsumerState<MindDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _meditation;

  @override
  void initState() {
    super.initState();
    if (widget.meditationId != null) {
      _loadMeditation();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadMeditation() async {
    final token = ref.read(authProvider).user?.token;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = MeditationService(token);
      final response = await service.getMeditationById(widget.meditationId!);

      if (mounted) {
        setState(() {
          _meditation = response['data'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load meditation';
          _isLoading = false;
        });
      }
    }
  }

  String get _title => _meditation?['title'] as String? ?? 'Meditation';
  String get _description =>
      _meditation?['description'] as String? ??
      'Find a comfortable position and focus on your breath.';
  int get _duration => _meditation?['duration'] as int? ?? 600;
  String get _difficulty => _meditation?['difficulty'] as String? ?? 'Beginner';
  String? get _categoryName {
    final category = _meditation?['category'];
    if (category is Map<String, dynamic>) {
      return category['name'] as String?;
    }
    return null;
  }

  String? get _videoUrl => _meditation?['videoUrl'] as String?;
  String? get _audioUrl => _meditation?['audioUrl'] as String?;
  List<String> get _benefits {
    final benefits = _meditation?['benefits'];
    if (benefits is List) {
      return benefits.map((e) => e.toString()).toList();
    }
    return ['stress relief', 'focus', 'calm', 'mental clarity'];
  }

  String? get _instructions => _meditation?['instructions'] as String?;

  String get _formattedDuration {
    final mins = (_duration / 60).floor();
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
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
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeditation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Main Illustration
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Left decorative line
                      Positioned(
                        left: 20,
                        child: Container(
                          width: 4,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Right decorative line
                      Positioned(
                        right: 20,
                        child: Container(
                          width: 4,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Main icon container
                      Container(
                        width: 200,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.self_improvement_rounded,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Instruction text
                Center(
                  child: Text(
                    _description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Chips row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_categoryName != null) _buildChip(_categoryName!),
                    if (_categoryName != null) const SizedBox(width: 8),
                    _buildChip(_difficulty, isSecondary: true),
                    if (_videoUrl != null) ...[
                      const SizedBox(width: 8),
                      _buildChip('Video', isVideo: true),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                // Stats row
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.timer_outlined,
                      title: _formattedDuration,
                      subtitle: 'Duration',
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.trending_up_rounded,
                      title: _difficulty,
                      subtitle: 'Level',
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.favorite_border_rounded,
                      title: '${_benefits.length}',
                      subtitle: 'Benefits',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // About section
                Text(
                  'About',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _description,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Benefits section
                Text(
                  'Benefits',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _benefits
                      .map((b) => _BenefitChip(label: b))
                      .toList(),
                ),
                if (_instructions != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _instructions!,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Bottom session bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_formattedDuration · ${_categoryName ?? 'Meditation'}',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _startMeditation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startMeditation() {
    // TODO: Implement meditation player (audio/video playback)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting meditation...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildChip(
    String label, {
    bool isSecondary = false,
    bool isVideo = false,
  }) {
    Color bgColor;
    Color textColor;

    if (isVideo) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
    } else if (isSecondary) {
      bgColor = const Color(0xFFE5F7E8);
      textColor = const Color(0xFF1E8842);
    } else {
      bgColor = AppTheme.primaryColor.withOpacity(0.1);
      textColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;

  const _BenefitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
