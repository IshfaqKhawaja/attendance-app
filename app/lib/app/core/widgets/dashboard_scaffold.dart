import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// A reusable scaffold for dashboard screens with a gradient header
/// and white content area. Automatically handles safe areas and responsive layouts.
/// On web, content is constrained to a max width for better readability.
class DashboardScaffold extends StatelessWidget {
  final Widget headerContent;
  final Widget bodyContent;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;

  /// Maximum content width for web/tablet layouts
  static const double maxContentWidth = 1200;

  /// Breakpoint for tablet/desktop layouts
  static const double tabletBreakpoint = 768;

  const DashboardScaffold({
    super.key,
    required this.headerContent,
    required this.bodyContent,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > tabletBreakpoint;

    return Scaffold(
      backgroundColor: kIsWeb ? AppColors.tertiary : Colors.white,
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? maxContentWidth : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isWideScreen ? 24 : 16,
                      16,
                      isWideScreen ? 24 : 16,
                      24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBackButton)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        Expanded(child: headerContent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // White content area with rounded top corners
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? maxContentWidth : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  // Add shadow on web for card-like appearance
                  boxShadow: kIsWeb && isWideScreen
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ]
                      : null,
                ),
                // Clip content to rounded corners
                clipBehavior: Clip.antiAlias,
                // Offset to cover the gradient behind rounded corners
                transform: Matrix4.translationValues(0, -16, 0),
                child: bodyContent,
              ),
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