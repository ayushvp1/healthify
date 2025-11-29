import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _questionIndex = 0;
  int? _selectedOption;

  final List<_QuestionData> _questions = const [
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
    _QuestionData(
      title: 'Question 3',
      body: 'What is your current activity level?',
      options: ['Sedentary', 'Lightly Active', 'Active', 'Very Active'],
    ),
    _QuestionData(
      title: 'Question 4',
      body: 'What type of workouts do you prefer?',
      options: ['Bodyweight', 'Weights', 'Cardio', 'Mix of all'],
    ),
  ];

  void _goNext() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
      });
    } else {
      // Later: navigate to summary or recommendations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment completed (demo).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_questionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Health Assessment',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Top mini tabs (Body, Mind, Nutrition, Lifestyle)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _TopTab(
                    label: 'Body',
                    icon: Icons.fitness_center_rounded,
                    selected: true,
                  ),
                  _TopTab(label: 'Mind', icon: Icons.self_improvement_rounded),
                  _TopTab(label: 'Nutrition', icon: Icons.rice_bowl_outlined),
                  _TopTab(label: 'Lifestyle', icon: Icons.bedtime_outlined),
                ],
              ),
              const SizedBox(height: 16),
              // Single question card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 18,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            question.title,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.body,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < question.options.length; i++) ...[
                        _OptionButton(
                          label: question.options[i],
                          selected: _selectedOption == i,
                          onTap: () {
                            setState(() => _selectedOption = i);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAA3D50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            _questionIndex < _questions.length - 1
                                ? 'Next'
                                : 'Finish',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
  final IconData icon;
  final bool selected;

  const _TopTab({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFAA3D50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: selected ? activeColor : Colors.grey.shade400,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? activeColor : Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // underline for selected tab
        Container(
          width: 40,
          height: 2,
          color: selected ? activeColor : Colors.transparent,
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
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFAA3D50) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFAA3D50) : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
