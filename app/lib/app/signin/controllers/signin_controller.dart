import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Core imports
import '../../core/core.dart';
import '../../routes/routes.dart';


// Local imports
import 'access_controller.dart';
import '../models/teacher_model.dart';
import '../models/user_model.dart';

class SignInController extends BaseFormController {
  late final TextEditingController emailController;
  late final TextEditingController otpController;
  final otpReady = false.obs;
  final resendCooldown = 0.obs; // Cooldown timer in seconds
  Timer? _resendTimer;
  
  Rx<TeacherModel> teacherData = TeacherModel(
    teacherId: "",
    teacherName: "",
    type: "",
    deptId: "",
  ).obs;

  Rx<UserModel> userData = UserModel(
    userId: "",
    userName: "",
    type: "",
    deptId: null,
    factId: null,
  ).obs;


  var isUserLoggedIn = false.obs;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepo;
  void checkIsUserLoggedIn() async {
    var accessToken = await AccessController.getAccessToken();
    if (accessToken == null) {
      // Not logged In
    } else {
      isUserLoggedIn.value = true;
    }
  }

  Future<void> sendOtp() async {
    return handleAsync(() async {
      if (!validateForm()) return;
      
      final email = emailController.text.trim();
      final res = await _authRepo.sendOtp(email);
      
      if ((res['success'] ?? false) == true) {
        final dynamic maybeOtp = res['otp'] ?? (res['data'] != null ? res['data']['otp'] : null);
        print("OTP Sent: $maybeOtp");
        showSuccessSnackbar("OTP sent to: $email");
        otpReady.value = true;
        _startResendCooldown();
      } else {
        throw Exception(res['message']?.toString() ?? 'Failed to send OTP');
      }
    });
  }
  
  /// Start cooldown timer for resend OTP (60 seconds)
  void _startResendCooldown() {
    resendCooldown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }
  
  /// Resend OTP (reuses sendOtp logic)
  Future<void> resendOtp() async {
    if (resendCooldown.value > 0) {
      showInfoSnackbar("Please wait ${resendCooldown.value} seconds before resending");
      return;
    }
    await sendOtp();
  }

  Future<void> verifyOtp() async {
    return handleAsync(() async {
      final otp = otpController.text.trim();
      final email = emailController.text.trim();

      final res = await _authRepo.verifyOtp(email, otp);
      final success = res["success"] == true;
      final isRegistered = res["is_registered"] == true;
      final isHod = res["is_hod"] == true;
      final isDean = res["is_dean"] == true;
      final isSuperAdmin = res["is_super_admin"] == true;

      if (success) {
        await AccessController.saveTokens(
          res["access_token"],
          res["refresh_token"],
        );

        // Save user data for auto-login
        await AccessController.saveUserData(res);

        // Set user data based on role
        // Admin users (Super Admin, Dean, HOD) use UserModel
        if (isSuperAdmin || isDean || isHod) {
          userData.value = UserModel.fromJson(res);
        } else if (isRegistered) {
          teacherData.value = TeacherModel.fromJson(res);
        }

        // Navigate to main dashboard if user is registered, otherwise show registration message
        if (isSuperAdmin || isDean || isHod || isRegistered) {
          clearForm(); // Clear form after successful login
          safeNavigateOffAll(Routes.MAIN_DASHBOARD);
        } else {
          showInfoSnackbar("Please complete your registration.");
        }
        otpReady.value = true;
      } else {
        throw Exception(res["message"]?.toString() ?? 'Verification failed');
      }
    });
  }

  /// Clear all form fields and reset to initial state
  void clearForm() {
    clearFormFields(); // Use base controller method
    resetFormKey(); // Reset the GlobalKey to avoid duplicate key errors in navigation
    otpReady.value = false;
    resendCooldown.value = 0;
    _resendTimer?.cancel();
  }

  /// Reset user data to initial state
  void resetUserData() {
    userData.value = UserModel(
      userId: "",
      userName: "",
      type: "",
      deptId: null,
      factId: null,
    );
    teacherData.value = TeacherModel(
      teacherId: "",
      teacherName: "",
      type: "",
      deptId: "",
    );
    isUserLoggedIn.value = false;
  }

  /// Restore user data from secure storage (used during auto-login)
  Future<void> restoreUserData() async {
    final savedData = await AccessController.getUserData();
    if (savedData != null) {
      final isSuperAdmin = savedData["is_super_admin"] == true;
      final isDean = savedData["is_dean"] == true;
      final isHod = savedData["is_hod"] == true;

      if (isSuperAdmin || isDean || isHod) {
        userData.value = UserModel.fromJson(savedData);
      } else {
        teacherData.value = TeacherModel.fromJson(savedData);
      }
      isUserLoggedIn.value = true;
    }
  }

  /// Check if current user is super admin
  bool get isSuperAdmin => userData.value.type.toLowerCase() == 'super_admin';

  /// Check if current user is dean
  bool get isDean => userData.value.type.toLowerCase() == 'dean';

  @override
  void onClose() {
    _resendTimer?.cancel();
    // Base form controller handles controller disposal
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers using base form controller
    emailController = registerController();
    otpController = registerController();
    
    _apiClient = ApiClient(
      tokenProvider: () => AccessController.getAccessToken(),
      // onUnauthorized: you can plug a token refresh handler here later
    );
    _authRepo = AuthRepository(_apiClient);
  }
}
