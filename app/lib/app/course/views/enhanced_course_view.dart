import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/core.dart';
import '../controllers/enhanced_course_controller.dart';
import '../models/student_attendence.dart';

/// Enhanced Course View using new widget library and architecture
class EnhancedCourseView extends GetView<EnhancedCourseController> {
  const EnhancedCourseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Course Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_report',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Generate Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          _buildAttendanceControls(),
          Expanded(child: _buildStudentsList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildStatsCard() {
    return Obx(() {
      final stats = controller.getAttendanceStats();
      return AppCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Students',
                    controller.students.length.toString(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Present Today',
                    stats['present'].toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Absent Today',
                    stats['absent'].toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (stats['total']! > 0) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: stats['percentage']! / 100.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                  stats['percentage']! >= 75 ? Colors.green : 
                  stats['percentage']! >= 50 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Attendance Rate: ${stats['percentage']}%',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: stats['percentage']! >= 75 ? Colors.green : 
                         stats['percentage']! >= 50 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceControls() {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sessions Count'),
                    const SizedBox(height: 4),
                    Obx(() => DropdownButtonFormField<int>(
                      value: controller.countedAs.value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(5, (index) => index + 1)
                          .map((count) => DropdownMenuItem(
                                value: count,
                                child: Text('$count Session${count > 1 ? 's' : ''}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateAttendanceCount(value);
                        }
                      },
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date'),
                    const SizedBox(height: 4),
                    Obx(() => InkWell(
                      onTap: () => _selectDate(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(_formatDate(controller.selectedDate.value)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LoadingButton(
                  text: 'Mark All Present',
                  onPressed: () => controller.markAllStudents(true),
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LoadingButton(
                  text: 'Mark All Absent',
                  onPressed: () => controller.markAllStudents(false),
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (controller.isLoadingStudents.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading students...'),
            ],
          ),
        );
      }

      if (controller.students.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.school,
          title: 'No Students Found',
          subtitle: 'This course doesn\'t have any enrolled students yet.',
        );
      }

      if (controller.attendanceMarked.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.how_to_reg, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Ready to Mark Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Initialize attendance to start marking.'),
              const SizedBox(height: 16),
              LoadingButton(
                text: 'Initialize Attendance',
                onPressed: controller.initializeAttendance,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.attendanceMarked.length,
        itemBuilder: (context, index) {
          final attendance = controller.attendanceMarked[index];
          return _buildStudentAttendanceCard(attendance, index);
        },
      );
    });
  }

  Widget _buildStudentAttendanceCard(StudentAttendanceList attendance, int index) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(Get.context!).primaryColor,
                child: Text(
                  attendance.studentName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ID: ${attendance.studentId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Sessions:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 8,
            children: List.generate(
              controller.countedAs.value,
              (sessionIndex) => FilterChip(
                label: Text('${sessionIndex + 1}'),
                selected: attendance.marked[sessionIndex],
                onSelected: (selected) {
                  controller.toggleAttendance(attendance.studentId, sessionIndex);
                },
                selectedColor: Colors.green[200],
                checkmarkColor: Colors.green[800],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (controller.attendanceMarked.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingButton(
          text: 'Submit Attendance',
          onPressed: controller.submitAttendance,
          isLoading: controller.isSubmittingAttendance.value,
          backgroundColor: Theme.of(Get.context!).primaryColor,
        ),
      );
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      controller.selectedDate.value = date;
      // Reinitialize attendance with new date
      if (controller.attendanceMarked.isNotEmpty) {
        controller.initializeAttendance();
      }
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'generate_report':
        controller.showReportDateRangePicker(context, 'Course Name');
        break;
      case 'settings':
        // Navigate to settings or show settings dialog
        Get.snackbar('Info', 'Settings feature coming soon!');
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}