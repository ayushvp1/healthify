import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  State<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen> {
  final List<Map<String, dynamic>> _medicines = [];
  String _searchQuery = '';

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
          'Medicine Reminders',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            if (_medicines.isEmpty)
              _buildEmptyState()
            else
              _buildMedicineList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAA3D50),

        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/add_medicine');
          if (!context.mounted) return;

          if (result is Map<String, dynamic>) {
            setState(() {
              _medicines.add(result);
            });

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Medicine added successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search medicine',
        prefixIcon: const Icon(Icons.search, color: Color(0xFFAA3D50)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : const Icon(Icons.close, color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFFCE4E8),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_box_outlined,
                size: 20,
                color: Color(0xFFAA3D50),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'No medicine reminders found',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicineList() {
    final filtered = _searchQuery.isEmpty
        ? _medicines
        : _medicines
              .where(
                (m) => (m['name'] as String? ?? '').toLowerCase().contains(
                  _searchQuery,
                ),
              )
              .toList();

    if (filtered.isEmpty) {
      return _buildNoResults();
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final medicine = filtered[index];
          return _MedicineCard(
            medicine: medicine,
            onEdit: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed('/add_medicine', arguments: medicine);
              if (result is Map<String, dynamic>) {
                setState(() {
                  final originalIndex = _medicines.indexOf(medicine);
                  if (originalIndex != -1) {
                    _medicines[originalIndex] = result;
                  }
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medicine updated successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onDelete: () {
              setState(() {
                _medicines.remove(medicine);
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicine deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Text(
        'No medicines match your search',
        style: GoogleFonts.inter(
          textStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = medicine['name'] as String? ?? '';
    final dosage = medicine['dosage'] as String? ?? '';
    final instructions = medicine['instructions'] as String? ?? '';
    final time = medicine['time'];

    String timeLabel;
    if (time is TimeOfDay) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      timeLabel = '$h:$m';
    } else {
      timeLabel = '';
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: Color(0xFFAA3D50)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFAA3D50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dosage.isNotEmpty
                      ? '$dosage${instructions.isNotEmpty ? ', ' : ''}$instructions'
                      : instructions,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
