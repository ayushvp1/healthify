import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/core.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../providers/auth_provider.dart';
import '../../services/health_assessment_service.dart';
import '../../services/gemini_service.dart';
import 'assessment_history_screen.dart';

class AssessmentResultsScreen extends ConsumerStatefulWidget {
  const AssessmentResultsScreen({super.key});

  @override
  ConsumerState<AssessmentResultsScreen> createState() =>
      _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState
    extends ConsumerState<AssessmentResultsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  AssessmentResults? _results;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _aiAnalysis;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateAIAnalysis() async {
    if (_results == null) return;

    setState(() {
      _isAnalyzing = true;
      _aiAnalysis = null;
    });

    try {
      final categoryScores = <String, int>{};
      for (var score in _results!.categoryScores) {
        categoryScores[score.category] = score.percentage;
      }

      final recommendations = _results!.recommendations
          .map(
            (r) => {
              'category': r.category,
              'title': r.title,
              'description': r.description,
            },
          )
          .toList();

      final analysis = await GeminiService.analyzeHealthAssessment(
        scores: categoryScores,
        recommendations: recommendations,
        totalAnswered: _results!.totalQuestionsAnswered,
      );

      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        SnackBarUtils.showError(context, 'Failed to generate AI analysis');
      }
    }
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token;
      final service = HealthAssessmentService(token);
      final results = await service.getResults();

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return AppTheme.successColor;
      case 'good':
        return AppTheme.green400;
      case 'fair':
        return AppTheme.warningColor;
      case 'needs improvement':
        return AppTheme.errorColor;
      default:
        return AppTheme.grey500;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Body':
        return const Color(0xFF8E44AD); // Purple
      case 'Mind':
        return const Color(0xFF3498DB); // Blue
      case 'Nutrition':
        return const Color(0xFF1ABC9C); // Teal
      case 'Lifestyle':
        return const Color(0xFFF39C12); // Orange
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Body':
        return Icons.fitness_center_rounded;
      case 'Mind':
        return Icons.psychology_rounded;
      case 'Nutrition':
        return Icons.restaurant_menu_rounded;
      case 'Lifestyle':
        return Icons.spa_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  IconData _getRecommendationIcon(String icon) {
    switch (icon) {
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'restaurant':
        return Icons.restaurant_menu_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return AppTheme.errorColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'low':
        return AppTheme.successColor;
      default:
        return AppTheme.grey500;
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
        leading: const BackButton(color: AppTheme.black),
        title: Text(
          'Your Health Score',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _error != null
          ? _buildErrorState()
          : _buildResultsContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppTheme.grey400),
            const SizedBox(height: 24),
            Text(
              'No Assessment Found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Please complete the health assessment first.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Take Assessment',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    final results = _results!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            _buildOverallScoreCard(results.overallScore),
            const SizedBox(height: 24),

            // Category Breakdown
            Text(
              'Category Breakdown',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryScores(results.categoryScores),
            const SizedBox(height: 32),

            // Recommendations
            Text(
              'Personalized Recommendations',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendations(results.recommendations),
            const SizedBox(height: 32),

            // AI Insights
            _buildAIInsightsSection(),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(OverallScore score) {
    final levelColor = _getLevelColor(score.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Health Score',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.white70,
            ),
          ),
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: score.percentage / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.percentage}%',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  score.level,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.white.withOpacity(0.2),
            progressColor: levelColor,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_results!.totalQuestionsAnswered} Questions Answered',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScores(List<CategoryScore> scores) {
    return Column(
      children: scores.map((score) {
        final color = _getCategoryColor(score.category);
        final icon = _getCategoryIcon(score.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey200),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score.category,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score.percentage / 100,
                        backgroundColor: AppTheme.grey200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${score.percentage}%',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${score.answeredCount} Q',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations(List<HealthRecommendation> recommendations) {
    return Column(
      children: recommendations.map((rec) {
        final priorityColor = _getPriorityColor(rec.priority);
        final icon = _getRecommendationIcon(rec.icon);
        final categoryColor = _getCategoryColor(rec.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: priorityColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: priorityColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: categoryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rec.category,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rec.priority.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                rec.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.grey700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // View History Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AssessmentHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
            label: Text(
              'View My Answers',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.grey700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: AppTheme.grey400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Retake Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Retake Assessment?'),
                  content: const Text(
                    'This will reset your current assessment. You will need to answer all questions again.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  final token = ref.read(authProvider).user?.token;
                  final service = HealthAssessmentService(token);
                  await service.resetAssessment();

                  if (mounted) {
                    SnackBarUtils.showSuccess(
                      context,
                      'Assessment reset. You can retake it now.',
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    SnackBarUtils.showError(
                      context,
                      'Failed to reset assessment',
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Retake Assessment',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Health Insight',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  Text(
                    'Powered by Gemini AI',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_aiAnalysis == null) ...[
            Text(
              'Want a deeper dive? Let our AI analyze your results to provide a comprehensive, personalized wellness report.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.grey700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _generateAIAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isAnalyzing
                      ? 'Analyzing Results...'
                      : 'Generate AI Deep Dive',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            _MarkdownContent(text: _aiAnalysis!),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _generateAIAnalysis,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Regenerate Analysis'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.grey600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  final String text;

  const _MarkdownContent({required this.text});

  @override
  Widget build(BuildContext context) {
    // Simple parser for bullet points and bolding
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        bool isHeading =
            line.startsWith('#') || line.contains(':') && !line.startsWith('-');
        bool isBullet =
            line.trim().startsWith('-') || line.trim().startsWith('*');

        String cleanText = line.replaceAll('#', '').replaceAll('*', '').trim();

        if (isHeading) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              cleanText,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBullet)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  isBullet ? cleanText.substring(1).trim() : cleanText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.grey800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
