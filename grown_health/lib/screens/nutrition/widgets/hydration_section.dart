import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// A stateful widget that displays hydration tracking with a water bottle graphic.
class HydrationSection extends StatefulWidget {
  const HydrationSection({super.key});

  @override
  State<HydrationSection> createState() => _HydrationSectionState();
}

class _HydrationSectionState extends State<HydrationSection> {
  int currentIntake = 0;
  final int dailyGoal = 2000;

  void _addWater() {
    setState(() {
      if (currentIntake < dailyGoal) {
        currentIntake += 200;
        if (currentIntake > dailyGoal) {
          currentIntake = dailyGoal;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colors extracted from design
    const Color darkMaroon = Color(0xFF64091A);
    const Color forestGreen = Color(0xFF0C5531);
    const Color darkGreyText = Color(0xFF3B3B3B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 9,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Bottle Graphic
          WaterBottleGraphic(
            fillColor: const Color(0xFFC75B6E),
            emptyColor: Colors.transparent,
            currentIntake: currentIntake,
            maxIntake: dailyGoal,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${currentIntake}ml / ${dailyGoal}ml',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: darkMaroon,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${dailyGoal - currentIntake}ml',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: forestGreen,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Staying hydrated improves energy, brain function and overall health',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: darkGreyText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addWater,
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: forestGreen),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 20, color: forestGreen),
                          SizedBox(width: 8),
                          Text(
                            '200 ml',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              color: forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A visual representation of a water bottle with fill level.
class WaterBottleGraphic extends StatelessWidget {
  final Color fillColor;
  final Color emptyColor;
  final int currentIntake;
  final int maxIntake;

  const WaterBottleGraphic({
    super.key,
    required this.fillColor,
    required this.emptyColor,
    required this.currentIntake,
    required this.maxIntake,
  });

  @override
  Widget build(BuildContext context) {
    const double bottleWidth = 80;
    const double bottleHeight = 170;

    final double fillPercentage = (currentIntake / maxIntake).clamp(0.0, 1.0);
    final int filledSegments = (fillPercentage * 8).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cap
        Container(
          width: 36,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFC76A76),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Body
        Container(
          width: bottleWidth,
          height: bottleHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5ACB6), width: 2.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              // index 0 is top, index 7 is bottom.
              // index >= (8 - filledSegments) -> filled
              bool isFilled = index >= (8 - filledSegments);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isFilled ? fillColor : Colors.white,
                    border: Border.all(
                      color: isFilled ? fillColor : const Color(0xFFF2D1D9),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
