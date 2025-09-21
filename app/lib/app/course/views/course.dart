import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/typography.dart';
import '../../routes/app_routes.dart';
import '../controllers/course_controller.dart';
import 'attendence.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final TeacherCourseModel course = Get.arguments["course"];

 late CourseController courseController;


void loadStudentsData() async{
  await courseController.getStudentsList();
  await courseController.getStudentsForAttendence();
}
 
 @override
 void initState() {
    super.initState();
    courseController = Get.put(CourseController(courseId: course.courseId), permanent: true);
    loadStudentsData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            top: Get.size.height * 0.085,
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              width: Get.size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Course Info",
                    style: GoogleFonts.openSans(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Students List Button
                  ElevatedButton(
                    child: Text("Students", style: textStyle.copyWith(fontSize: 13,),),
                    onPressed: (){
                      Get.toNamed(Routes.STUDENTS, arguments: {"course": course});
                      },                   
                  ),
                ElevatedButton(
                  onPressed: (){
                    courseController.showDateRangeDialog(context, course.courseName!);
                      },                   
                    child: Text("Report",style: textStyle.copyWith(fontSize: 13,),),)
                ],
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.13,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Course Name: ${course.courseName}\nCourse ID : ${course.courseId}\nSem ID : ${course.semName}",
                style: GoogleFonts.openSans(fontSize: 14, color: Colors.white),
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
            child: Container(
              height: Get.size.height * 0.739,
              width: Get.size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(),
              ),
              child: Attendence(),
            ),
          ),
        ],
      ),
    );
  }
}
