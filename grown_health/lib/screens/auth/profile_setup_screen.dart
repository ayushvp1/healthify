import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Step 1 fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;

  // Step 2 selection
  String? _selectedGoal;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      // Validate first page before proceeding
      if (_currentPage == 0) {
        final name = _nameController.text.trim();
        final age = _ageController.text.trim();
        final weight = _weightController.text.trim();

        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your name')),
          );
          return;
        }
        if (age.isEmpty || int.tryParse(age) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid age')),
          );
          return;
        }
        if (weight.isEmpty || double.tryParse(weight) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid weight')),
          );
          return;
        }
        if (_selectedGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your gender')),
          );
          return;
        }
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Last page, complete profile and go to home
      _completeProfileAndGoHome();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
    final gender = _mapGenderToBackend(_selectedGender);

    setState(() => _isLoading = true);

    try {
      // Call the profile API if we have a token
      if (token != null && token.isNotEmpty) {
        debugPrint('📡 Calling profile/complete API...');
        final profileService = ProfileService(token);
        await profileService.completeProfile(
          name: name.isNotEmpty ? name : 'User',
          age: age,
          gender: gender,
          weight: weight,
        );
        debugPrint('✅ Profile completed on backend');
      }

      // Also save locally as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (name.isNotEmpty) {
        await prefs.setString('userName', name);
      }

      // Save profile data locally for fallback
      final profileData = {
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight,
        'isProfileComplete': true,
        'profileCompleted': true,
      };
      await prefs.setString('profile_data_$userEmail', jsonEncode(profileData));
      debugPrint('💾 Profile saved locally for $userEmail');

      // Update auth state to mark profile as complete
      ref.read(authProvider.notifier).setProfileCompleted(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile setup complete!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } catch (e) {
      debugPrint('❌ Profile completion error: $e');

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show error but still allow proceeding (save locally)
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profile Sync Issue'),
          content: Text(
            'Could not save profile to server: $errorMsg\n\n'
            'Your profile will be saved locally. Would you like to continue?',
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
        // Save locally and proceed
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
          'isProfileComplete': true,
          'profileCompleted': true,
        };
        await prefs.setString(
          'profile_data_$userEmail',
          jsonEncode(profileData),
        );

        // Update auth state to mark profile as complete
        ref.read(authProvider.notifier).setProfileCompleted(true);

        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      }
    }
  }

  Future<void> _skipAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select gender',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Male'),
                onTap: () {
                  setState(() => _selectedGender = 'Male');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  setState(() => _selectedGender = 'Female');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Prefer not to say'),
                onTap: () {
                  setState(() => _selectedGender = 'Prefer not to say');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back, progress, skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: _currentPage > 0 ? _prevPage : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA3D50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFAA3D50),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skip button
                  GestureDetector(
                    onTap: _isLoading ? null : _skipAndGoHome,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _isLoading ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [_buildStep1(), _buildStep2()],
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA3D50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage < _totalPages - 1 ? 'Next' : 'Finish',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            'Tell me more',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'About Yourself',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildInputField(
            controller: _nameController,
            hint: 'Enter your name',
            label: 'Your Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _ageController,
            hint: 'Enter your age',
            label: 'Your Age',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showGenderPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedGender ?? 'Select gender',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: _selectedGender != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    'Your Gender',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _weightController,
            hint: 'Enter weight (kg)',
            label: 'Your Weight',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final goals = [
      {'id': 'fit', 'label': 'Get fit', 'icon': Icons.fitness_center_rounded},
      {'id': 'active', 'label': 'Be Active', 'icon': Icons.favorite_rounded},
      {
        'id': 'health',
        'label': 'Be Health',
        'icon': Icons.health_and_safety_rounded,
      },
      {'id': 'balance', 'label': 'Find Balance', 'icon': Icons.balance_rounded},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            "what's Your main goal?",
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: goals.map((goal) {
              final isSelected = _selectedGoal == goal['id'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedGoal = goal['id'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFAA3D50)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        goal['icon'] as IconData,
                        size: 40,
                        color: const Color(0xFFAA3D50),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        goal['label'] as String,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
