import 'dart:convert';

import 'package:app/app/routes/app_routes.dart';
import 'package:app/app/signin/models/teacher_model.dart';
import 'package:app/app/signin/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// Local Imports
import '../../register/views/register.dart';
import '../../constants/network_constants.dart';
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
    final body = jsonEncode({"email_id": email});
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/authenticate/send_otp"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        Get.snackbar("OTP Sent to:", email, colorText: Colors.white);
        otpReady.value = true;
      } else {
        Get.snackbar(
          "Error",
          "Server returned \${response.statusCode}",
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
    isLoading.value = false;
    final otp = otpController.text.trim();
    final email = emailController.text.trim();
    final body = jsonEncode({"email_id": email, "otp": otp});
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/authenticate/verify_otp"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        final success = res["success"];
        final isRegistered = res["is_registered"];
        final isRegularUser = res["is_regular_user"];
        if (success) {
          if(!isRegularUser) {
            // THen the user is not a regular teacher:
            userData.value = UserModel.fromJson(res);
            if(userData.value.type == "HOD"){
              Get.offAllNamed(Routes.HOD_DASHBOARD);
            }
            // Same for SUPER USER and DEANS
          }
          else if (isRegistered) {
            teacherData.value = TeacherModel.fromJson(res);
            AccessController.saveTokens(
              res["access_token"],
              res["refresh_token"],
            );
            // Route to Dashboard
            Get.offAllNamed(Routes.TEACHER_DASHBOARD);
          } else {
            Get.dialog(
              RegisterTeacher(),
              useSafeArea: true,
              barrierDismissible: false,
            );
          }
        } else {
          // Handle Unsuccessful cases:::
          Get.snackbar("ERROR", res["message"], colorText: Colors.red);
        }
        otpReady.value = true;
      } else {
        Get.snackbar("Error", "Occured", colorText: Colors.white);
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
}
