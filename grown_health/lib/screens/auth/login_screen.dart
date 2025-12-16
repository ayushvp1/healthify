import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grown_health/widgets/widgets.dart';

import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;

    final success = result['success'] as bool? ?? false;
    final profileCompleted = result['profileCompleted'] as bool? ?? false;

    if (success) {
      if (profileCompleted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/profile_setup');
      }
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) {
        SnackBarUtils.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Curved Header with Back Button
                  CustomBackHeader(
                    height: size.height * 0.2,
                    onBack: () {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    },
                  ),

                  const SizedBox(height: 28),

                  // Body Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingLarge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sign In Title
                              Text(
                                "Sign In",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConstants.fontSizeXLarge,
                                      color: AppTheme.black,
                                    ),
                              ),
                              Text(
                                "Welcome back",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.grey500,
                                    ),
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              CustomTextField(
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                hintText: 'Email Address',
                                inputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              CustomTextField(
                                controller: _passwordController,
                                icon: Icons.lock_outline_rounded,
                                hintText: 'Password',
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Forgot Password Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: CustomButton(
                                  text: "Forgot Password?",
                                  type: ButtonType.text,
                                  onPressed: () {
                                    // TODO: Navigate to forgot password
                                  },
                                  textColor: AppTheme.accentColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // Sign In Button
                        CustomButton(
                          text: "Sign In",
                          type: ButtonType.primary,
                          onPressed: _handleLogin,
                          isLoading: isLoading,
                          isFullWidth: true,
                          height: 48,
                          backgroundColor: AppTheme.accentColor,
                          textColor: AppTheme.white,
                        ),
                        const SizedBox(height: 24),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppTheme.grey400,
                                thickness: 1.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(color: AppTheme.grey600),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppTheme.grey400,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Google Login Button
                        CustomButton(
                          text: "Login with Gmail",
                          icon: Icons.mail_outline,
                          type: ButtonType.elevated,
                          onPressed: () {
                            // TODO: Implement Google login
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 12),

                        // Facebook Login Button
                        CustomButton(
                          text: "Login with Facebook",
                          icon: Icons.facebook,
                          type: ButtonType.elevated,
                          onPressed: () {
                            // TODO: Implement Facebook login
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 20),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New Member? ",
                              style: TextStyle(
                                color: AppTheme.grey700,
                                fontSize: AppConstants.fontSizeSmall,
                              ),
                            ),
                            CustomButton(
                              type: ButtonType.text,
                              onPressed: () {
                                Navigator.of(context).pushNamed('/signup');
                              },
                              text: 'Sign Up',
                              textColor: AppTheme.accentColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: AppTheme.black54,
              child: const Center(child: LoadingWidget(color: AppTheme.white)),
            ),
        ],
      ),
    );
  }
}
