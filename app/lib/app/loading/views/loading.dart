import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../signin/controllers/signin_controller.dart';
import '../controllers/loading_controller.dart';

/// A full-screen loading indicator with an optional logo and gradient background.
class LoadingScreen extends StatelessWidget {
  LoadingScreen({super.key});
  final LoadingController loadingController = Get.put(
    LoadingController(),
    permanent: true,
  );
  final SignInController controller = Get.put(
    SignInController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Get.theme.primaryColor,
              Get.theme.primaryColor.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      ),
    );
  }
}
