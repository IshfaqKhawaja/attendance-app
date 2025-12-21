import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/text_styles.dart';
import '../controllers/signin_controller.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late final SignInController controller;

  // Max width for the sign-in card on web
  static const double maxCardWidth = 420;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller, create if not found
    try {
      controller = Get.find<SignInController>();
    } catch (e) {
      controller = Get.put(SignInController(), permanent: true);
    }
    // Reset form key immediately to avoid duplicate GlobalKey error
    // This must happen before the widget tree is built
    controller.resetFormKey();
    // Clear form fields after the frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearFormFields();
      controller.otpReady.value = false;
      controller.resendCooldown.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 24);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? maxCardWidth : double.infinity,
                ),
                child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // JMI Logo
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'JMI Attendance',
                          style: textStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign In to Continue',
                          style: textStyle.copyWith(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Email Input:
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        sizedBox,
                        // OTP Form
                        if (controller.otpReady.value)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: controller.otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'OTP',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter otp';
                                  }
                                  if (value.length != 6) {
                                    return 'Please enter 6 digit otp';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              // Resend OTP Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: controller.resendCooldown.value > 0
                                      ? null
                                      : controller.resendOtp,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: Text(
                                    controller.resendCooldown.value > 0
                                        ? 'Resend in ${controller.resendCooldown.value}s'
                                        : 'Resend OTP',
                                    style: textStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        sizedBox,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.otpReady.value
                                ? controller.verifyOtp
                                : controller.sendOtp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    controller.otpReady.value
                                        ? "Verify OTP"
                                        : 'Send OTP',
                                    style: textStyle.copyWith(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
            ),
          );
        }),
      ),
    );
  }
}
