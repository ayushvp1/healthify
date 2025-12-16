import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Grid layout for quick action buttons.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(Icons.camera_alt, 'Scan Food', Colors.deepPurple),
        _buildActionCard(Icons.restaurant_menu, 'Log Meal', Colors.teal),
        _buildActionCard(Icons.history, 'View History', Colors.green),
        _buildActionCard(Icons.notifications, 'Set Reminder', Colors.blue),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
