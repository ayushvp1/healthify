import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grown_health/widgets/widgets.dart';

import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from auth provider if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = ref.read(authProvider).user?.name;
      if (name != null && name.isNotEmpty) {
        _nameController.text = name;
      }
    });
  }

  // Step 1 fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedGender;

  // Validation state
  Map<String, String> validationErrors = {};
  bool showErrors = false;

  // Step 2 selection
  int _selectedGoalIndex = -1;

  final List<Map<String, dynamic>> _goals = [
    {'id': 'fit', 'label': 'Get Fit', 'icon': Icons.fitness_center_rounded},
    {'id': 'active', 'label': 'Be Active', 'icon': Icons.favorite_rounded},
    {
      'id': 'health',
      'label': 'Be Healthy',
      'icon': Icons.health_and_safety_rounded,
    },
    {'id': 'balance', 'label': 'Find Balance', 'icon': Icons.balance_rounded},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    setState(() {
      validationErrors.clear();
      showErrors = false;
    });

    // Name validation
    if (_nameController.text.trim().isEmpty) {
      validationErrors['name'] = 'Please enter your name';
    } else if (_nameController.text.trim().length < 2) {
      validationErrors['name'] = 'Name must be at least 2 characters';
    }

    // Age validation
    if (_ageController.text.trim().isEmpty) {
      validationErrors['age'] = 'Please enter your age';
    } else {
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 13 || age > 120) {
        validationErrors['age'] = 'Please enter a valid age (13-120)';
      }
    }

    // Gender validation
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      validationErrors['gender'] = 'Please select your gender';
    }

    // Weight validation
    if (_weightController.text.trim().isEmpty) {
      validationErrors['weight'] = 'Please enter your weight';
    } else {
      final weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight < 20 || weight > 300) {
        validationErrors['weight'] = 'Please enter a valid weight (20-300 kg)';
      }
    }

    // Height validation
    if (_heightController.text.trim().isEmpty) {
      validationErrors['height'] = 'Please enter your height';
    } else {
      final height = double.tryParse(_heightController.text.trim());
      if (height == null || height < 50 || height > 250) {
        validationErrors['height'] = 'Please enter a valid height (50-250 cm)';
      }
    }

    if (validationErrors.isNotEmpty) {
      setState(() {
        showErrors = true;
      });
      return false;
    }

    return true;
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      if (_currentPage == 0 && !_validateStep1()) {
        return;
      }
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      if (_selectedGoalIndex == -1) {
        SnackBarUtils.showWarning(context, 'Please select a goal to continue');
        return;
      }
      _completeProfileAndGoHome();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  String _mapGenderToBackend(String? gender) {
    if (gender == null) return 'other';
    switch (gender.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'prefer not to say':
        return 'other';
      default:
        return 'other';
    }
  }

  Future<void> _completeProfileAndGoHome() async {
    final token = ref.read(authProvider).user?.token;
    final userEmail = ref.read(authProvider).user?.email ?? '';

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 25;
    final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
    final height = double.tryParse(_heightController.text.trim());
    final gender = _mapGenderToBackend(_selectedGender);

    String? fitnessGoal;
    if (_selectedGoalIndex >= 0 && _selectedGoalIndex < _goals.length) {
      fitnessGoal = _goals[_selectedGoalIndex]['label'] as String;
    }

    setState(() => _isLoading = true);

    try {
      if (token != null && token.isNotEmpty) {
        final profileService = ProfileService(token);
        await profileService.completeProfile(
          name: name.isNotEmpty ? name : 'User',
          age: age,
          gender: gender,
          weight: weight,
          height: height,
          fitnessGoal: fitnessGoal,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (name.isNotEmpty) {
        await prefs.setString('userName', name);
      }

      final profileData = {
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight,
        'height': height,
        'fitnessGoal': fitnessGoal,
        'isProfileComplete': true,
        'profileCompleted': true,
      };
      await prefs.setString('profile_data_$userEmail', jsonEncode(profileData));

      ref
          .read(authProvider.notifier)
          .updateUser(name: name, profileCompleted: true);

      if (!mounted) return;

      SnackBarUtils.showSuccess(context, 'Profile setup complete!');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Profile Sync Issue'),
          content: Text(
            'Could not save profile to server: $errorMsg\n\n'
            'Your profile will be saved locally. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue Anyway'),
            ),
          ],
        ),
      );

      if (shouldProceed == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        if (name.isNotEmpty) {
          await prefs.setString('userName', name);
        }

        final profileData = {
          'name': name,
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          'fitnessGoal': fitnessGoal,
          'isProfileComplete': true,
          'profileCompleted': true,
        };
        await prefs.setString(
          'profile_data_$userEmail',
          jsonEncode(profileData),
        );

        ref
            .read(authProvider.notifier)
            .updateUser(name: name, profileCompleted: true);

        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      }
    }
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Text(
                  'Select gender',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ),
              _buildGenderOption('Male'),
              _buildGenderOption('Female'),
              _buildGenderOption('Prefer not to say'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String gender) {
    return ListTile(
      onTap: () {
        setState(() => _selectedGender = gender);
        if (showErrors && validationErrors.containsKey('gender')) {
          validationErrors.remove('gender');
          if (validationErrors.isEmpty) showErrors = false;
        }
        Navigator.pop(context);
      },
      title: Text(
        gender,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppTheme.black87,
        ),
      ),
      trailing: _selectedGender == gender
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.accentColor)
          : null,
    );
  }

  Future<void> _skipAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: CustomProgressBar(
                value: (_currentPage + 1) / _totalPages,
                showBack: _currentPage > 0,
                onBack: _prevPage,
                onSkip: _isLoading ? null : _skipAndGoHome,
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [_buildStep1(), _buildStep2()],
              ),
            ),

            // Bottom Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomButton(
        text: _currentPage < _totalPages - 1 ? 'Next' : 'Complete Setup',
        type: ButtonType.primary,
        isFullWidth: true,
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _nextPage,
        height: 52,
        backgroundColor: AppTheme.accentColor,
        textColor: AppTheme.white,
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            "Tell me more",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          Text(
            "About Yourself",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 40),

          // Gender Selector Card
          GestureDetector(
            onTap: _showGenderPicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
                border: showErrors && validationErrors.containsKey('gender')
                    ? Border.all(color: AppTheme.errorColor, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: showErrors && validationErrors.containsKey('gender')
                        ? AppTheme.errorColor.withValues(alpha: 0.1)
                        : AppTheme.grey300.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedGender ?? 'Select Gender',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: _selectedGender != null
                            ? AppTheme.black
                            : AppTheme.grey400,
                      ),
                    ),
                  ),
                  Text(
                    'Your Gender',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Name Field
          _buildBoxedTextField(
            controller: _nameController,
            hint: 'Enter your name',
            label: 'Your Name',
            hasError: showErrors && validationErrors.containsKey('name'),
          ),

          // Age Field
          _buildBoxedTextField(
            controller: _ageController,
            hint: 'Enter your age',
            label: 'Your Age',
            keyboardType: TextInputType.number,
            hasError: showErrors && validationErrors.containsKey('age'),
          ),

          // Weight Field
          _buildBoxedTextField(
            controller: _weightController,
            hint: 'Enter weight (kg)',
            label: 'Your Weight',
            keyboardType: TextInputType.number,
            hasError: showErrors && validationErrors.containsKey('weight'),
          ),

          // Height Field
          _buildBoxedTextField(
            controller: _heightController,
            hint: 'Enter height (cm)',
            label: 'Your Height',
            keyboardType: TextInputType.number,
            hasError: showErrors && validationErrors.containsKey('height'),
          ),

          // Error Display
          if (showErrors && validationErrors.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppConstants.paddingMedium),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.red100,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.red700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Please fix the following errors:',
                        style: GoogleFonts.inter(
                          color: AppTheme.red700,
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...validationErrors.values.map(
                    (error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: AppTheme.red700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              error,
                              style: GoogleFonts.inter(
                                color: AppTheme.red700,
                                fontSize: AppConstants.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBoxedTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: hasError
            ? Border.all(color: AppTheme.errorColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: hasError
                ? AppTheme.errorColor.withValues(alpha: 0.1)
                : AppTheme.grey300.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 3,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (_) {
                if (showErrors) {
                  setState(() {
                    // Clear specific error when user starts typing
                  });
                }
              },
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: hasError ? AppTheme.red700 : AppTheme.black,
                fontSize: AppConstants.fontSizeMedium,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  color: hasError
                      ? AppTheme.errorColor.withValues(alpha: 0.5)
                      : AppTheme.grey400,
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeLarge,
                ),
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: hasError ? AppTheme.red700 : AppTheme.grey500,
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            "What's your",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          Text(
            "main goal?",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 40),

          // Goals Grid
          GridView.builder(
            itemCount: _goals.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final goal = _goals[index];
              return GoalCard(
                icon: goal['icon'] as IconData,
                label: goal['label'] as String,
                isSelected: _selectedGoalIndex == index,
                onTap: () => setState(() => _selectedGoalIndex = index),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
