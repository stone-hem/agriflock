import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/auth/repo/manual_auth_repo.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:agriflock360/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _manualAuthRepo = ManualAuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logos/Logo_0725.png',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green,
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),

              // Header
              Center(
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Sign in to continue to your farm dashboard',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Login Form Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _identifierController,
                          labelText: 'Email/Phone Number',
                          hintText: 'Enter your email/phone number',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your credential';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        AuthTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade600,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: Colors.green.withOpacity(
                                0.5,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Social Sign In Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/logos/google.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signInWithApple,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apple,
                              size: 20,
                              color: Colors.grey.shade800,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Apple',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.go('/signup'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    final email = _identifierController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ToastUtil.showError("Please enter your email");
      return;
    }
    if (password.isEmpty) {
      ToastUtil.showError("Please enter your password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _manualAuthRepo.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ToastUtil.showSuccess("Login successful!");
        context.go(AppRoutes.dashboard);
      } else if (result['needsOnboarding'] == true) {
        // Redirect to onboarding quiz
        final tempToken = result['tempToken'] ?? '';
        context.push(
          '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
        );
      } else if (result['needsVerification'] == true) {
        // Redirect to email verification
        final email = result['email'] ?? '';
        context.push(
          '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}',
        );
      }
    } catch (e) {
      // Error already handled by repository
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This returns the BACKEND response, not just Google user data
      final response = await authService.signInWithGoogle();


      if (!mounted) return;

      if (response['success'] == true) {
        ToastUtil.showSuccess("Login successful!");
        context.go(AppRoutes.dashboard);
      } else if (response['needsOnboarding'] == true) {
        // Redirect to onboarding quiz
        final tempToken = response['tempToken'] ?? '';
        context.go(
          '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
        );
      } else if (response['needsVerification'] == true) {
        // Redirect to email verification
        final email = response['email'] ?? '';
        context.push(
          '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await authService.signInWithApple();

      if (!mounted) return;

      if (response['success'] == true) {
        ToastUtil.showSuccess("Login successful!");
        context.go(AppRoutes.dashboard);
      } else if (response['needsOnboarding'] == true) {
        // Redirect to onboarding quiz
        final tempToken = response['tempToken'] ?? '';
        context.push(
          '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
        );
      } else if (response['needsVerification'] == true) {
        // Redirect to email verification
        final email = response['email'] ?? '';
        context.push(
          '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}',
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
