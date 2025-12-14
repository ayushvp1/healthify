import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HydrationCard extends StatelessWidget {
  final int currentMl;
  final int targetMl;
  final VoidCallback? onAddWater;

  const HydrationCard({
    super.key,
    this.currentMl = 0,
    this.targetMl = 2000,
    this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = targetMl - currentMl;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 9),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: SizedBox(
              width: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  size: 48,
                  color: Color(0xFFAA3D50),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 20, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentMl}ml / ${targetMl}ml',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAA3D50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remaining: ${remaining}ml',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Staying hydrated improves energy, brain function and overall health.',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: onAddWater,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18, color: Colors.black),
                    label: Text(
                      '200 ml',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
