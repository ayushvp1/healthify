import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Ayush';
  String _age = '23 years';
  String _gender = 'Male';
  String _weight = '90 kg';
  String _goal = 'Get fit';
  String _cholesterol = 'Not set';
  String _bloodSugar = 'Not set';
  String _bloodPressure = 'Not set';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() => _userName = savedName);
    } else {
      // Save the default name so HomeScreen can read it
      await prefs.setString('userName', _userName);
    }

    final savedAge = prefs.getString('userAge');
    final savedGender = prefs.getString('userGender');
    final savedWeight = prefs.getString('userWeight');
    final savedGoal = prefs.getString('userGoal');
    final savedChol = prefs.getString('userCholesterol');
    final savedSugar = prefs.getString('userBloodSugar');
    final savedBp = prefs.getString('userBloodPressure');

    setState(() {
      if (savedAge != null && savedAge.isNotEmpty) _age = savedAge;
      if (savedGender != null && savedGender.isNotEmpty) _gender = savedGender;
      if (savedWeight != null && savedWeight.isNotEmpty) _weight = savedWeight;
      if (savedGoal != null && savedGoal.isNotEmpty) _goal = savedGoal;
      if (savedChol != null && savedChol.isNotEmpty) _cholesterol = savedChol;
      if (savedSugar != null && savedSugar.isNotEmpty) _bloodSugar = savedSugar;
      if (savedBp != null && savedBp.isNotEmpty) _bloodPressure = savedBp;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('userAge');
    await prefs.remove('userGender');
    await prefs.remove('userWeight');
    await prefs.remove('userGoal');
    await prefs.remove('userCholesterol');
    await prefs.remove('userBloodSugar');
    await prefs.remove('userBloodPressure');

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 50,
                color: Color(0xFFAA3D50),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              _userName,
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
              'avpdoppler@gmail.com',
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
            _buildMetricRow(Icons.cake_outlined, 'Age', _age),
            _buildMetricRow(Icons.person_outline_rounded, 'Gender', _gender),
            _buildMetricRow(Icons.fitness_center_rounded, 'Weight', _weight),
            _buildMetricRow(Icons.flag_outlined, 'Goal', _goal),
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
    final ageController = TextEditingController(text: _age);
    final genderController = TextEditingController(text: _gender);
    final weightController = TextEditingController(text: _weight);
    final goalController = TextEditingController(text: _goal);

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
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Goal'),
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
      setState(() {
        _age = ageController.text.trim().isEmpty
            ? _age
            : ageController.text.trim();
        _gender = genderController.text.trim().isEmpty
            ? _gender
            : genderController.text.trim();
        _weight = weightController.text.trim().isEmpty
            ? _weight
            : weightController.text.trim();
        _goal = goalController.text.trim().isEmpty
            ? _goal
            : goalController.text.trim();
      });

      await prefs.setString('userAge', _age);
      await prefs.setString('userGender', _gender);
      await prefs.setString('userWeight', _weight);
      await prefs.setString('userGoal', _goal);
    }
  }

  Future<void> _showEditHealthMetricsDialog() async {
    final cholController = TextEditingController(text: _cholesterol);
    final sugarController = TextEditingController(text: _bloodSugar);
    final bpController = TextEditingController(text: _bloodPressure);

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
                TextField(
                  controller: sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Sugar - Fasting (e.g. 95 mg/dL)',
                  ),
                ),
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
      setState(() {
        _cholesterol = cholController.text.trim().isEmpty
            ? _cholesterol
            : cholController.text.trim();
        _bloodSugar = sugarController.text.trim().isEmpty
            ? _bloodSugar
            : sugarController.text.trim();
        _bloodPressure = bpController.text.trim().isEmpty
            ? _bloodPressure
            : bpController.text.trim();
      });

      await prefs.setString('userCholesterol', _cholesterol);
      await prefs.setString('userBloodSugar', _bloodSugar);
      await prefs.setString('userBloodPressure', _bloodPressure);
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
