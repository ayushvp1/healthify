import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileModel? _profile;
  bool _loading = true;
  String? _error;
  
  // Health metrics (not in Profile API, stored locally)
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
    final prefs = await SharedPreferences.getInstance();
    final userEmail = ref.read(authProvider).user?.email ?? '';
    
    setState(() {
      _cholesterol = prefs.getString('${userEmail}_cholesterol') ?? 'Not set';
      _bloodSugar = prefs.getString('${userEmail}_bloodSugar') ?? 'Not set';
      _bloodPressure = prefs.getString('${userEmail}_bloodPressure') ?? 'Not set';
    });
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
      final profile = await profileService.getProfile();
      
      // Debug: Print what we received
      debugPrint('📱 Profile loaded:');
      debugPrint('  Name: ${profile.name}');
      debugPrint('  Email: ${profile.email}');
      debugPrint('  Age: ${profile.age}');
      debugPrint('  Gender: ${profile.gender}');
      debugPrint('  Weight: ${profile.weight}');
      debugPrint('  Height: ${profile.height}');
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('❌ Profile error: $e');
      
      // Check if it's a "profile not found" error
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not found') || errorMsg.contains('404')) {
        // Profile doesn't exist - navigate to complete profile screen
        if (mounted) {
          final completed = await Navigator.of(context).pushNamed('/profile-complete');
          if (completed == true) {
            // Profile was completed, reload
            _loadProfile();
          } else {
            setState(() {
              _error = 'Profile not completed';
              _loading = false;
            });
          }
        }
      } else {
        if (mounted) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
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
              color: Colors.black,
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                backgroundColor: const Color(0xFFAA3D50),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(String userEmail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Avatar
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
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_outline_rounded,
                        size: 50,
                        color: Color(0xFFAA3D50),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: Color(0xFFAA3D50),
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
              textStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
            'Not set', // Not in Profile API
          ),
          const SizedBox(height: 40),
          // Logout Button
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA3D50),
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
                    color: Colors.white,
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
                  color: Color(0xFFAA3D50),
                ),
                const SizedBox(width: 4),
                Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFAA3D50),
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
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
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
      );
    }
  }

  Future<void> _showEditHealthMetricsDialog() async {
    final cholController = TextEditingController(text: _cholesterol == 'Not set' ? '' : _cholesterol);
    final sugarController = TextEditingController(text: _bloodSugar == 'Not set' ? '' : _bloodSugar);
    final bpController = TextEditingController(text: _bloodPressure == 'Not set' ? '' : _bloodPressure);

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
                  decoration: const InputDecoration(
                    labelText: 'Cholesterol (e.g. 180 mg/dL)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Sugar - Fasting (e.g. 95 mg/dL)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bpController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Pressure (e.g. 120/80)',
                  ),
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
      final prefs = await SharedPreferences.getInstance();
      final userEmail = ref.read(authProvider).user?.email ?? '';
      
      final newChol = cholController.text.trim().isEmpty ? 'Not set' : cholController.text.trim();
      final newSugar = sugarController.text.trim().isEmpty ? 'Not set' : sugarController.text.trim();
      final newBp = bpController.text.trim().isEmpty ? 'Not set' : bpController.text.trim();
      
      await prefs.setString('${userEmail}_cholesterol', newChol);
      await prefs.setString('${userEmail}_bloodSugar', newSugar);
      await prefs.setString('${userEmail}_bloodPressure', newBp);
      
      setState(() {
        _cholesterol = newChol;
        _bloodSugar = newSugar;
        _bloodPressure = newBp;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health metrics updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
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
      );

      debugPrint('✅ Profile update sent to backend');
      debugPrint('🔄 Reloading profile from API...');

      // Force clear current profile
      if (mounted) {
        setState(() {
          _profile = null;
          _loading = true;
        });
      }

      // Small delay to ensure backend is updated
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload the profile from API to get fresh data
      final freshProfile = await profileService.getProfile();
      
      debugPrint('📱 Fresh profile loaded:');
      debugPrint('  Name: ${freshProfile.name}');
      debugPrint('  Age: ${freshProfile.age}');
      debugPrint('  Gender: ${freshProfile.gender}');
      debugPrint('  Weight: ${freshProfile.weight}');
      debugPrint('  Height: ${freshProfile.height}');

      if (mounted) {
        setState(() {
          _profile = freshProfile;
          _loading = false;
          _error = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Profile update failed: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
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
            child: Icon(icon, size: 20, color: const Color(0xFFAA3D50)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
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
