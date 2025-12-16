import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grown_health/core/core.dart';
import '../../../providers/providers.dart';
import '../../../providers/water_provider.dart';

class WellnessSection extends ConsumerWidget {
  const WellnessSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 110, // Reduced height
      child: Row(
        children: [
          // Medicine Reminder Card (Flex 3)
          Expanded(flex: 3, child: _MedicineCard()),
          const SizedBox(width: 16),
          // Water Tracker Card (Flex 2)
          Expanded(flex: 2, child: _WaterTrackerCard()),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: _getMedicineData(),
      builder: (context, snapshot) {
        final hasData = snapshot.hasData && snapshot.data != null;
        final data = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3), // Very light pink
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B2E42).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  ),
                  if (hasData)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data!['time'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              if (hasData)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Pill',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data!['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'No reminders',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed('/medicine_reminders'),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String>?> _getMedicineData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('latest_medicine_name');
    final time = prefs.getString('latest_medicine_time');
    if (name != null) {
      return {'name': name, 'time': time ?? ''};
    }
    return null;
  }
}

class _WaterTrackerCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider).user?.token;
    final waterState = ref.watch(waterNotifierProvider(token));
    final progress = (waterState.currentMl / waterState.goalMl).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FA), // Very light blue/cyan
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B99).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background Liquid (Horizontal Fill)
          FractionallySizedBox(
            widthFactor: progress,
            heightFactor: 1.0,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF81D4FA).withOpacity(0.3),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Icon + Add)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF0288D1),
                      size: 20,
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(waterNotifierProvider(token).notifier)
                          .addWater(),
                      onLongPress: () => ref
                          .read(waterNotifierProvider(token).notifier)
                          .removeWater(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${waterState.currentMl}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                    Text(
                      '/ ${waterState.goalMl}ml',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF0277BD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
