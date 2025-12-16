import 'package:flutter/material.dart';
import '../core/core.dart';

/// A curved header widget with a back button.
/// Features a primary-colored curved background with a circular back button.
class CustomBackHeader extends StatelessWidget {
  final double height;
  final VoidCallback? onBack;

  const CustomBackHeader({super.key, this.height = 200, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _TopCurveClipper(),
          child: Container(height: height, color: AppTheme.accentColor),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          child: CircleAvatar(
            backgroundColor: AppTheme.accentColor,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.white,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom clipper for the curved top header
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
