// json not needed after repository refactor

import 'package:app/app/routes/app_routes.dart';
import 'package:app/app/signin/models/teacher_model.dart';
import 'package:app/app/signin/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
// http no longer used directly after repository refactor
// Local Imports
import '../../register/views/register.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import 'access_controller.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final otpReady = false.obs;
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
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final email = emailController.text.trim();
    try {
    final res = await _authRepo.sendOtp(email);
    if ((res['success'] ?? false) == true) {
        // If backend returns an OTP in test/dev, surface it in debug mode
        final dynamic maybeOtp = res['otp'] ?? (res['data'] != null ? res['data']['otp'] : null);
        if (kDebugMode && maybeOtp != null) {
          // Print to console and show a temporary snackbar for quick copy
          // WARNING: Do not enable this in production builds.
          // ignore: avoid_print
          print('DEBUG OTP: ' + maybeOtp.toString());
          Get.snackbar('OTP (debug)', maybeOtp.toString(), colorText: Colors.white);
        }
        Get.snackbar("OTP Sent to:", email, colorText: Colors.white);
        otpReady.value = true;
      } else {
        Get.snackbar(
          "Error",
      res['message']?.toString() ?? 'Failed to send OTP',
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future verifyOtp() async {
    isLoading.value = true;
    final otp = otpController.text.trim();
    final email = emailController.text.trim();
    try {
      final res = await _authRepo.verifyOtp(email, otp);
      final success = res["success"] == true;
      final isRegistered = res["is_registered"] == true;
      final isRegularUser = res["is_regular_user"] == true;
      if (success) {
        if (!isRegularUser) {
          // Not a regular teacher: HOD/Dean/etc
          userData.value = UserModel.fromJson(res);
          if (userData.value.type == "HOD") {
            Get.offAllNamed(Routes.HOD_DASHBOARD);
          }
          // TODO: route other roles as needed
        } else if (isRegistered) {
          teacherData.value = TeacherModel.fromJson(res);
          await AccessController.saveTokens(
            res["access_token"],
            res["refresh_token"],
          );
          Get.offAllNamed(Routes.TEACHER_DASHBOARD);
        } else {
          Get.dialog(
            RegisterTeacher(),
            useSafeArea: true,
            barrierDismissible: false,
          );
        }
        otpReady.value = true;
      } else {
        Get.snackbar("ERROR", res["message"].toString(), colorText: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _apiClient = ApiClient(
      tokenProvider: () => AccessController.getAccessToken(),
      // onUnauthorized: you can plug a token refresh handler here later
    );
    _authRepo = AuthRepository(_apiClient);
  }
}
