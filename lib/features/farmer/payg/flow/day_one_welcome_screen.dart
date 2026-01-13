import 'package:agriflock360/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Day1WelcomeScreen extends StatelessWidget {
  const Day1WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 60,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Welcome to\nAgriFlock 360',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Text(
                  'You\'re now on the AgriFlock 360 Full Farm Experience. For the next 30 days, enjoy full access to feeding, vaccination, quotations, and extension & veterinary services — built to help you farm smarter and earn more.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to batch setup
                    context.go(AppRoutes.farmsAdd);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Set up your first batch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Skip for now
              TextButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
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