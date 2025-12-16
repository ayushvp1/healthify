import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/health_metrics_service.dart';
import '../models/profile_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileModel? _profile;
  bool _loading = true;
  String? _error;

  // Health metrics from API
  String _cholesterol = 'Not set';
  String _bloodSugar = 'Not set';
  String _bloodPressure = 'Not set';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    try {
      final service = HealthMetricsService(token);
      final metrics = await service.getHealthMetrics();

      if (mounted) {
        setState(() {
          _cholesterol = metrics.cholesterolDisplay;
          _bloodSugar = metrics.bloodSugarDisplay;
          _bloodPressure = metrics.bloodPressureDisplay;
        });
      }
      debugPrint('✅ Health metrics loaded from API');
    } catch (e) {
      debugPrint('❌ Failed to load health metrics: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final userEmail = ref.read(authProvider).user?.email ?? '';

      if (mounted) {
        setState(() {
          _cholesterol =
              prefs.getString('${userEmail}_cholesterol') ?? 'Not set';
          _bloodSugar = prefs.getString('${userEmail}_bloodSugar') ?? 'Not set';
          _bloodPressure =
              prefs.getString('${userEmail}_bloodPressure') ?? 'Not set';
        });
      }
    }
  }

  Future<void> _saveProfileLocally(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = ref.read(authProvider).user?.email ?? '';
      if (userEmail.isEmpty) return;

      await prefs.setString('profile_data_$userEmail', jsonEncode(data));
      debugPrint('💾 Profile saved locally for $userEmail');
    } catch (e) {
      debugPrint('❌ Failed to save profile locally: $e');
    }
  }

  Future<ProfileModel?> _loadProfileLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = ref.read(authProvider).user?.email ?? '';
      if (userEmail.isEmpty) return null;

      final jsonStr = prefs.getString('profile_data_$userEmail');
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        debugPrint('💾 Loaded local profile for $userEmail');
        return ProfileModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('❌ Failed to load local profile: $e');
    }
    return null;
  }

  Future<void> _loadProfile() async {
    final token = ref.read(authProvider).user?.token;

    if (token == null) {
      setState(() {
        _error = 'Not logged in';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileService = ProfileService(token);
      final apiProfile = await profileService.getProfile();

      // Debug: Print what we received
      debugPrint('📱 API Profile loaded:');
      debugPrint('  Name: "${apiProfile.name}"');
      debugPrint('  Age: ${apiProfile.age}');

      // Check if API returned empty data (backend bug)
      ProfileModel finalProfile = apiProfile;

      if (apiProfile.age == null || apiProfile.weight == null) {
        debugPrint(
          '⚠️ API returned incomplete data. Checking local storage...',
        );
        final localProfile = await _loadProfileLocally();

        if (localProfile != null) {
          debugPrint('✅ Using local profile data as fallback');
          // Merge API data (like name/email) with local data (age/weight)
          finalProfile = apiProfile.copyWith(
            age: localProfile.age,
            gender: localProfile.gender,
            weight: localProfile.weight,
            height: localProfile.height,
            isProfileComplete: localProfile.isProfileComplete,
          );

          // If name is missing in API but present locally, use local
          if (finalProfile.name == null || finalProfile.name!.isEmpty) {
            finalProfile = finalProfile.copyWith(name: localProfile.name);
          }
        }
      }

      if (mounted) {
        setState(() {
          _profile = finalProfile;
          _loading = false;
          _error = null;
        });

        // Force another setState to ensure UI updates
        Future.microtask(() {
          if (mounted) {
            setState(() {});
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Profile error: $e');

      // Check if it's a "profile not found" error
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not found') || errorMsg.contains('404')) {
        // Profile doesn't exist - navigate to complete profile screen
        if (mounted) {
          final result = await Navigator.of(
            context,
          ).pushNamed('/profile-complete');
          if (result != null && result is Map<String, dynamic>) {
            // Profile was completed, save locally and reload
            await _saveProfileLocally(result);
            _loadProfile();
          } else {
            setState(() {
              _error = 'Profile not completed';
              _loading = false;
            });
          }
        }
      } else {
        // Try to load locally on error
        final localProfile = await _loadProfileLocally();
        if (localProfile != null && mounted) {
          setState(() {
            _profile = localProfile;
            _loading = false;
            _error = null;
          });
        } else if (mounted) {
          setState(() {
            _error = e.toString().replaceFirst('Exception: ', '');
            _loading = false;
          });
        }
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Use auth provider's logout which clears all data
    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(authProvider).user?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppTheme.black,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _buildProfileView(userEmail),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load profile',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => _loading = true);

    try {
      final token = ref.read(authProvider).user?.token;
      if (token == null) return;

      final uploadService = UploadService(token);
      debugPrint('📤 Uploading image...');
      final imageUrl = await uploadService.uploadImage(File(pickedFile.path));
      debugPrint('✅ Image uploaded: $imageUrl');

      final profileService = ProfileService(token);
      await profileService.updateProfileImage(imageUrl);
      debugPrint('✅ Profile updated with new image');

      _loadProfile(); // Reload to show new image
    } catch (e) {
      debugPrint('❌ Image upload failed: $e');
      if (mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to upload image: ${e.toString().replaceAll("Exception:", "")}',
        );
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildProfileView(String userEmail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Avatar
          // Avatar
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE4E8),
                    shape: BoxShape.circle,
                  ),
                  child: _profile?.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            _profile!.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 50,
                                  color: AppTheme.accentColor,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          size: 50,
                          color: AppTheme.accentColor,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: AppTheme.white, width: 2),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppTheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            _profile?.name != null && _profile!.name!.isNotEmpty
                ? _profile!.name!
                : userEmail.split('@').first, // Use email prefix if no name
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            userEmail,
            style: GoogleFonts.inter(
              textStyle: TextStyle(fontSize: 14, color: AppTheme.grey600),
            ),
          ),
          const SizedBox(height: 32),
          // Health Metrics Section
          _buildSectionHeader(
            'Health Metrics',
            editable: true,
            onEdit: _showEditHealthMetricsDialog,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            Icons.monitor_heart_outlined,
            'Cholesterol',
            _cholesterol,
          ),
          _buildMetricRow(
            Icons.water_drop_outlined,
            'Blood Sugar - Fasting',
            _bloodSugar,
          ),
          _buildMetricRow(
            Icons.favorite_outline_rounded,
            'Blood Pressure',
            _bloodPressure,
          ),
          const SizedBox(height: 24),
          // Personal Information Section
          _buildSectionHeader(
            'Personal Information',
            editable: true,
            onEdit: _showEditPersonalInfoDialog,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            Icons.cake_outlined,
            'Age',
            _profile?.age != null ? '${_profile!.age} years' : 'Not set',
          ),
          _buildMetricRow(
            Icons.person_outline_rounded,
            'Gender',
            _profile?.gender ?? 'Not set',
          ),
          _buildMetricRow(
            Icons.fitness_center_rounded,
            'Weight',
            _profile?.weight != null ? '${_profile!.weight} kg' : 'Not set',
          ),
          _buildMetricRow(
            Icons.height_rounded,
            'Height',
            _profile?.height != null ? '${_profile!.height} cm' : 'Not set',
          ),
          _buildMetricRow(
            Icons.flag_outlined,
            'Goal',
            _profile?.fitnessGoal ?? 'Not set',
          ),
          const SizedBox(height: 40),
          // Logout Button
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (editable && onEdit != null)
          InkWell(
            onTap: onEdit,
            child: Row(
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showEditPersonalInfoDialog() async {
    final ageController = TextEditingController(
      text: _profile?.age?.toString() ?? '',
    );
    final genderController = TextEditingController(
      text: _profile?.gender ?? '',
    );
    final weightController = TextEditingController(
      text: _profile?.weight?.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: _profile?.height?.toString() ?? '',
    );
    final goalController = TextEditingController(
      text: _profile?.fitnessGoal ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Personal Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Main Goal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _updateProfile(
        age: int.tryParse(ageController.text.trim()),
        gender: genderController.text.trim().isEmpty
            ? null
            : genderController.text.trim(),
        weight: double.tryParse(weightController.text.trim()),
        height: double.tryParse(heightController.text.trim()),
        fitnessGoal: goalController.text.trim(),
      );
    }
  }

  Future<void> _showEditHealthMetricsDialog() async {
    final cholController = TextEditingController(
      text: _cholesterol == 'Not set'
          ? ''
          : _cholesterol.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final sugarController = TextEditingController(
      text: _bloodSugar == 'Not set'
          ? ''
          : _bloodSugar.replaceAll(RegExp(r'[^0-9.]'), ''),
    );

    // Parse current BP
    String currentSystolic = '';
    String currentDiastolic = '';
    if (_bloodPressure != 'Not set' && _bloodPressure.contains('/')) {
      final parts = _bloodPressure.split('/');
      if (parts.length == 2) {
        currentSystolic = parts[0].trim();
        currentDiastolic = parts[1].trim();
      }
    }

    final systolicController = TextEditingController(text: currentSystolic);
    final diastolicController = TextEditingController(text: currentDiastolic);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Health Metrics'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cholController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cholesterol (mg/dL)',
                    hintText: 'e.g. 180',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sugarController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Blood Sugar - Fasting (mg/dL)',
                    hintText: 'e.g. 95',
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blood Pressure (mmHg)',
                    style: TextStyle(fontSize: 12, color: AppTheme.grey500),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: systolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Systolic',
                          hintText: '120',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '/',
                        style: TextStyle(fontSize: 20, color: AppTheme.grey500),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                          hintText: '80',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final token = ref.read(authProvider).user?.token;
      final userEmail = ref.read(authProvider).user?.email ?? '';

      final newChol = cholController.text.trim();
      final newSugar = sugarController.text.trim();

      // Combine BP
      final sys = systolicController.text.trim();
      final dia = diastolicController.text.trim();
      String newBp = '';
      if (sys.isNotEmpty && dia.isNotEmpty) {
        newBp = '$sys/$dia';
      } else if (sys.isNotEmpty) {
        newBp = sys;
      }

      // Show loading
      if (mounted) {
        SnackBarUtils.showInfo(
          context,
          'Saving health metrics...',
          duration: const Duration(seconds: 2),
        );
      }

      try {
        // Save to API
        if (token != null) {
          final service = HealthMetricsService(token);
          final updatedMetrics = await service.updateHealthMetrics(
            cholesterol: newChol,
            bloodSugar: newSugar,
            bloodPressure: newBp,
          );

          if (mounted) {
            setState(() {
              _cholesterol = updatedMetrics.cholesterolDisplay;
              _bloodSugar = updatedMetrics.bloodSugarDisplay;
              _bloodPressure = updatedMetrics.bloodPressureDisplay;
            });
          }
          debugPrint('✅ Health metrics saved to API');
        }

        // Also save locally as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          '${userEmail}_cholesterol',
          newChol.isEmpty ? 'Not set' : newChol,
        );
        await prefs.setString(
          '${userEmail}_bloodSugar',
          newSugar.isEmpty ? 'Not set' : newSugar,
        );
        await prefs.setString(
          '${userEmail}_bloodPressure',
          newBp.isEmpty ? 'Not set' : newBp,
        );

        if (mounted) {
          SnackBarUtils.hide(context);
          SnackBarUtils.showSuccess(context, 'Health metrics updated!');
        }
      } catch (e) {
        debugPrint('❌ Failed to save health metrics: $e');

        // Still update UI with local values
        if (mounted) {
          setState(() {
            _cholesterol = newChol.isEmpty ? 'Not set' : newChol;
            _bloodSugar = newSugar.isEmpty ? 'Not set' : newSugar;
            _bloodPressure = newBp.isEmpty ? 'Not set' : newBp;
          });

          // Save locally anyway
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('${userEmail}_cholesterol', _cholesterol);
          await prefs.setString('${userEmail}_bloodSugar', _bloodSugar);
          await prefs.setString('${userEmail}_bloodPressure', _bloodPressure);

          if (!mounted) return;
          SnackBarUtils.hide(context);
          SnackBarUtils.showWarning(
            context,
            'Saved locally (Offline)',
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  Future<void> _updateProfile({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessGoal,
  }) async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    setState(() => _loading = true);

    try {
      final profileService = ProfileService(token);
      await profileService.updateProfile(
        name: name,
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        fitnessGoal: fitnessGoal,
      );

      debugPrint('✅ Profile update sent to backend');

      // Save locally to workaround backend bug
      final updatedData = {
        'name': name ?? _profile?.name,
        'age': age ?? _profile?.age,
        'gender': gender ?? _profile?.gender,
        'weight': weight ?? _profile?.weight,
        'height': height ?? _profile?.height,
        'fitnessGoal': fitnessGoal ?? _profile?.fitnessGoal,
        'isProfileComplete': true,
      };
      await _saveProfileLocally(updatedData);
      debugPrint('💾 Profile update saved locally');

      // Reload using hybrid loader
      await _loadProfile();

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      debugPrint('❌ Profile update failed: $e');
      if (mounted) {
        setState(() => _loading = false);
        SnackBarUtils.showError(
          context,
          'Failed to update: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  Widget _buildMetricRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.accentColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(fontSize: 12, color: AppTheme.grey500),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
