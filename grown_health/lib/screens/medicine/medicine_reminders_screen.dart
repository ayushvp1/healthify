import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/widgets.dart';
import '../../services/medicine_service.dart';
import '../../providers/auth_provider.dart';

class MedicineRemindersScreen extends ConsumerStatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  ConsumerState<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState
    extends ConsumerState<MedicineRemindersScreen> {
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final token = ref.read(authProvider).user?.token;
      if (token != null) {
        final service = MedicineService(token);
        final meds = await service.getUserMedicines();
        if (mounted) {
          setState(() {
            _medicines = meds;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarUtils.showError(context, 'Failed to load medicines: $e');
      }
    }
  }

  Future<void> _addMedicine(Map<String, dynamic> result) async {
    try {
      final token = ref.read(authProvider).user?.token;
      if (token != null) {
        final service = MedicineService(token);
        final newMed = await service.addUserMedicine(result);
        setState(() {
          _medicines.add(newMed);
        });
        _persistLatest(result); // Keep local persistence for Home screen

        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            'Added! Reminders set for ${result['times']?.length ?? 1} time(s).',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to save to cloud: $e');
      }
    }
  }

  Future<void> _updateMedicine(
    String id,
    Map<String, dynamic> result,
    Map<String, dynamic> oldMedicine,
  ) async {
    try {
      final token = ref.read(authProvider).user?.token;
      if (token != null) {
        final service = MedicineService(token);
        final updatedMed = await service.updateUserMedicine(id, result);

        setState(() {
          final index = _medicines.indexOf(oldMedicine);
          if (index != -1) {
            _medicines[index] = updatedMed;
          }
        });

        _persistLatest(result); // Update local persistence

        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            'Medicine updated successfully!',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to update: $e');
      }
    }
  }

  Future<void> _deleteMedicine(String id, Map<String, dynamic> medicine) async {
    try {
      final token = ref.read(authProvider).user?.token;
      if (token != null) {
        final service = MedicineService(token);
        await service.deleteUserMedicine(id);

        setState(() {
          _medicines.remove(medicine);
        });

        if (mounted) {
          SnackBarUtils.showInfo(
            context,
            'Medicine deleted',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to delete: $e');
      }
    }
  }

  Future<void> _persistLatest(Map<String, dynamic> result) async {
    // Persist for Home Screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latest_medicine_name', result['name']);

    String timeStr = '';
    if (result['times'] is List<TimeOfDay>) {
      final times = result['times'] as List<TimeOfDay>;
      if (times.isNotEmpty) {
        final t = times.first;
        final h = t.hour.toString().padLeft(2, '0');
        final m = t.minute.toString().padLeft(2, '0');
        timeStr = '$h:$m';
        if (times.length > 1) {
          timeStr += ' +${times.length - 1} more';
        }
      }
    } else if (result['time'] is TimeOfDay) {
      final t = result['time'] as TimeOfDay;
      final h = t.hour.toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      timeStr = '$h:$m';
    }
    await prefs.setString('latest_medicine_time', timeStr);
  }

  Future<void> _openAddMedicine() async {
    final result = await Navigator.of(context).pushNamed('/add_medicine');
    if (!context.mounted) return;

    if (result is Map<String, dynamic>) {
      await _addMedicine(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.black,
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
              color: AppTheme.black,
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
              Expanded(
                child: Center(
                  child: EmptyStateWidget(
                    icon: Icons.medication_rounded,
                    title: 'No medicine reminders found',
                    description:
                        'Keep track of your medications and never miss a dose.',
                    actionLabel: 'Add Medicine',
                    onAction: _openAddMedicine,
                  ),
                ),
              )
            else
              _buildMedicineList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: _openAddMedicine,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppTheme.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search medicine',
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.grey500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.grey500,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.grey500,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
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
          // Use _id from backend if available, otherwise fallback (should exist)
          final medId = medicine['_id'] ?? medicine['id'];

          return _MedicineCard(
            medicine: medicine,
            onEdit: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed('/add_medicine', arguments: medicine);

              if (result is Map<String, dynamic> && medId != null) {
                await _updateMedicine(medId, result, medicine);
              }
            },
            onDelete: () async {
              // Show confirmation dialog before deleting
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Delete Medicine',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${medicine['name']}"? This action cannot be undone.',
                    style: GoogleFonts.inter(color: AppTheme.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: AppTheme.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true && medId != null) {
                await _deleteMedicine(medId, medicine);
              }
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
          textStyle: const TextStyle(fontSize: 14, color: AppTheme.black54),
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
    final frequency = medicine['frequency'] as String? ?? 'daily';
    final times = medicine['times'];
    final legacyTime = medicine['time'];
    final reminderTimes = medicine['reminderTimes'];
    final isActive = medicine['isActive'] as bool? ?? true;

    // Parse reminder times
    List<String> timesList = [];
    if (reminderTimes is List && reminderTimes.isNotEmpty) {
      timesList = reminderTimes
          .map((rt) => rt['time'] as String? ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    } else if (times is List<TimeOfDay>) {
      timesList = times.map((t) {
        final h = t.hour.toString().padLeft(2, '0');
        final m = t.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }).toList();
    } else if (legacyTime is TimeOfDay) {
      final h = legacyTime.hour.toString().padLeft(2, '0');
      final m = legacyTime.minute.toString().padLeft(2, '0');
      timesList = ['$h:$m'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent strip on the left
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isActive
                        ? [
                            AppTheme.accentColor,
                            AppTheme.accentColor.withOpacity(0.6),
                          ]
                        : [AppTheme.grey400, AppTheme.grey300],
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine icon with gradient background
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.lightAccentBg,
                              AppTheme.lightAccentBg.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.medication_rounded,
                          color: AppTheme.accentColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medicine name with status indicator
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.black,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.grey200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Paused',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.grey600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Dosage and frequency row
                            Row(
                              children: [
                                if (dosage.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.grey100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      dosage,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.grey700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 12,
                                        color: AppTheme.accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        frequency.capitalize(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Reminder times
                            if (timesList.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: timesList.map((time) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.lightAccentBg,
                                          AppTheme.lightAccentBg.withOpacity(
                                            0.7,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.accentColor.withOpacity(
                                          0.15,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.alarm_rounded,
                                          size: 14,
                                          color: AppTheme.accentColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          time,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Instructions
                            if (instructions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 13,
                                    color: AppTheme.grey500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      instructions,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.grey500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Menu button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.grey100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: AppTheme.grey600,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: AppTheme.white,
                          elevation: 8,
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.grey100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AppTheme.grey700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Edit',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.grey700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.red100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Delete',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.errorColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
