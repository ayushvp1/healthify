import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _currentCategoryIndex = 0;
  int _currentQuestionIndex = 0;
  int? _selectedOption;

  final List<String> _categories = ['Body', 'Mind', 'Nutrition', 'Lifestyle'];

  // Define questions for each category
  final Map<String, List<_QuestionData>> _questionsByCategory = {
    'Body': [
      _QuestionData(
        title: 'Question 1',
        body: 'What is your primary fitness goal?',
        options: ['Weight Loss', 'Muscle Gain', 'General Health', 'Endurance'],
      ),
      _QuestionData(
        title: 'Question 2',
        body: 'How many days per week can you exercise?',
        options: ['1-2 days', '3-4 days', '5-6 days', 'Everyday'],
      ),
    ],
    'Mind': [
      _QuestionData(
        title: 'Question 1',
        body: 'How would you rate your daily stress levels?',
        options: ['Low', 'Moderate', 'High', 'Very High'],
      ),
      _QuestionData(
        title: 'Question 2',
        body: 'Do you practice meditation or mindfulness?',
        options: ['Daily', 'Sometimes', 'Rarely', 'Never'],
      ),
    ],
    'Nutrition': [
      _QuestionData(
        title: 'Question 1',
        body: 'How many meals do you eat per day?',
        options: ['2 meals', '3 meals', '4-5 meals', 'Irregular'],
      ),
      _QuestionData(
        title: 'Question 2',
        body: 'Do you follow any specific diet?',
        options: ['Vegan', 'Keto', 'Vegetarian', 'None'],
      ),
    ],
    'Lifestyle': [
      _QuestionData(
        title: 'Question 1',
        body: 'How many hours of sleep do you get?',
        options: ['Less than 5', '5-6 hours', '7-8 hours', 'More than 8'],
      ),
      _QuestionData(
        title: 'Question 2',
        body: 'Do you smoke or consume alcohol?',
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
      ),
    ],
  };

  void _goNext() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before continuing.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final currentCategory = _categories[_currentCategoryIndex];
    final currentQuestions = _questionsByCategory[currentCategory]!;

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
        content: const Text('Assessment is completed for now.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog only
              // Do NOT close the screen, just stay here so user sees the message.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assessment is completed for now.'),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = _categories[_currentCategoryIndex];
    final currentQuestions = _questionsByCategory[currentCategory]!;
    final question = currentQuestions[_currentQuestionIndex];
    const maroonColor = Color(0xFF5B0C23);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Health Assessment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
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
                    iconPath: 'assets/images/icon_body.png',
                    selected: _currentCategoryIndex == 0,
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Mind',
                    iconPath: 'assets/images/icon_mind.png',
                    selected: _currentCategoryIndex == 1,
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Nutrition',
                    iconPath: 'assets/images/icon_nutrition.png',
                    selected: _currentCategoryIndex == 2,
                    color: maroonColor,
                  ),
                  _TopTab(
                    label: 'Lifestyle',
                    iconPath: 'assets/images/icon_lifestyle.png',
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
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // Light Green
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/icon_body.png',
                            color: const Color(0xFF2E7D32), // Dark Green
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          question.title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      question.body,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: Colors.black,
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
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
  final String title;
  final String body;
  final List<String> options;

  const _QuestionData({
    required this.title,
    required this.body,
    required this.options,
  });
}

class _TopTab extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool selected;
  final Color color;

  const _TopTab({
    required this.label,
    required this.iconPath,
    this.selected = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 28,
          height: 28,
          color: selected ? color : Colors.grey.shade400,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? color : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF5B0C23) : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF5B0C23),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
