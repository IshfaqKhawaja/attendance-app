import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system UI overlay & edge-to-edge
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable edge-to-edge so content can draw under the status & nav bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Make status/navigation bars transparent (adjust icon brightness as needed).
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "JMI Attendance",
      initialRoute: Routes.LOADING,
      getPages: Pages.routes,
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
