import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/services/social_auth_service.dart';
import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/first_login_util.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/widgets/app_snack_bar.dart';
import 'package:flutter/services.dart';
import 'package:agriflock/features/auth/repo/manual_auth_repo.dart';
import 'package:agriflock/features/auth/shared/auth_text_field.dart';
import 'package:agriflock/features/auth/shared/country_phone_input.dart';
import 'package:agriflock/features/auth/shared/country_service.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';


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
  bool _acceptedSmsAlerts = false;
  bool _showSmsError = false;

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(
                                  r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{FE00}-\u{FEFF}\u{1FA00}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}]',
                                  unicode: true,
                                ),
                              ),
                            ],
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
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password must contain at least 1 uppercase letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Password must contain at least 1 digit';
                              }
                              if (!RegExp(r'[!@#$%^&*()\[\]{};:,.<>?/~|_\-+=\\`]').hasMatch(value)) {
                                return 'Password must contain at least 1 symbol';
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
                                    activeColor: Theme.of(context).primaryColor,
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
                                                onTap: () => launchUrl(
                                                  Uri.parse('https://www.agriflock360.com/terms-conditions'),
                                                  mode: LaunchMode.externalApplication,
                                                ),
                                                child: Text(
                                                  'Terms and Conditions',
                                                  style: TextStyle(
                                                    color: Theme.of(context).primaryColor,
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
                                                onTap: () => launchUrl(
                                                  Uri.parse('https://www.agriflock360.com/privacy-policy'),
                                                  mode: LaunchMode.externalApplication,
                                                ),
                                                child: Text(
                                                  'Privacy Policy',
                                                  style: TextStyle(
                                                    color: Theme.of(context).primaryColor,
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
                          const SizedBox(height: 12),

                          // SMS Alerts Checkbox (mandatory)
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
                                    value: _acceptedSmsAlerts,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _acceptedSmsAlerts = value ?? false;
                                        _showSmsError = false;
                                      });
                                    },
                                    activeColor: Theme.of(context).primaryColor,
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
                                      Text(
                                        'I agree to receive SMS alerts and account notifications for Agriflock 360.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                      Text(
                                        'You can opt out later in your account settings.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (_showSmsError && !_acceptedSmsAlerts)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Please accept SMS notifications to continue',
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
                                setState(() {
                                  _showTermsError = true;
                                  _showSmsError = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  if (!_acceptedTerms) {
                                    AppSnackBar.show(context, message: 'Please accept the terms and conditions', type: SnackBarType.error);
                                    return;
                                  }
                                  if (!_acceptedSmsAlerts) {
                                    AppSnackBar.show(context, message: 'Please accept SMS notifications to continue', type: SnackBarType.error);
                                    return;
                                  }
                                  _signUp();
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
              ),
              const SizedBox(height: 24),

              // Social Sign Up Buttons
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signUpWithGoogle,
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

              // Login Link
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/login'),
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
        final email = failure.data?['email'] as String? ?? _emailController.text.trim();
        _showSocialTermsDialog(tempToken: tempToken, email: email);
      case 'account_unverified':
        final email = failure.data?['email'] as String? ??
            _emailController.text.trim();
        final userId = failure.data?['userId'] as String? ?? '';
        context.push(
          '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}&userId=${Uri.encodeComponent(userId)}',
          extra: _phoneController.text.trim(),
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
      AppSnackBar.show(context, message: 'Please enter your full name', type: SnackBarType.error);
      return;
    }
    if (email.isEmpty) {
      AppSnackBar.show(context, message: 'Please enter your email', type: SnackBarType.error);
      return;
    }
    if (phone.isEmpty) {
      AppSnackBar.show(context, message: 'Please enter your phone number', type: SnackBarType.error);
      return;
    }
    if (password.isEmpty) {
      AppSnackBar.show(context, message: 'Please enter your password', type: SnackBarType.error);
      return;
    }
    if (!_acceptedTerms) {
      AppSnackBar.show(context, message: 'Please accept the terms and conditions', type: SnackBarType.error);
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
        agreedToSmsAlerts: _acceptedSmsAlerts,
      );

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          AppSnackBar.show(context, message: 'Account created successfully! Please verify your account.', type: SnackBarType.success);
          final userId = data['userId'] as String? ?? '';
          context.go(
            '${AppRoutes.otpVerifyEmailOrPhone}?email=${Uri.encodeComponent(email)}&userId=${Uri.encodeComponent(userId)}',
            extra: completePhoneNumber,
          );

        case final Failure failure:
          ApiErrorHandler.handleFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Sign up failed: ${e.toString()}', type: SnackBarType.error);
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
            final email = data['email'] as String? ?? '';
            _showSocialTermsDialog(tempToken: tempToken, email: email);
          } else {
            AppSnackBar.show(context, message: 'Welcome back!', type: SnackBarType.success);
            final redirectPath = await FirstLoginUtil.getRedirectPath();
            if (mounted) context.go(redirectPath);
          }

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Google sign up failed: ${e.toString()}', type: SnackBarType.error);
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
            final email = data['email'] as String? ?? '';
            _showSocialTermsDialog(tempToken: tempToken, email: email);
          } else {
            AppSnackBar.show(context, message: 'Welcome back!', type: SnackBarType.success);
            final redirectPath = await FirstLoginUtil.getRedirectPath();
            if (mounted) context.go(redirectPath);
          }

        case final Failure failure:
          _handleAuthFailure(failure);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Apple sign up failed: ${e.toString()}', type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSocialTermsDialog({
    required String tempToken,
    required String email,
  }) async {
    bool agreedToTerms = false;
    bool acceptSms = false;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool isSubmitting = false;

          Future<void> submit() async {
            setDialogState(() => isSubmitting = true);
            try {
              final response = await apiClient.patch(
                '/auth/agree-to-terms',
                headers: {'Authorization': 'Bearer $tempToken'},
                body: {
                  'agreed_to_terms': true,
                  'accept_sms_notifications': acceptSms,
                },
              );
              if (response.statusCode == 200 || response.statusCode == 201) {
                if (mounted) context.pop(true);
              } else {
                LogUtil.error(response);
                AppSnackBar.show(context, message: 'Failed to accept terms. Please try again.', type: SnackBarType.error);
                setDialogState(() => isSubmitting = false);
              }
            } catch (e) {
              AppSnackBar.show(context, message: 'An error occurred. Please try again.', type: SnackBarType.error);
              setDialogState(() => isSubmitting = false);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Terms & Conditions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Before continuing, please review and accept our terms and conditions.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse('https://www.agriflock360.com/terms-conditions'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(dialogContext).primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text('  ·  ', style: TextStyle(fontSize: 13)),
                    GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse('https://www.agriflock360.com/privacy-policy'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(dialogContext).primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: agreedToTerms,
                  onChanged: isSubmitting
                      ? null
                      : (v) => setDialogState(() => agreedToTerms = v ?? false),
                  title: const Text(
                    'I agree to the Terms & Conditions',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: acceptSms,
                  onChanged: isSubmitting
                      ? null
                      : (v) => setDialogState(() => acceptSms = v ?? false),
                  title: const Text(
                    'I agree to receive SMS notifications',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'You can opt out later in your account settings.',
                    style: TextStyle(fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => context.pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: agreedToTerms && acceptSms && !isSubmitting ? submit : null,
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Agree & Continue'),
              ),
            ],
          );
        },
      ),
    );

    if (accepted == true && mounted) {
      context.push(
        '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
        extra: email,
      );
    }
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
