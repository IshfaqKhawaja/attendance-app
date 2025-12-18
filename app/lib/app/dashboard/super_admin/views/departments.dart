import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:app/app/dashboard/super_admin/widgets/department.dart';
import 'package:app/app/core/constants/app_colors.dart';
import 'package:app/app/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Departments extends StatefulWidget {
  final String factId;
  final String factName;
  const Departments({super.key, required this.factId, required this.factName});

  @override
  State<Departments> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<Departments> {
  final DepartmentController departmentController = Get.put(DepartmentController());

  static const double maxContentWidth = 1200;

  @override
  void initState() {
    super.initState();
    // Defer loading to after the build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      departmentController.loadDepartments(widget.factId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 768;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final crossAxisCount = ResponsiveUtils.value(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
      largeDesktop: 3,
    );

    return Scaffold(
      backgroundColor: kIsWeb ? AppColors.tertiary : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.factName,
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (departmentController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (departmentController.departments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No departments found',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? maxContentWidth : double.infinity,
            ),
            decoration: kIsWeb && isWideScreen
                ? BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Departments',
                            style: GoogleFonts.openSans(
                              fontSize: isDesktop ? 24 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${departmentController.departments.length} departments',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Departments Grid/List
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: crossAxisCount > 1
                        ? GridView.builder(
                            padding: EdgeInsets.all(isDesktop ? 24 : 16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: departmentController.departments.length,
                            itemBuilder: (context, index) {
                              final department = departmentController.departments[index];
                              return Department(
                                deptName: department.deptName,
                                deptId: department.deptId,
                                index: index,
                                useMargin: false,
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: departmentController.departments.length,
                            itemBuilder: (context, index) {
                              final department = departmentController.departments[index];
                              return Department(
                                deptName: department.deptName,
                                deptId: department.deptId,
                                index: index,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}