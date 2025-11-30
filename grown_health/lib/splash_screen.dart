import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAA3D50),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // White rounded square with heart icon
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Center(
                  child: SizedBox(
                    width: 69,
                    height: 69,
                    child: Image.asset('assets/heart.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title: Grown Health
              Text(
                'Grown Health',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 39,
                    height: 47 / 39, // line-height from Figma
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle: Your Health Journey Starts Here
              Text(
                'Your Health Journey Starts Here',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: 24 / 20,
                    color: Colors.white,
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
