

import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:app/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Department extends StatelessWidget {
  final String deptName;
  final String deptId;
  final int index;
  final bool useMargin;

  Department({
    super.key,
    required this.deptName,
    required this.deptId,
    required this.index,
    this.useMargin = true,
  });
  
  final DepartmentController departmentController = Get.find<DepartmentController>();

  // Icon for each department type
  IconData _getDepartmentIcon(String deptName) {
    final name = deptName.toLowerCase();
    if (name.contains('computer') || name.contains('cs') || name.contains('it')) {
      return Icons.computer;
    } else if (name.contains('electric') || name.contains('ee')) {
      return Icons.electrical_services;
    } else if (name.contains('mechanic') || name.contains('me')) {
      return Icons.precision_manufacturing;
    } else if (name.contains('civil')) {
      return Icons.architecture;
    } else if (name.contains('business') || name.contains('mba')) {
      return Icons.business_center;
    } else {
      return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: useMargin ? EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        child: InkWell(
          onTap: () {
            departmentController.navigateToHodDashboard(deptId);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Department Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Get.theme.primaryColor.withValues(alpha: 0.8),
                        Get.theme.primaryColorLight.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getDepartmentIcon(deptName),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                // Department Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        deptName,
                        style: GoogleFonts.openSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 13,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'ID: $deptId',
                              style: GoogleFonts.openSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}