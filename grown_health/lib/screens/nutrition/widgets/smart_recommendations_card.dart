import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/services/gemini_service.dart';

class SmartRecommendationsCard extends StatefulWidget {
  const SmartRecommendationsCard({super.key});

  @override
  State<SmartRecommendationsCard> createState() =>
      _SmartRecommendationsCardState();
}

class _SmartRecommendationsCardState extends State<SmartRecommendationsCard> {
  String _tip = "Stay hydrated and eat your greens!";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip() async {
    setState(() => _loading = true);
    try {
      final tip = await GeminiService.generateFoodRecommendations();
      if (mounted) {
        setState(() {
          _tip = tip;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Smart AI Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loading ? null : _loadTip,
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          else
            Text(
              _tip,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.grey800,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
