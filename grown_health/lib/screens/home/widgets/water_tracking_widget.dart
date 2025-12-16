import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/water_provider.dart';

/// Water tracking widget that uses shared water provider for sync across screens
class WaterTrackingWidget extends ConsumerWidget {
  const WaterTrackingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider).user?.token;
    final waterState = ref.watch(waterNotifierProvider(token));

    final currentMl = waterState.currentMl;
    final totalMl = waterState.goalMl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Milliliter label
        GestureDetector(
          onTap: () => _editGoal(context, ref, token, waterState.goalGlasses),
          child: Text(
            '${currentMl}ml / ${totalMl}ml',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Battery Indicator
        GestureDetector(
          onTap: waterState.loading
              ? null
              : () =>
                    ref.read(waterNotifierProvider(token).notifier).addWater(),
          onLongPress: waterState.loading
              ? null
              : () => ref
                    .read(waterNotifierProvider(token).notifier)
                    .removeWater(),
          child: Row(
            children: [
              // Battery Body
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD46A7A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: List.generate(waterState.goalGlasses, (index) {
                      final isFilled = index < waterState.currentGlasses;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index == waterState.goalGlasses - 1 ? 0 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? AppTheme.accentColor
                                : AppTheme.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: isFilled
                                ? null
                                : Border.all(
                                    color: const Color(0xFFF2C3CC),
                                    width: 1,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Battery Nipple
              Container(
                width: 6,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFD46A7A),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editGoal(
    BuildContext context,
    WidgetRef ref,
    String? token,
    int currentGoal,
  ) async {
    final controller = TextEditingController(text: currentGoal.toString());
    final result = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Glasses (1-20)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 1 && val <= 20) {
                Navigator.pop(context, val);
              } else {
                SnackBarUtils.showWarning(context, 'Please enter 1-20 glasses');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && token != null) {
      await ref.read(waterNotifierProvider(token).notifier).setGoal(result);
      if (context.mounted) {
        SnackBarUtils.showSuccess(context, 'Goal updated!');
      }
    }
  }
}

// Keep backwards-compatible state class for any legacy code
class WaterTrackingWidgetState
    extends ConsumerState<StatefulWaterTrackingWidget> {
  @override
  Widget build(BuildContext context) {
    return const WaterTrackingWidget();
  }
}

class StatefulWaterTrackingWidget extends ConsumerStatefulWidget {
  const StatefulWaterTrackingWidget({super.key});

  @override
  ConsumerState<StatefulWaterTrackingWidget> createState() =>
      WaterTrackingWidgetState();
}
