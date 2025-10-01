import 'package:app/app/dashboard/super_admin/views/faculities.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  final SignInController signInController = Get.find<SignInController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Get.theme.primaryColor, Get.theme.primaryColorLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.1,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Welcome \n${signInController.userData.value.userName}",
                style: GoogleFonts.openSans(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.25,
            child: Container(
              height: Get.size.height * 0.01,
              width: Get.size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.26,
            child:Container(
              height: Get.size.height * 0.74,
              width: Get.size.width,
              color: Colors.white,
              child: Facilities(),
              // child: Text("Super Admin Dashboard"),
              ),
          ),
        ],
      ),
    );
  } 
}