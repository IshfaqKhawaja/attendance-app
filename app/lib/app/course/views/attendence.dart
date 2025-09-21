import 'package:app/app/course/controllers/course_controller.dart';
import 'package:app/app/course/widgets/attendence_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/drop_down_widget.dart';
import '../../constants/text_styles.dart';

class Attendence extends StatefulWidget {
   const Attendence({super.key});

  @override
  State<Attendence> createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
  final CourseController courseController = Get.find<CourseController>();
  @override
  void dispose() {
    super.dispose();
    courseController.clear();
  }
  @override
  Widget build(BuildContext context) {
    final height = Get.size.height;
    final width = Get.size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.04,
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                  style: textStyle.copyWith(fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      "Counted As : ",
                      style: textStyle.copyWith(fontSize: 14),
                    ),
                    DropDownWidget(),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 2, color: Get.theme.primaryColor),
          Container(
            height: height * 0.6,
            width: width,
            color: Colors.black12.withOpacity(0.1),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: AttendenceWidget(),
            ),
          ),

          Container(
            height: height * 0.06,
            width: width,
            padding: EdgeInsets.all(4),
            color: Colors.black12.withOpacity(0.1),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  padding: EdgeInsets.all(2), // Adjust size
                ),
                onPressed: () {
                  courseController.addAttendence();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add Attendance",
                      style: textStyle.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.save_as, color: Colors.white, size: 30),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }
}
