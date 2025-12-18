import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/core.dart';
import '../../services/gemini_service.dart';
import '../../services/nutrition_service.dart';
import '../../models/calorie_analysis_result.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

import '../../providers/auth_provider.dart';

class CalorieScannerScreen extends ConsumerStatefulWidget {
  const CalorieScannerScreen({super.key});

  @override
  ConsumerState<CalorieScannerScreen> createState() =>
      _CalorieScannerScreenState();
}

class _CalorieScannerScreenState extends ConsumerState<CalorieScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  bool _permissionsGranted = false;
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();

      if (!cameraStatus.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan food';
          _permissionsGranted = false;
        });
        return;
      }

      setState(() {
        _permissionsGranted = true;
      });

      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isAnalyzing = true;
        _errorMessage = null;
      });

      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      if (mounted) {
        _showAnalysisDialog(imageFile);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Failed to capture image: ${e.toString()}';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        if (mounted) {
          _showAnalysisDialog(imageFile);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  void _showAnalysisDialog(File imageFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AnalysisDialog(
        imageFile: imageFile,
        onClose: () {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Calorie Scanner',
          style: GoogleFonts.inter(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_permissionsGranted) {
      return _buildPermissionState();
    }

    if (!_isCameraInitialized) {
      return const Center(child: LoadingWidget());
    }

    return _buildCameraView();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              onPressed: _initializeCamera,
              type: ButtonType.primary,
              backgroundColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera permission required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant camera permission to scan food',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Grant Permission',
              onPressed: _initializeCamera,
              type: ButtonType.primary,
              backgroundColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_cameraController!)),
        Positioned.fill(child: CustomPaint(painter: ScanOverlayPainter())),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Point camera at food to analyze calories',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onPressed: _isAnalyzing ? null : _pickFromGallery,
                      ),
                      GestureDetector(
                        onTap: _isAnalyzing ? null : _captureAndAnalyze,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAnalyzing
                                ? AppTheme.grey400
                                : AppTheme.white,
                            border: Border.all(color: AppTheme.white, width: 4),
                          ),
                          child: _isAnalyzing
                              ? const CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 3,
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                        ),
                      ),
                      _buildControlButton(
                        icon: Icons.flash_off,
                        label: 'Flash',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
          ),
          child: IconButton(
            icon: Icon(icon, color: AppTheme.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(color: AppTheme.white, fontSize: 12),
        ),
      ],
    );
  }
}

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.4,
    );

    const cornerLength = 30.0;

    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _AnalysisDialog extends ConsumerStatefulWidget {
  final File imageFile;
  final VoidCallback onClose;

  const _AnalysisDialog({required this.imageFile, required this.onClose});

  @override
  ConsumerState<_AnalysisDialog> createState() => _AnalysisDialogState();
}

class _AnalysisDialogState extends ConsumerState<_AnalysisDialog> {
  CalorieAnalysisResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final result = await GeminiService.analyzeFood(widget.imageFile);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXXLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onClose();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 20),
          Text(
            'Analyzing Nutrition...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gemini AI is identifying food items',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.grey600),
          ),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Analysis Failed',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.grey600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose();
                  },
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _analyzeImage();
                  },
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return _buildResultContent(_result!);
  }

  Widget _buildResultContent(CalorieAnalysisResult result) {
    Color calorieColor;
    if (result.totalCalories > 512) {
      calorieColor = Colors.red;
    } else if (result.totalCalories > 200) {
      calorieColor = Colors.orange;
    } else {
      calorieColor = Colors.green;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${result.totalCalories}',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: calorieColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kcal',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: calorieColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${result.confidenceLevel}% match • ${result.confidenceDescription}',
              style: GoogleFonts.inter(
                color: calorieColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Identified Items:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...result.foodItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.inter(color: AppTheme.grey800),
                    ),
                  ),
                  Text(
                    '${item.calories} kcal',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (result.warning != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.warning!,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Scan More',
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose();
                  },
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Log Food',
                  onPressed: () async {
                    final token = ref.read(authProvider).user?.token;
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to log food'),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final success = await NutritionService.logMeal(
                      token: token,
                      name: result.foodItems.isNotEmpty
                          ? result.foodItems.first.name
                          : 'Scanned Food',
                      calories: result.totalCalories,
                      items: result.foodItems
                          .map(
                            (item) => {
                              'name': item.name,
                              'calories': item.calories,
                            },
                          )
                          .toList(),
                    );

                    Navigator.of(context).pop(); // Remove loading

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Food logged successfully!'),
                        ),
                      );
                      Navigator.of(context).pop();
                      widget.onClose();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to log food. Try again.'),
                        ),
                      );
                    }
                  },
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
