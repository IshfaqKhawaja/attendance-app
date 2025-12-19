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
      // Force light theme on web for consistency, use system on mobile
      themeMode: kIsWeb ? ThemeMode.light : ThemeMode.system,
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
      // Default route when URL doesn't match any route (for web)
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
      ),
      // Handle back button on web - prevent app from closing
      popGesture: !kIsWeb,
      // Add global error handling
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Page shown when route is not found (for web navigation)
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('The page you are looking for does not exist.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.LOADING),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
