import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MacroNutrientsCard extends StatelessWidget {
  final int proteinCurrent;
  final int proteinTarget;
  final int carbsCurrent;
  final int carbsTarget;
  final int fatsCurrent;
  final int fatsTarget;

  const MacroNutrientsCard({
    super.key,
    this.proteinCurrent = 0,
    this.proteinTarget = 150,
    this.carbsCurrent = 0,
    this.carbsTarget = 250,
    this.fatsCurrent = 0,
    this.fatsTarget = 65,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 9),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Macro Nutrients',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroItem(
                label: 'Protein',
                value: '$proteinCurrent/${proteinTarget}g',
                icon: Icons.close_rounded,
                iconColor: const Color(0xFFAA3D50),
              ),
              _MacroItem(
                label: 'Carbs',
                value: '$carbsCurrent/${carbsTarget}g',
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
              ),
              _MacroItem(
                label: 'Fats',
                value: '$fatsCurrent/${fatsTarget}g',
                icon: Icons.water_drop_rounded,
                iconColor: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
