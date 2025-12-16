import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import '../../providers/auth_provider.dart';

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
  String? _error;

  final List<String> _categories = ['Body', 'Mind', 'Nutrition', 'Lifestyle'];
  Map<String, List<_QuestionData>> _questionsByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health-assessment/questions');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final groupedData = data['data'] as Map<String, dynamic>;

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

        if (mounted) {
          setState(() {
            _questionsByCategory = loadedQuestions;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load questions');
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
    } catch (e) {
      debugPrint('Error saving answer: $e');
      // Continue anyway for better UX, or show error?
      // Choosing to continue for smoother flow, could queue offline
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
      // Should not happen if API works, but safe fallback
      _moveToNextCategory();
      return;
    }

    final currentQuestion = currentQuestions[_currentQuestionIndex];

    // Submit answer to backend
    await _submitAnswer(currentQuestion.id, _selectedOption!);

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
        title: const Text('Section Completed!'),
        content: Text('Moving on to the $nextCategory assessment.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentCategoryIndex++;
                _currentQuestionIndex = 0;
                _selectedOption = null;
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showFinalCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Assessment Complete!'),
        content: const Text('Your health assessment has been saved.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to where they came from
              SnackBarUtils.showSuccess(
                context,
                'Assessment saved successfully!',
              );
            },
            child: const Text('Done'),
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
              TextButton(onPressed: _loadQuestions, child: const Text('Retry')),
            ],
          ),
        ),
      );
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
    const maroonColor = AppTheme.primaryColor;

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
      body: SafeArea(
        child: Column(
          children: [
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
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Mind',
                    icon: Icons.psychology_rounded,
                    selected: _currentCategoryIndex == 1,
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Nutrition',
                    icon: Icons.restaurant_menu_rounded,
                    selected: _currentCategoryIndex == 2,
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Lifestyle',
                    icon: Icons.spa_rounded,
                    selected: _currentCategoryIndex == 3,
                    color: maroonColor,
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
                          width:
                              48, // Slightly larger for better touch target/visual
                          height: 48,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE8F5E9,
                            ), // Keeping soft green background
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
                          question.title, // "Question 1"
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
                        fontSize: 20, // Larger for main question
                        fontWeight: FontWeight.w700, // Bolder
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
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
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
  final Color color;

  const _TopTab({
    required this.label,
    required this.icon,
    this.selected = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: selected ? color : AppTheme.grey400),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? color : AppTheme.grey400,
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
