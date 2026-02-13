import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/services/social_auth_service.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/first_login_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/auth/repo/manual_auth_repo.dart';
import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:agriflock360/features/auth/shared/country_phone_input.dart';
import 'package:agriflock360/features/auth/shared/country_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _manualAuthRepo = ManualAuthRepository();


  Country? _selectedCountry;
  List<Country> _countries = [];
  bool _isLoadingCountry = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await CountriesService.loadCountries();
      setState(() {
        _countries = countries;
        _isLoadingCountry = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        _isLoadingCountry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
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
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Join thousands of people in Agriflock',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Signup Form Card
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
                        // Full Name
                        AuthTextField(
                          controller: _fullNameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        AuthTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Country Phone Input
                        CountryPhoneInput(
                          controller: _phoneController,
                          countries: _countries,
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          initialCountry: Country(name: "United States",
                              code: "US",
                              emoji: "🇺🇸",
                              unicode: "U+1F1FA U+1F1F8",
                              image: "US.svg",
                              dialCode: "+1"),
                          onCountryChanged: (country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Create a strong password',
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
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Terms and Conditions Checkbox
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                      _showTermsError = false;
                                    });
                                  },
                                  activeColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'I agree to the ',
                                          ),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                _showTermsDialog(context);
                                              },
                                              child: Text(
                                                'Terms and Conditions',
                                                style: TextStyle(
                                                  color: Colors.green.shade600,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                  TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                _showPrivacyDialog(context);
                                              },
                                              child: Text(
                                                'Privacy Policy',
                                                style: TextStyle(
                                                  color: Colors.green.shade600,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                  TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_acceptedTerms && _showTermsError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Please accept the terms and conditions',
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              setState(() => _showTermsError = true);

                              if (_formKey.currentState!.validate()) {
                                if (!_acceptedTerms) {
                                  ToastUtil.showError('Please accept the terms and conditions');
                                  return;
                                }
                                _signUp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor:
                              Colors.green.withOpacity(0.5),
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
                              'Create Account',
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
                      'Or sign up with',
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

              // Social Sign Up Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
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
                        onPressed: _isLoading ? null : _signUpWithApple,
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

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                    ),
                    child: const Text(
                      'Login',
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

  /// Handle conditional auth failures (shared between social auth methods)
  void _handleAuthFailure<T>(Failure<T> failure) {
    if (!mounted) return;

    switch (failure.cond) {
      case 'user_onboarding':
        final tempToken = failure.data?['tempToken'] as String? ?? '';
        context.push(
          '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
        );
      case 'account_inactive':
        final email = failure.data?['email'] as String? ??
            _emailController.text.trim();
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

  void _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // Validate required fields
    if (fullName.isEmpty) {
      ToastUtil.showError("Please enter your full name");
      return;
    }
    if (email.isEmpty) {
      ToastUtil.showError("Please enter your email");
      return;
    }
    if (phone.isEmpty) {
      ToastUtil.showError("Please enter your phone number");
      return;
    }
    if (password.isEmpty) {
      ToastUtil.showError("Please enter your password");
      return;
    }
    if (!_acceptedTerms) {
      ToastUtil.showError("Please accept the terms and conditions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final countryCode = _selectedCountry?.dialCode ?? '+1';
      final completePhoneNumber =
      phone.startsWith('+') ? phone : '$countryCode$phone';

      final result = await _manualAuthRepo.signUp(
        fullName: fullName,
        email: email,
        phoneNumber: completePhoneNumber,
        password: password,
        agreedToTerms: true,
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          ToastUtil.showSuccess(
            "Account created successfully! Please verify your account.",
          );
          final userId = data['userId'] as String? ?? '';
          context.go(
            '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}&userId=${Uri.encodeComponent(userId)}',
          );

        case final Failure failure:
          ApiErrorHandler.handleFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Sign up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await SocialAuthService().signInWithGoogle();

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          if (data['is_new_user'] == true) {
            final tempToken = data['tempToken'] as String? ?? '';
            context.push(
              '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
            );
          } else {
            ToastUtil.showSuccess("Welcome back!");
            final redirectPath = await FirstLoginUtil.getRedirectPath();
            if (mounted) context.go(redirectPath);
          }

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Google sign up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signUpWithApple() async {
    setState(() => _isLoading = true);

    try {
      final result = await SocialAuthService().signInWithApple();

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          if (data['is_new_user'] == true) {
            final tempToken = data['tempToken'] as String? ?? '';
            context.push(
              '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
            );
          } else {
            ToastUtil.showSuccess("Welcome back!");
            final redirectPath = await FirstLoginUtil.getRedirectPath();
            if (mounted) context.go(redirectPath);
          }

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Apple sign up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By creating an account with AgriFlock360, you agree to:\n\n'
                '1. Provide accurate and complete information\n'
                '2. Maintain the security of your account credentials\n'
                '3. Accept responsibility for all activities under your account\n'
                '4. Use the service only for lawful purposes\n'
                '5. Not engage in any fraudulent activities\n\n'
                'We reserve the right to modify these terms at any time. '
                'Continued use of the service constitutes acceptance of modified terms.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This Privacy Policy explains:\n\n'
                '• What personal data we collect\n'
                '• How we use your data\n'
                '• How we protect your information\n'
                '• Your rights regarding your data\n'
                '• How to contact us about privacy concerns\n\n'
                'We collect information you provide directly, including name, email, '
                'phone number, and farm data. We use this to provide and improve our services.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
