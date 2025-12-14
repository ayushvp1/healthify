import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/water_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/water_intake_model.dart';

class WaterTrackingCard extends ConsumerStatefulWidget {
  const WaterTrackingCard({super.key});

  @override
  ConsumerState<WaterTrackingCard> createState() => _WaterTrackingCardState();
}

class _WaterTrackingCardState extends ConsumerState<WaterTrackingCard> {
  WaterTodayResponse? _todayData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final token = ref.read(authProvider).user?.token;
    
    if (token == null || token.isEmpty) {
      // User not logged in - show static card
      if (mounted) {
        setState(() {
          _loading = false;
          _error = null;
          _todayData = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final waterService = WaterService(token);
      
      // Try to get today's data
      try {
        debugPrint('🚰 Fetching today\'s water intake...');
        final data = await waterService.getTodayWaterIntake();
        debugPrint('✅ Got water data: ${data.count}/${data.goal} glasses');
        
        if (mounted) {
          setState(() {
            _todayData = data;
            _loading = false;
            _error = null;
          });
        }
      } catch (e) {
        debugPrint('⚠️ No water data found, initializing goal...');
        // If no data exists, set goal first
        try {
          await waterService.setWaterGoal(8); // 8 glasses = 2000ml (250ml per glass)
          debugPrint('✅ Goal set to 8 glasses');
          
          final data = await waterService.getTodayWaterIntake();
          debugPrint('✅ Got water data after setting goal: ${data.count}/${data.goal}');
          
          if (mounted) {
            setState(() {
              _todayData = data;
              _loading = false;
              _error = null;
            });
          }
        } catch (goalError) {
          debugPrint('❌ Failed to initialize water tracking: $goalError');
          if (mounted) {
            setState(() {
              _error = 'Unable to connect to water tracking service. Please check your internet connection.';
              _loading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Water tracking error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
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
      
      setState(() {
        _todayData = result;
        _loading = false;
        _error = null;
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added 250ml! ${result.count}/${result.goal} glasses'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final token = ref.watch(authProvider).user?.token;
    
    if (token == null || token.isEmpty) {
      return _buildLoginPromptCard();
    }
    
    if (_loading && _todayData == null) {
      return _buildLoadingCard();
    }

    if (_error != null && _todayData == null) {
      return _buildErrorCard();
    }

    final currentMl = (_todayData?.count ?? 0) * 250; // 250ml per glass
    final targetMl = (_todayData?.goal ?? 8) * 250;
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
                    onPressed: _loading ? null : _addWater,
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
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.add, size: 18, color: Colors.black),
                    label: Text(
                      '250 ml',
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

  Widget _buildLoadingCard() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 9),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFAA3D50),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 9),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Failed to load water data',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWaterData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAA3D50),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPromptCard() {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Track Your Water Intake',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAA3D50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Login to start tracking your daily water intake and stay hydrated!',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAA3D50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Login to Track',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
