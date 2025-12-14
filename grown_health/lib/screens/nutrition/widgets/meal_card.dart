import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final String buttonLabel;
  final Color buttonColor;
  final Color chipColor;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.buttonLabel,
    required this.buttonColor,
    required this.chipColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.13),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.breakfast_dining_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4C4C4C),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                calories,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C4C4C),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: buttonColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        buttonLabel,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: buttonColor,
                          ),
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
