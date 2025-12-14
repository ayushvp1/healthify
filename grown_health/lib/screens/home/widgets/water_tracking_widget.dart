import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/water_service.dart';
import '../../../providers/auth_provider.dart';

class WaterTrackingWidget extends ConsumerStatefulWidget {
  const WaterTrackingWidget({super.key});

  @override
  ConsumerState<WaterTrackingWidget> createState() =>
      _WaterTrackingWidgetState();
}

class _WaterTrackingWidgetState extends ConsumerState<WaterTrackingWidget> {
  bool _loading = false;
  int _currentGlasses = 0;
  int _totalGlasses = 8;

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final token = ref.read(authProvider).user?.token;

    if (token == null || token.isEmpty) {
      return;
    }

    setState(() => _loading = true);

    try {
      final waterService = WaterService(token);
      final data = await waterService.getTodayWaterIntake();
      if (mounted) {
        setState(() {
          _currentGlasses = data.count;
          _totalGlasses = data.goal;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get water data: $e');
      // If failed, try to initialize goal only if it seems strictly necessary or first run
      // For now, we just fallback to offline-like view without overwriting goal blindly
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addWater() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    setState(() => _loading = true);

    try {
      final waterService = WaterService(token);
      final result = await waterService.addWaterGlass();

      if (mounted) {
        setState(() {
          _currentGlasses = result.count;
          _totalGlasses = result.goal;
          _loading = false;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added +1! $_currentGlasses/$_totalGlasses'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Optimistic update
        setState(() {
          _loading = false;
          _currentGlasses++;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added (Offline)')));
      }
    }
  }

  Future<void> _removeWater() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    if (_currentGlasses <= 0) return;

    setState(() => _loading = true);

    try {
      final waterService = WaterService(token);
      final result = await waterService.removeWaterGlass();

      if (mounted) {
        setState(() {
          _currentGlasses = result.count;
          _totalGlasses = result.goal;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (_currentGlasses > 0) _currentGlasses--;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed (Offline)')));
      }
    }
  }

  Future<void> _editGoal() async {
    final controller = TextEditingController(text: _totalGlasses.toString());
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter 1-20 glasses')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _loading = true);
      try {
        final token = ref.read(authProvider).user?.token;
        if (token != null) {
          final service = WaterService(token);
          await service.setWaterGoal(result);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Goal updated!')));
          }
          _loadWaterData();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assumption: 1 glass = 250ml
    final currentMl = _currentGlasses * 250;
    final totalMl = _totalGlasses * 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Milliliter label
        GestureDetector(
          onTap: _editGoal,
          child: Text(
            '${currentMl}ml / ${totalMl}ml',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5B0C23), // Dark Burgundy
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Battery Indicator
        GestureDetector(
          onTap: _loading ? null : _addWater,
          onLongPress: _loading ? null : _removeWater,
          child: Row(
            children: [
              // Battery Body
              Expanded(
                child: Container(
                  height: 56, // Increased height to match image
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD46A7A), // Pinkish border
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: List.generate(_totalGlasses, (index) {
                      final isFilled = index < _currentGlasses;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index == _totalGlasses - 1 ? 0 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? const Color(0xFFAA3D50) // Filled color
                                : Colors.transparent, // Empty
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
                height: 24, // Increased nipple height
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
}
