import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/first_login_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/auth/repo/manual_auth_repo.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:agriflock360/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  final String? identifier;
  const LoginScreen({super.key, this.identifier});

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
  void initState() {
    super.initState();
    if (widget.identifier != null) {
      _identifierController.text = widget.identifier!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Card(
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
                            readOnly: widget.identifier != null,
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
              ),
              const SizedBox(height: 24),

              // Divider
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),

                child: Row(
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
              ),
              const SizedBox(height: 24),

              // Social Sign In Buttons
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signInWithGoogle,
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
              ),
              const SizedBox(height: 32),

              // Sign Up Link
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/signup'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle conditional auth failures (shared between login and social auth)
  void _handleAuthFailure<T>(Failure<T> failure) {
    if (!mounted) return;

    switch (failure.cond) {
      case 'user_onboarding':
        final tempToken = failure.data?['tempToken'] as String? ?? '';
        context.push(
          '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
          extra: _identifierController.text.trim(),
        );
      case 'account_inactive':
        final email = failure.data?['email'] as String? ??
            _identifierController.text.trim();
        final userId = failure.data?['userId'] as String? ?? '';
        context.push(
          '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}&userId=${Uri.encodeComponent(userId)}',
        );
      case 'unverified_vet':
        context.go(AppRoutes.vetVerificationPending);
      default:
        ApiErrorHandler.handleFailure(failure);
    }
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

      switch (result) {
        case Success():
          ToastUtil.showSuccess("Login successful!");
          final redirectPath = await FirstLoginUtil.getRedirectPath();
          if (mounted) context.go(redirectPath);

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Login failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await authService.signInWithGoogle();

      if (!mounted) return;

      switch (result) {
        case Success():
          ToastUtil.showSuccess("Login successful!");
          final redirectPath = await FirstLoginUtil.getRedirectPath();
          if (mounted) context.go(redirectPath);

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Google sign in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithApple() async {
    setState(() => _isLoading = true);

    try {
      final result = await authService.signInWithApple();

      if (!mounted) return;

      switch (result) {
        case Success():
          ToastUtil.showSuccess("Login successful!");
          final redirectPath = await FirstLoginUtil.getRedirectPath();
          if (mounted) context.go(redirectPath);

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Apple sign in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
