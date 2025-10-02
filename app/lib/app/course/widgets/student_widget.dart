import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentWidget extends StatelessWidget {
  final StudentModel student;
  const StudentWidget({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // final buttonStyle = ButtonStyle(
    //   backgroundColor: WidgetStateProperty.all<Color>(Colors.white70),
    //   elevation: WidgetStateProperty.all<double>(0.1),
    //   shadowColor: WidgetStateProperty.all<Color>(Colors.white),
    // );
    final rowWidth = Get.size.width * 0.8;
    return Card(
      color: Get.theme.primaryColor.withOpacity(0.7),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: rowWidth,
                  child: Text(
                    student.studentName,
                    style: textStyle.copyWith(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: rowWidth,
                  child: Text(
                    student.studentId,
                    style: textStyle.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     ElevatedButton(
            //       style: buttonStyle,
            //       onPressed: () {},
            //       child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
