import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Core imports using barrel exports
import 'app/core/core.dart';
import 'app/core/injection/dependency_injection.dart';
import 'app/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection system
  await DependencyInjection.init();

  // Configure system UI (only for mobile platforms)
  if (!kIsWeb) {
    _configureSystemUI();
  }

  runApp(const AttendanceApp());
}

/// Configure system UI appearance (mobile only)
void _configureSystemUI() {
  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // Use scaffold background color (light grey) to avoid green showing through
    systemNavigationBarColor: Color(0xFFF5F5F7),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    // Dark icons for light background
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: ConfigService.to.appName,
      initialRoute: Routes.LOADING,
      getPages: Pages.routes,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // Add scroll behavior for web (enables mouse scroll)
      scrollBehavior: kIsWeb
          ? const MaterialScrollBehavior().copyWith(
              scrollbars: true,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            )
          : null,
      // Add global error handling
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
