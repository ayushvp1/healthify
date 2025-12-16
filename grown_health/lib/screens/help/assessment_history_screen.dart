import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_config.dart';
import '../../providers/auth_provider.dart';
import 'assessment_results_screen.dart';

/// Shows the user's assessment history - their answered questions grouped by category
class AssessmentHistoryScreen extends ConsumerStatefulWidget {
  const AssessmentHistoryScreen({super.key});

  @override
  ConsumerState<AssessmentHistoryScreen> createState() =>
      _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState
    extends ConsumerState<AssessmentHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _progressData;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(authProvider).user?.token;
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/health-assessment/my-progress',
      );
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _progressData = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Body':
        return const Color(0xFF8E44AD);
      case 'Mind':
        return const Color(0xFF3498DB);
      case 'Nutrition':
        return const Color(0xFF1ABC9C);
      case 'Lifestyle':
        return const Color(0xFFF39C12);
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
          'Assessment History',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.insights_rounded,
              color: AppTheme.primaryColor,
            ),
            tooltip: 'View Results',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AssessmentResultsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _error != null
          ? _buildErrorState()
          : _buildHistoryContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: AppTheme.grey400),
            const SizedBox(height: 24),
            Text(
              'No History Found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Complete the health assessment to see your history.',
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

  Widget _buildHistoryContent() {
    if (_progressData == null) {
      return _buildErrorState();
    }

    final answers = _progressData!['answers'] as List<dynamic>? ?? [];
    final categoryProgress =
        _progressData!['categoryProgress'] as List<dynamic>? ?? [];
    final isComplete = _progressData!['isComplete'] ?? false;

    // Group answers by category (we'll need to infer from questionText or use a different approach)
    // For now, let's display the overall progress and answers list

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isComplete
                    ? [
                        AppTheme.successColor,
                        AppTheme.successColor.withOpacity(0.8),
                      ]
                    : [
                        AppTheme.warningColor,
                        AppTheme.warningColor.withOpacity(0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete ? Icons.check_circle : Icons.pending,
                    color: AppTheme.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Assessment Complete' : 'In Progress',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${answers.length} questions answered',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Category Progress
          Text(
            'Category Progress',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),

          ...categoryProgress.map((cp) {
            final category = cp['category'] as String? ?? 'Unknown';
            final total = cp['totalQuestions'] as int? ?? 0;
            final answered = cp['answeredQuestions'] as int? ?? 0;
            final complete = cp['isComplete'] ?? false;
            final color = _getCategoryColor(category);
            final icon = _getCategoryIcon(category);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: complete ? color.withOpacity(0.5) : AppTheme.grey200,
                ),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black87,
                              ),
                            ),
                            if (complete) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppTheme.successColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: total > 0 ? answered / total : 0,
                            backgroundColor: AppTheme.grey200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$answered/$total',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Your Answers
          if (answers.isNotEmpty) ...[
            Text(
              'Your Answers',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            ...answers.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              final questionText =
                  answer['questionText'] ?? 'Question ${index + 1}';
              final selectedText = answer['selectedOptionText'] ?? 'No answer';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            questionText,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
