import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import '../../providers/auth_provider.dart';
import 'assessment_results_screen.dart';
import 'category_summary_screen.dart';

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
  bool _showIntro = false;
  bool _isShowingDashboard = true; // New state to show all 4 categories first

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
        _totalAnswered = 0;
        _answeredPerCategory = {
          'Body': 0,
          'Mind': 0,
          'Nutrition': 0,
          'Lifestyle': 0,
        };
        _isComplete = false;
        _isShowingDashboard = true;
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

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Body':
        return 'Let\'s assess your physical health, activity levels, and body awareness.';
      case 'Mind':
        return 'Focusing on your mental well-being, stress levels, and emotional balance.';
      case 'Nutrition':
        return 'Understanding your dietary habits, hydration, and fueling choices.';
      case 'Lifestyle':
        return 'Reviewing your sleep, work-life balance, and daily routines.';
      default:
        return 'Continuing your journey towards better health.';
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
      // Finished current category - show summary
      final completedCategory = _categories[_currentCategoryIndex];
      final isLastCategory = _currentCategoryIndex >= _categories.length - 1;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategorySummaryScreen(
            category: completedCategory,
            isLastCategory: isLastCategory,
            onContinue: () {
              if (!isLastCategory) {
                // Move to next category
                setState(() {
                  _currentCategoryIndex++;
                  _currentQuestionIndex = 0;
                  _selectedOption = null;
                  _showIntro = true;
                  _isShowingDashboard = false; // Keep in assessment mode
                });
              } else {
                // Return to dashboard but marked as complete
                setState(() {
                  _isShowingDashboard = true;
                  _selectedOption = null;
                });
              }
            },
          ),
        ),
      );
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

    if (_isShowingDashboard) {
      return _buildDashboard();
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

    final categoryColor = _getCategoryColor(currentCategory);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.black),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.white,
              categoryColor.withOpacity(0.05),
              categoryColor.withOpacity(0.12),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _showIntro
                ? _buildCategoryIntro(currentCategory)
                : _buildQuestionView(currentCategory, question, categoryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.grey600),
            onPressed: _showResetConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellness Journey',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete all 4 categories to see your overall health score.',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
            ),
            const SizedBox(height: 32),
            ...List.generate(_categories.length, (index) {
              final category = _categories[index];
              final color = _getCategoryColor(category);
              final icon = _getCategoryIcon(category);
              final desc = _getCategoryDescription(category);
              final answered = _answeredPerCategory[category] ?? 0;
              final total = _questionsByCategory[category]?.length ?? 0;
              final isDone = total > 0 && answered >= total;
              final progress = total > 0 ? answered / total : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentCategoryIndex = index;
                      _currentQuestionIndex = answered < total ? answered : 0;
                      _selectedOption = null;
                      _isShowingDashboard = false;
                      _showIntro =
                          answered == 0; // Show intro only for first time
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDone ? color : AppTheme.grey200,
                        width: isDone ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                  Text(
                                    isDone
                                        ? 'Completed'
                                        : '$answered/$total Questions',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDone ? color : AppTheme.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDone)
                              Icon(
                                Icons.check_circle_rounded,
                                color: color,
                                size: 28,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          desc,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.grey700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: color.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_totalAnswered > 0)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AssessmentResultsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('View Current Progress & Results'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIntro(String category) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final description = _getCategoryDescription(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
              child: Icon(icon, size: 60, color: color),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            category,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.grey700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => setState(() => _showIntro = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: color.withOpacity(0.4),
              ),
              child: Text(
                'Start Section',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(
    String currentCategory,
    _QuestionData question,
    Color categoryColor,
  ) {
    return Column(
      key: ValueKey('question_${question.id}'),
      children: [
        const SizedBox(height: 10),
        // Progress indicator removed as per user request
        const SizedBox(height: 10),
        // Top Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_categories.length, (index) {
              final category = _categories[index];
              final isCompleted =
                  (_answeredPerCategory[category] ?? 0) >=
                  (_questionsByCategory[category]?.length ?? 0);
              final totalQuestions =
                  _questionsByCategory[category]?.length ?? 0;

              return GestureDetector(
                onTap: () {
                  // Allow tapping on completed sections to view summary
                  if (isCompleted && totalQuestions > 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategorySummaryScreen(
                          category: category,
                          isLastCategory: index == _categories.length - 1,
                        ),
                      ),
                    );
                  } else if (index <= _currentCategoryIndex) {
                    // Allow navigating to current or previous sections
                    setState(() {
                      _currentCategoryIndex = index;
                      _currentQuestionIndex = 0;
                      _selectedOption = null;
                      _showIntro = true;
                    });
                  }
                },
                child: _TopTab(
                  label: category,
                  icon: _getCategoryIcon(category),
                  selected: _currentCategoryIndex == index,
                  completed: isCompleted && totalQuestions > 0,
                  color: _getCategoryColor(category),
                ),
              );
            }),
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
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(currentCategory),
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      question.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.body,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Options
                ...List.generate(question.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionButton(
                      label: question.options[index],
                      selected: _selectedOption == index,
                      activeColor: categoryColor,
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
                backgroundColor: categoryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: categoryColor.withOpacity(0.35),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: AppTheme.white)
                  : Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Assessment Completed!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap any section to view detailed results',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
            ),
            const SizedBox(height: 32),

            // Category Cards
            ...List.generate(_categories.length, (index) {
              final category = _categories[index];
              final color = _getCategoryColor(category);
              final icon = _getCategoryIcon(category);
              final answeredCount = _answeredPerCategory[category] ?? 0;
              final totalCount = _questionsByCategory[category]?.length ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategorySummaryScreen(
                          category: category,
                          isLastCategory: index == _categories.length - 1,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
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
                                category,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$answeredCount/$totalCount questions completed',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.grey600,
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
                            color: AppTheme.successColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.successColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Done',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // View Full Results Button
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
                label: const Text('View Full Results & Recommendations'),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 32),
          ],
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
    // Use category color for completed sections, show that they're tappable
    final displayColor = selected
        ? color
        : completed
        ? color.withOpacity(0.7)
        : AppTheme.grey400;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (selected || completed)
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: displayColor),
            ),
            if (completed)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.white, width: 2),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: displayColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
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
  final Color activeColor;

  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.05) : AppTheme.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? activeColor : AppTheme.grey300,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: activeColor.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: AppTheme.black.withOpacity(0.01),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? activeColor : AppTheme.black87,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: activeColor, size: 18),
          ],
        ),
      ),
    );
  }
}
