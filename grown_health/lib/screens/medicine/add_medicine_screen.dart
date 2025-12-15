import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _frequency = 'DAILY';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'frequency': _frequency,
      'time': _time,
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Add New Medicine',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Medicine Name',
                icon: Icons.medication_outlined,
                controller: _nameController,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter medicine name'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Dosage',
                icon: Icons.local_drink_outlined,
                controller: _dosageController,
              ),
              const SizedBox(height: 16),
              _buildFrequencyField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimeCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStartDateCard()),
                ],
              ),
              const SizedBox(height: 12),
              _buildEndDateCard(),
              const SizedBox(height: 16),
              _buildInstructionsField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA3D50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Add Medicine',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8BFC8)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFAA3D50)),
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8BFC8)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _frequency,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Frequency',
        ),
        items: const [
          DropdownMenuItem(value: 'DAILY', child: Text('DAILY')),
          DropdownMenuItem(value: 'WEEKLY', child: Text('WEEKLY')),
          DropdownMenuItem(value: 'MONTHLY', child: Text('MONTHLY')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _frequency = value);
          }
        },
      ),
    );
  }

  Widget _buildTimeCard() {
    return GestureDetector(
      onTap: _pickTime,
      child: _InfoCard(
        icon: Icons.access_time,
        title: 'Time',
        value: _formatTime(_time),
      ),
    );
  }

  Widget _buildStartDateCard() {
    return GestureDetector(
      onTap: _pickStartDate,
      child: _InfoCard(
        icon: Icons.calendar_today_outlined,
        title: 'Start Date',
        value: _formatDate(_startDate),
      ),
    );
  }

  Widget _buildEndDateCard() {
    return GestureDetector(
      onTap: _pickEndDate,
      child: _InfoCard(
        icon: Icons.calendar_today_outlined,
        title: 'End Date (Optional)',
        value: _endDate == null ? 'Not set' : _formatDate(_endDate!),
      ),
    );
  }

  Widget _buildInstructionsField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8BFC8)),
      ),
      child: TextFormField(
        controller: _instructionsController,
        maxLines: 3,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.info_outline, color: Color(0xFFAA3D50)),
          hintText: 'Instructions',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFAA3D50)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    );
  }
}
