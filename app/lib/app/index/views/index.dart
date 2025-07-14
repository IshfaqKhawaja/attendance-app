import 'package:app/app/index/controllers/index_controller.dart';
import 'package:app/app/dashboard/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../constants/text_styles.dart';

class IndexPage extends StatelessWidget {
  IndexPage({super.key});
  final IndexController controller = Get.put(IndexController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.index.value;
      return Scaffold(
        appBar: AppBar(title: Text('JMI Attendance', style: appBarTextStyle)),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => controller.tap(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.userPlus,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 4),
                      Text("Add Students", style: iconTextStyle),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.checkCircle,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 4),
                    Text("Attendance", style: iconTextStyle),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.fileExcel,
                      size: 80,
                      color: const Color.fromARGB(255, 9, 74, 124),
                    ),
                    SizedBox(height: 4),
                    Text("Generate Report", style: iconTextStyle),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.edit,
                      size: 80,
                      color: const Color.fromARGB(255, 221, 122, 60),
                    ),
                    SizedBox(height: 4),
                    Text("Edit Data", style: iconTextStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(),
      );
    });
  }
}
