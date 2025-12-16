import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable scaffold for dashboard screens with a gradient header
/// and white content area. Automatically handles safe areas and responsive layouts.
class DashboardScaffold extends StatelessWidget {
  final Widget headerContent;
  final Widget bodyContent;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const DashboardScaffold({
    super.key,
    required this.headerContent,
    required this.bodyContent,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Gradient header section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: headerContent,
              ),
            ),
          ),
          // White content area with rounded top corners
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              // Clip content to rounded corners
              clipBehavior: Clip.antiAlias,
              // Offset to cover the gradient behind rounded corners
              transform: Matrix4.translationValues(0, -16, 0),
              child: bodyContent,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}