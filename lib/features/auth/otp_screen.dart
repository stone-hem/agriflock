import 'package:agriflock/core/utils/snackbar_api_error_handler.dart';
import 'package:agriflock/core/widgets/app_snack_bar.dart';
import 'package:agriflock/app_routes.dart';
import 'package:agriflock/features/auth/repo/manual_auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String email;
  final String? phoneNumber;
  final String userId;
  const OTPVerifyScreen({super.key, required this.email, this.phoneNumber, required this.userId});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _countdown = 60;
  bool _canResend = false;
  final ManualAuthRepository _authRepository = ManualAuthRepository();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
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
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Image.asset(
                  'assets/logos/Logo_0725.png',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green,
                      child: const Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),

              // Header
              Center(
                child: Text(
                  'Verify Phone Number',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Phone display
              if(widget.phoneNumber != null)
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Text(
                    'An OTP has been sent to your number ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Enter the 6-digit verification code sent to your phone number',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Card
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // OTP Input Fields (6 digits)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                                (index) => SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.12,
                              height: 60,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style:  TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  // Move to next field when a digit is entered
                                  if (value.length == 1 && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }

                                  // Auto verify if all fields are filled
                                  if (index == 5 && value.isNotEmpty && _otpCode.length == 6) {
                                    _verifyOTP();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Resend OTP
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _canResend
                                  ? TextButton(
                                onPressed: _resendOTP,
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColor,
                                ),
                                child: const Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                                  : Text(
                                'Resend in $_countdown seconds',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading || _otpCode.length != 6
                                ? null
                                : _verifyOTP,
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Verify Phone Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Go back to login')
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTP() async {
    if (_otpCode.length != 6) {
      AppSnackBar.show(context, message: 'Please enter all 6 digits', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authRepository.verifyEmail(
        otpCode: _otpCode,
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        AppSnackBar.show(context, message: result['message'] ?? 'Verified successfully!', type: SnackBarType.success);

        final tempToken = result['tempToken'];
        _clearOtpFields();

        if (tempToken != null) {
          context.go(
            '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken)}',
            extra: widget.email,
          );
        } else {
          context.go('/login');
        }
      } else {
        AppSnackBar.show(context, message: result['message'] ?? 'Verification failed', type: SnackBarType.error);
        _clearOtpFields();
      }
    } catch (e) {
      if (mounted) {
        SnackBarApiErrorHandler.handle(context, e);
      }
      _clearOtpFields();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _countdown = 60;
    });

    try {
      final result = await _authRepository.resendVerificationCode(
        identifier: widget.email,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        AppSnackBar.show(context, message: result['message'] ?? 'Code resent successfully!', type: SnackBarType.success);
        _startCountdown();
        _clearOtpFields();
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      } else {
        AppSnackBar.show(context, message: result['message'] ?? 'Failed to resend code', type: SnackBarType.error);
        setState(() => _canResend = true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarApiErrorHandler.handle(context, e);
        setState(() => _canResend = true);
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (mounted && _focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}