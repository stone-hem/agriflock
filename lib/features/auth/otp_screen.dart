import 'dart:convert';

import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String email;
  const OTPVerifyScreen({super.key, required this.email});

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
      backgroundColor: Colors.grey.shade50,
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
                  'Verify Email',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Email display
              Center(
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),

              Center(
                child: Text(
                  'Enter the 6-digit verification code sent to your email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // OTP Input Fields (6 digits for email verification)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                              (index) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 60,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                                contentPadding: EdgeInsets.zero, // removes internal padding
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
                                foregroundColor: Colors.green.shade600,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.green.withOpacity(0.5),
                          ),
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
                            'Verify Email',
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
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTP() async {
    // Validate OTP length
    if (_otpCode.length != 6) {
      ToastUtil.showError("Please enter all 6 digits");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await apiClient.post(
        '/auth/verify-email',
        body: {
          'code': _otpCode.toString(),
        },
      );

      if (response.statusCode == 200) {
          ToastUtil.showSuccess("Email verified successfully!");
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final message = decoded['message'] as Map<String, dynamic>;
          final tempToken = message['tempToken'] as String?;

          if (mounted) {
            // Clear OTP fields on failure
            _clearOtpFields();
            context.push(
              '${AppRoutes.onboardingQuiz}?tempToken=${Uri.encodeComponent(tempToken ?? '')}',
            );
          }
      } else {
        ApiErrorHandler.handle(response);
        _clearOtpFields();
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
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
      final response = await apiClient.post(
        '/auth/resend-code',
        body: {
          'identifier': widget.email,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          ToastUtil.showSuccess("Verification code resent successfully!");

          // Start countdown again
          _startCountdown();

          // Clear previous OTP
          _clearOtpFields();
          _focusNodes[0].requestFocus();
        } else {
          ToastUtil.showError(data['message'] ?? 'Failed to resend code');
          setState(() => _canResend = true);
        }
      } else {
        ApiErrorHandler.handle(response);
        setState(() => _canResend = true);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() => _canResend = true);
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