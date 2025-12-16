import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import '../../providers/auth_provider.dart';
import 'assessment_results_screen.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  int _currentCategoryIndex = 0;
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  bool _isComplete = false;
  int _totalAnswered = 0;

  final List<String> _categories = ['Body', 'Mind', 'Nutrition', 'Lifestyle'];
  Map<String, List<_QuestionData>> _questionsByCategory = {};
  Map<String, int> _answeredPerCategory = {};

  @override
  void initState() {
    super.initState();
    _loadQuestionsAndProgress();
  }

  /// Load questions and user's existing progress
  Future<void> _loadQuestionsAndProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load questions
      final questionsUri = Uri.parse(
        '${ApiConfig.baseUrl}/health-assessment/questions',
      );
      final questionsRes = await http.get(questionsUri);

      if (questionsRes.statusCode != 200) {
        throw Exception('Failed to load questions');
      }

      final questionsData = jsonDecode(questionsRes.body);
      final groupedData = questionsData['data'] as Map<String, dynamic>;

      final Map<String, List<_QuestionData>> loadedQuestions = {};
      groupedData.forEach((category, questionsList) {
        loadedQuestions[category] = (questionsList as List).map((q) {
          return _QuestionData(
            id: q['_id'],
            title: 'Question ${q['questionNumber']}',
            body: q['questionText'],
            options: List<String>.from(q['options']),
          );
        }).toList();
      });

      // Load user's progress
      final token = ref.read(authProvider).user?.token;
      Map<String, int> answeredCounts = {
        'Body': 0,
        'Mind': 0,
        'Nutrition': 0,
        'Lifestyle': 0,
      };
      bool hasProgress = false;
      bool isComplete = false;
      int totalAnswered = 0;

      if (token != null) {
        try {
          final progressUri = Uri.parse(
            '${ApiConfig.baseUrl}/health-assessment/my-progress',
          );
          final progressRes = await http.get(
            progressUri,
            headers: {'Authorization': 'Bearer $token'},
          );

          if (progressRes.statusCode == 200) {
            final progressData = jsonDecode(progressRes.body);
            final assessment = progressData['data'];

            if (assessment != null) {
              isComplete = assessment['isComplete'] ?? false;

              if (assessment['categoryProgress'] != null) {
                for (var cp in assessment['categoryProgress']) {
                  final cat = cp['category'] as String?;
                  final answered = cp['answeredQuestions'] as int? ?? 0;
                  if (cat != null) {
                    answeredCounts[cat] = answered;
                    totalAnswered += answered;
                  }
                }
              }

              hasProgress = totalAnswered > 0;
            }
          }
        } catch (e) {
          debugPrint('Failed to load progress: $e');
        }
      }

      if (mounted) {
        setState(() {
          _questionsByCategory = loadedQuestions;
          _answeredPerCategory = answeredCounts;
          _isComplete = isComplete;
          _totalAnswered = totalAnswered;
          _isLoading = false;
        });

        // Auto-resume: find the first unanswered question
        if (hasProgress && !isComplete) {
          _resumeFromProgress(loadedQuestions, answeredCounts);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load assessment. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  /// Resume from the first unanswered category/question
  void _resumeFromProgress(
    Map<String, List<_QuestionData>> questions,
    Map<String, int> answered,
  ) {
    for (int i = 0; i < _categories.length; i++) {
      final cat = _categories[i];
      final totalInCategory = questions[cat]?.length ?? 0;
      final answeredInCategory = answered[cat] ?? 0;

      if (answeredInCategory < totalInCategory) {
        setState(() {
          _currentCategoryIndex = i;
          _currentQuestionIndex = answeredInCategory;
          _selectedOption = null;
        });
        return;
      }
    }
  }

  /// Reset assessment and start fresh
  Future<void> _resetAssessment() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health-assessment/reset');
      await http.delete(uri, headers: {'Authorization': 'Bearer $token'});

      // Reset all local state
      setState(() {
        _currentCategoryIndex = 0;
        _currentQuestionIndex = 0;
        _selectedOption = null;
        _isComplete = false;
        _totalAnswered = 0;
        _answeredPerCategory = {
          'Body': 0,
          'Mind': 0,
          'Nutrition': 0,
          'Lifestyle': 0,
        };
      });

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Assessment reset. Start fresh!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to reset assessment');
      }
    }
  }

  Future<void> _submitAnswer(String questionId, int optionIndex) async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health-assessment/answer');
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'questionId': questionId,
          'selectedOption': optionIndex,
        }),
      );

      // Update local progress tracking
      final currentCategory = _categories[_currentCategoryIndex];
      _answeredPerCategory[currentCategory] =
          (_answeredPerCategory[currentCategory] ?? 0) + 1;
      _totalAnswered++;
    } catch (e) {
      debugPrint('Error saving answer: $e');
    }
  }

  Future<void> _goNext() async {
    if (_selectedOption == null) {
      SnackBarUtils.showWarning(
        context,
        'Please select an answer before continuing.',
        duration: const Duration(seconds: 1),
      );
      return;
    }

    final currentCategory = _categories[_currentCategoryIndex];
    final currentQuestions = _questionsByCategory[currentCategory];

    if (currentQuestions == null || currentQuestions.isEmpty) {
      _moveToNextCategory();
      return;
    }

    final currentQuestion = currentQuestions[_currentQuestionIndex];

    setState(() => _isSubmitting = true);

    // Submit answer to backend
    await _submitAnswer(currentQuestion.id, _selectedOption!);

    setState(() => _isSubmitting = false);

    if (_currentQuestionIndex < currentQuestions.length - 1) {
      // Next question in same category
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      // Finished current category
      if (_currentCategoryIndex < _categories.length - 1) {
        // Move to next category
        _showCategoryCompletionDialog(_categories[_currentCategoryIndex + 1]);
      } else {
        // Finished all categories
        _showFinalCompletionDialog();
      }
    }
  }

  void _moveToNextCategory() {
    if (_currentCategoryIndex < _categories.length - 1) {
      setState(() {
        _currentCategoryIndex++;
        _currentQuestionIndex = 0;
        _selectedOption = null;
      });
    } else {
      _showFinalCompletionDialog();
    }
  }

  void _showCategoryCompletionDialog(String nextCategory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Section Completed!'),
          ],
        ),
        content: Text('Great job! Moving on to the $nextCategory assessment.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentCategoryIndex++;
                _currentQuestionIndex = 0;
                _selectedOption = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalCompletionDialog() {
    setState(() => _isComplete = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.celebration,
                color: AppTheme.successColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Assessment Complete!'),
          ],
        ),
        content: const Text(
          'Your health assessment has been saved. View your personalized health score and recommendations.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AssessmentResultsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Results',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restart Assessment?'),
        content: const Text(
          'This will clear all your previous answers. You will need to complete the assessment again from the beginning.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetAssessment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              TextButton(
                onPressed: _loadQuestionsAndProgress,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show completion screen if already complete
    if (_isComplete) {
      return _buildCompletedScreen();
    }

    final currentCategory = _categories[_currentCategoryIndex];
    final currentQuestions = _questionsByCategory[currentCategory] ?? [];

    if (currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Assessment')),
        body: Center(child: Text('No questions for $currentCategory')),
      );
    }

    final question = currentQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppTheme.black),
        title: Text(
          'Health Assessment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.grey600),
            onSelected: (value) {
              if (value == 'results') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AssessmentResultsScreen(),
                  ),
                );
              } else if (value == 'reset') {
                _showResetConfirmation();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'results',
                child: Row(
                  children: [
                    Icon(Icons.insights_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('View Results'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Restart',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            // Top Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopTab(
                    label: 'Body',
                    icon: Icons.fitness_center_rounded,
                    selected: _currentCategoryIndex == 0,
                    completed:
                        (_answeredPerCategory['Body'] ?? 0) >=
                        (_questionsByCategory['Body']?.length ?? 0),
                    color: AppTheme.primaryColor,
                  ),
                  _TopTab(
                    label: 'Mind',
                    icon: Icons.psychology_rounded,
                    selected: _currentCategoryIndex == 1,
                    completed:
                        (_answeredPerCategory['Mind'] ?? 0) >=
                        (_questionsByCategory['Mind']?.length ?? 0),
                    color: AppTheme.primaryColor,
                  ),
                  _TopTab(
                    label: 'Nutrition',
                    icon: Icons.restaurant_menu_rounded,
                    selected: _currentCategoryIndex == 2,
                    completed:
                        (_answeredPerCategory['Nutrition'] ?? 0) >=
                        (_questionsByCategory['Nutrition']?.length ?? 0),
                    color: AppTheme.primaryColor,
                  ),
                  _TopTab(
                    label: 'Lifestyle',
                    icon: Icons.spa_rounded,
                    selected: _currentCategoryIndex == 3,
                    completed:
                        (_answeredPerCategory['Lifestyle'] ?? 0) >=
                        (_questionsByCategory['Lifestyle']?.length ?? 0),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_outlined,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          question.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      question.body,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Options
                    ...List.generate(question.options.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _OptionButton(
                          label: question.options[index],
                          selected: _selectedOption == index,
                          onTap: () => setState(() => _selectedOption = index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: AppTheme.white)
                      : Text(
                          'Next',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
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

  Widget _buildProgressIndicator() {
    final totalQuestions = _questionsByCategory.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final progress = totalQuestions > 0 ? _totalAnswered / totalQuestions : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey600,
                ),
              ),
              Text(
                '$_totalAnswered / $totalQuestions',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppTheme.black),
        title: Text(
          'Health Assessment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Assessment Completed!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have already completed the health assessment. View your results or retake the assessment.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AssessmentResultsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('View My Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showResetConfirmation,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retake Assessment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionData {
  final String id;
  final String title;
  final String body;
  final List<String> options;

  const _QuestionData({
    required this.id,
    required this.title,
    required this.body,
    required this.options,
  });
}

class _TopTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool completed;
  final Color color;

  const _TopTab({
    required this.label,
    required this.icon,
    this.selected = false,
    this.completed = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Icon(
              icon,
              size: 28,
              color: selected
                  ? color
                  : completed
                  ? AppTheme.successColor
                  : AppTheme.grey400,
            ),
            if (completed)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: AppTheme.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? color
                : completed
                ? AppTheme.successColor
                : AppTheme.grey400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: selected ? color : AppTheme.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.grey300,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: AppTheme.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
