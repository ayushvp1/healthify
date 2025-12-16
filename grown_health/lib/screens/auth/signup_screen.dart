import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grown_health/widgets/widgets.dart';

import '../../providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      SnackBarUtils.showWarning(context, 'Passwords do not match');
      return;
    }

    final name = _nameController.text.trim();

    final success = await ref
        .read(authProvider.notifier)
        .register(email: email, password: password, name: name);

    if (!mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(
        context,
        'Account created! Let\'s set up your profile.',
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/profile_setup', (route) => false);
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

                  const SizedBox(height: 20),

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
                              // Sign Up Title
                              Text(
                                "Sign Up",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConstants.fontSizeXLarge,
                                      color: AppTheme.black,
                                    ),
                              ),
                              Text(
                                "Create an Account",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.grey500,
                                    ),
                              ),
                              const SizedBox(height: 26),

                              // Name Field
                              CustomTextField(
                                controller: _nameController,
                                icon: Icons.person_outline,
                                hintText: 'Name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

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
                              const SizedBox(height: 16),

                              // Confirm Password Field
                              CustomTextField(
                                controller: _confirmPasswordController,
                                icon: Icons.lock_outline_rounded,
                                hintText: 'Confirm Password',
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Terms of Use
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "By signing up you agree with our ",
                                    style: TextStyle(
                                      color: AppTheme.grey600,
                                      fontSize: AppConstants.fontSizeSmall,
                                    ),
                                  ),
                                  CustomButton(
                                    type: ButtonType.text,
                                    onPressed: () {
                                      // TODO: Show Terms of Use
                                    },
                                    text: 'Terms of Use',
                                    textColor: AppTheme.accentColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // Sign Up Button
                        CustomButton(
                          text: "Sign Up",
                          type: ButtonType.primary,
                          onPressed: _handleSignup,
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

                        // Google Signup Button
                        CustomButton(
                          text: "Sign up with Gmail",
                          icon: Icons.mail_outline,
                          type: ButtonType.elevated,
                          onPressed: () {
                            // TODO: Implement Google signup
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 12),

                        // Facebook Signup Button
                        CustomButton(
                          text: "Sign up with Facebook",
                          icon: Icons.facebook,
                          type: ButtonType.elevated,
                          onPressed: () {
                            // TODO: Implement Facebook signup
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 20),

                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: AppTheme.grey700,
                                fontSize: AppConstants.fontSizeSmall,
                              ),
                            ),
                            CustomButton(
                              type: ButtonType.text,
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (r) => false,
                                );
                              },
                              text: 'Sign In',
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
