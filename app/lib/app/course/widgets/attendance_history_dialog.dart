import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_history_controller.dart';

/// Dialog to view attendance history for a course
/// Read-only view for all users (HOD, Teacher, Super Admin)
class AttendanceHistoryDialog extends StatelessWidget {
  final String courseId;
  final String courseName;

  const AttendanceHistoryDialog({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  static Future<void> show({
    required BuildContext context,
    required String courseId,
    required String courseName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttendanceHistoryDialog(
        courseId: courseId,
        courseName: courseName,
      ),
    );
  }

  // Check if we're on a small screen (mobile)
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AttendanceHistoryController(courseId: courseId, courseName: courseName),
      tag: 'history_$courseId',
    );

    final isMobile = _isMobile(context);

    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Container(
        width: MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
        height: MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.85),
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 900,
          maxHeight: isMobile ? double.infinity : 700,
        ),
        child: Column(
          children: [
            _buildHeader(context, controller),
            _buildDateRangeSelector(context, controller),
            Expanded(child: _buildContent(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AttendanceHistoryController controller) {
    final isMobile = _isMobile(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.white, size: isMobile ? 20 : 24),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  courseName,
                  style: TextStyle(color: Colors.white70, fontSize: isMobile ? 12 : 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Get.delete<AttendanceHistoryController>(tag: 'history_$courseId');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(
      BuildContext context, AttendanceHistoryController controller) {
    final isMobile = _isMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(context, controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range, size: isMobile ? 18 : 20),
                        SizedBox(width: isMobile ? 4 : 8),
                        Flexible(
                          child: Text(
                            '${controller.formatDateDisplay(controller.startDate.value)} - ${controller.formatDateDisplay(controller.endDate.value)}',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: isMobile ? 18 : 20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 4 : 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.loadHistory,
                tooltip: 'Refresh',
                iconSize: isMobile ? 20 : 24,
              ),
            ],
          )),
    );
  }

  Future<void> _selectDateRange(
      BuildContext context, AttendanceHistoryController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildContent(BuildContext context, AttendanceHistoryController controller) {
    final isMobile = _isMobile(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.loadHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.days.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No attendance records found\nfor the selected date range',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      // Use different layouts for mobile vs desktop
      if (isMobile) {
        return _buildMobileContent(context, controller);
      } else {
        return _buildDesktopContent(controller);
      }
    });
  }

  // Mobile layout: Stacked with expandable date tiles
  Widget _buildMobileContent(BuildContext context, AttendanceHistoryController controller) {
    return Obx(() {
      final selectedDay = controller.selectedDay.value;

      return Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.days.length} Days',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Avg: ${controller.summary['avgAttendance'].toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // Date dropdown selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<DayAttendanceData>(
              value: selectedDay,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                labelText: 'Select Date',
              ),
              items: controller.days.map((day) {
                return DropdownMenuItem<DayAttendanceData>(
                  value: day,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          controller.formatDateWithDay(day.date),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMiniChip('${day.presentCount}P', Colors.green.shade100, Colors.green.shade700),
                          const SizedBox(width: 4),
                          _buildMiniChip('${day.absentCount}A', Colors.red.shade100, Colors.red.shade700),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (day) {
                if (day != null) {
                  controller.selectDay(day);
                }
              },
            ),
          ),
          // Selected day details
          Expanded(
            child: selectedDay == null
                ? const Center(child: Text('Select a date above'))
                : _buildMobileDayDetails(controller, selectedDay),
          ),
        ],
      );
    });
  }

  Widget _buildMobileDayDetails(AttendanceHistoryController controller, DayAttendanceData day) {
    final students = day.studentsAttendance;

    return Column(
      children: [
        // Day summary header
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.totalStudents} students',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${day.presentCount} present | ${day.absentCount} absent',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              _buildPercentageBadge(day.attendancePercentage, small: true),
            ],
          ),
        ),
        // Student list
        Expanded(
          child: students.isEmpty
              ? Center(
                  child: Text(
                    'No students found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildMobileStudentRow(student, day.slotsCount);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMobileStudentRow(StudentDayAttendance student, int totalSlots) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Status icon
          CircleAvatar(
            radius: 14,
            backgroundColor: student.isPresent ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              student.isPresent ? Icons.check : Icons.close,
              size: 14,
              color: student.isPresent ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 10),
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  student.studentId,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Class indicators (if multiple classes)
          if (totalSlots > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: student.slots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    slot.present ? Icons.check : Icons.close,
                    size: 16,
                    color: slot.present ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Desktop layout: Side by side panels
  Widget _buildDesktopContent(AttendanceHistoryController controller) {
    return Row(
      children: [
        // Left panel - Date list
        SizedBox(
          width: 200,
          child: _buildDateList(controller),
        ),
        VerticalDivider(width: 1, color: Colors.grey.shade300),
        // Right panel - Day details with student list
        Expanded(child: _buildDayDetails(controller)),
      ],
    );
  }

  Widget _buildDateList(AttendanceHistoryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.days.length} Days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Avg: ${controller.summary['avgAttendance'].toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        // Date list
        Expanded(
          child: ListView.builder(
            itemCount: controller.days.length,
            itemBuilder: (context, index) {
              final day = controller.days[index];
              final isSelected = controller.selectedDay.value?.date == day.date;

              return InkWell(
                onTap: () => controller.selectDay(day),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : null,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 3,
                      ),
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatDateWithDay(day.date),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildMiniChip(
                            '${day.presentCount}P',
                            Colors.green.shade100,
                            Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          _buildMiniChip(
                            '${day.absentCount}A',
                            Colors.red.shade100,
                            Colors.red.shade700,
                          ),
                          const Spacer(),
                          Text(
                            '${day.attendancePercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getPercentageColor(day.attendancePercentage),
                            ),
                          ),
                        ],
                      ),
                      // Show classes info if multiple attendance classes
                      if (day.slotsCount > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${day.slotsCount} classes',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayDetails(AttendanceHistoryController controller) {
    return Obx(() {
      final day = controller.selectedDay.value;
      if (day == null) {
        return const Center(child: Text('Select a date to view student attendance'));
      }

      final students = day.studentsAttendance;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatDateWithDay(day.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.totalStudents} students | ${day.presentCount} present | ${day.absentCount} absent',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (day.slotsCount > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${day.slotsCount} classes taken',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildPercentageBadge(day.attendancePercentage),
              ],
            ),
          ),
          // Student list header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (day.slotsCount > 1)
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Classes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          // Student list
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Text(
                      'No students found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentRow(student, day.slotsCount);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildStudentRow(StudentDayAttendance student, int totalSlots) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Student avatar and info
          CircleAvatar(
            radius: 16,
            backgroundColor: student.isPresent ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              student.isPresent ? Icons.check : Icons.close,
              size: 16,
              color: student.isPresent ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  student.studentId,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Class indicators (if multiple classes) - show tick/cross icons
          if (totalSlots > 1)
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: student.slots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      slot.present ? Icons.check : Icons.close,
                      size: 20,
                      color: slot.present ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPercentageBadge(double percentage, {bool small = false}) {
    final color = _getPercentageColor(percentage);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12, vertical: small ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: small ? 13 : 16,
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green.shade700;
    if (percentage >= 75) return Colors.orange.shade700;
    if (percentage >= 60) return Colors.orange.shade900;
    return Colors.red.shade700;
  }
}
