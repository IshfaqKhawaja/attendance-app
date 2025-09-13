import 'package:app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CardWidget extends StatelessWidget {
  final course;
  const CardWidget({required this.course});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.COURSE, arguments: {"course": course});
      },
      child: Card(
        color: Get.theme.primaryColor.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course:
              Text(
                course.courseName,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 20),
              ),
              // Sem Name
              Text(
                course.semName,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 16),
              ),
              // Prog Name:
              Text(
                course.progName,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 14),
              ),
              // Dept Name
              Text(
                course.deptName,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 12),
              ),
              // Fact Name
              Text(
                course.factName,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
