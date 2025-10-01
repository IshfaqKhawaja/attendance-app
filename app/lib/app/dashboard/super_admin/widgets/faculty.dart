


import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class Faculty extends StatelessWidget {
  final String factName;
  final String factId;
  const Faculty({super.key, required this.factName, required this.factId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: () {
          Get.toNamed(Routes.DEPARTMENTS, arguments: {'factId': factId, 'factName': factName});
        },
        title: Text(factName, style : textStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        ),
        subtitle: Text('ID: $factId', style: textStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),),
      ),
    );
  }
}