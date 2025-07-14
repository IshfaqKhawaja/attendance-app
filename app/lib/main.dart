import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // your brand colors
    const primaryColor = Color(0xFF012B4A);
    const secondaryColor = Color(0xFF425C8C);
    const tertiaryColor = Color(0xFFEEF3F6);
    final tooltipTheme = TooltipThemeData(
      waitDuration: Duration(milliseconds: 300),
      showDuration: Duration(seconds: 2),
    );

    // start from a clean light theme…
    final baseLight = ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: tertiaryColor,
      // give both themes exactly the same Google-Fonts textTheme
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        // title style also comes from the same Lato family
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );

    final baseDark = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: tertiaryColor,
      textTheme: baseLight.textTheme,
      appBarTheme: baseLight.appBarTheme,
      tooltipTheme: tooltipTheme,
    );

    return GetMaterialApp(
      title: "JMI Attendance",
      initialRoute: Routes.LOADING,
      getPages: Pages.routes,
      theme: baseLight,
      darkTheme: baseDark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
