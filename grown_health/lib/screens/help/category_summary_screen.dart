import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/core.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_config.dart';
import '../../providers/auth_provider.dart';

/// Screen to display summary after completing a category section
class CategorySummaryScreen extends ConsumerStatefulWidget {
  final String category;
  final VoidCallback? onContinue;
  final bool isLastCategory;

  const CategorySummaryScreen({
    super.key,
    required this.category,
    this.onContinue,
    this.isLastCategory = false,
  });

  @override
  ConsumerState<CategorySummaryScreen> createState() =>
      _CategorySummaryScreenState();
}

class _CategorySummaryScreenState extends ConsumerState<CategorySummaryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _categoryData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    _loadCategoryResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token;
      if (token == null) {
        throw Exception('Please login to view results');
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/health-assessment/results/category/${widget.category}',
      );

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _categoryData = data['data'];
            _isLoading = false;
          });
          _animationController.forward();
        }
      } else {
        throw Exception('Failed to load category results');
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

  Color _getCategoryColor() {
    switch (widget.category) {
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

  IconData _getCategoryIcon() {
    switch (widget.category) {
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

  String _getCategoryDescription() {
    switch (widget.category) {
      case 'Body':
        return 'Physical fitness, exercise habits, and body wellness';
      case 'Mind':
        return 'Mental health, stress levels, and emotional wellbeing';
      case 'Nutrition':
        return 'Eating habits, diet quality, and hydration';
      case 'Lifestyle':
        return 'Sleep patterns, daily routines, and healthy habits';
      default:
        return 'Your health assessment results';
    }
  }

  String _getLevelText(int percentage) {
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  Color _getLevelColor(int percentage) {
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 60) return AppTheme.green400;
    if (percentage >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getMotivationMessage(int percentage) {
    if (percentage >= 80) {
      return 'Amazing! You\'re doing great in this area. Keep up the excellent work!';
    }
    if (percentage >= 60) {
      return 'Good progress! A few small improvements can make a big difference.';
    }
    if (percentage >= 40) {
      return 'You\'re on the right track. Focus on building better habits step by step.';
    }
    return 'This is a great opportunity for growth. Small changes lead to big results!';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildContent(categoryColor),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _getCategoryColor()),
          const SizedBox(height: 24),
          Text(
            'Calculating your ${widget.category} score...',
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load results',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategoryResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getCategoryColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color categoryColor) {
    final score = _categoryData?['score'] ?? {};
    final percentage = score['percentage'] ?? 0;
    final recommendation = _categoryData?['recommendation'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.category} Assessment',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.black,
                          ),
                        ),
                        Text(
                          'Section Complete!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Score Card
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor,
                              categoryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.category} Score',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CircularPercentIndicator(
                              radius: 80,
                              lineWidth: 12,
                              percent: percentage / 100,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: GoogleFonts.inter(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  Text(
                                    _getLevelText(percentage),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _getLevelColor(percentage),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.white.withOpacity(0.2),
                              progressColor: _getLevelColor(percentage),
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                              animationDuration: 1200,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${score['answeredCount'] ?? 0} Questions Answered',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category Description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: categoryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About ${widget.category}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCategoryDescription(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.grey700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Motivation Message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getLevelColor(percentage).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getLevelColor(percentage).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            percentage >= 60
                                ? Icons.emoji_emotions_rounded
                                : Icons.lightbulb_outline_rounded,
                            color: _getLevelColor(percentage),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getMotivationMessage(percentage),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.grey800,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recommendation (if available)
                    if (recommendation != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.tips_and_updates_rounded,
                                    color: categoryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recommendation['title'] ?? 'Recommendation',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(
                                      recommendation['priority'] ?? 'low',
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (recommendation['priority'] ?? 'low')
                                        .toString()
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _getPriorityColor(
                                        recommendation['priority'] ?? 'low',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              recommendation['description'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.grey700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.onContinue != null) {
                          Navigator.pop(context);
                          widget.onContinue!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        widget.isLastCategory
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppTheme.white,
                      ),
                      label: Text(
                        widget.isLastCategory
                            ? 'View Full Results'
                            : 'Continue to Next Section',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isLastCategory
                            ? AppTheme.successColor
                            : categoryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (!widget.isLastCategory) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Take a break & continue later',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
