import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/text_styles.dart';
import '../controllers/edit_attendance_controller.dart';

class EditAttendanceDialog extends StatefulWidget {
  final String courseId;
  final String courseName;

  const EditAttendanceDialog({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<EditAttendanceDialog>
    with SingleTickerProviderStateMixin {
  late final EditAttendanceController controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      EditAttendanceController(
        courseId: widget.courseId,
        courseName: widget.courseName,
      ),
      tag: 'edit_${widget.courseId}',
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<EditAttendanceController>(tag: 'edit_${widget.courseId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = kIsWeb ? 600.0 : screenWidth * 0.95;
    final dialogHeight = screenHeight * 0.8;

    return Dialog(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Tab Bar
            _buildTabBar(),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildPreviousDayTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Attendance',
                  style: textStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.courseName,
                  style: textStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
      child: TabBar(
        controller: _tabController,
        labelColor: Get.theme.colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Get.theme.colorScheme.primary,
        tabs: [
          Obx(() => Tab(
                text: 'Today (${controller.formatDate(controller.todayDate.value)})',
              )),
          Obx(() => Tab(
                text: 'Previous (${controller.formatDate(controller.previousDate.value)})',
              )),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return Obx(() {
      if (controller.isLoadingToday.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.todayError.value.isNotEmpty) {
        return _buildErrorState(controller.todayError.value, controller.loadTodayAttendance);
      }

      return Column(
        children: [
          Expanded(
            child: _buildAttendanceList(
              controller.todayAttendance,
              isToday: true,
            ),
          ),
          _buildSaveButton(isToday: true),
        ],
      );
    });
  }

  Widget _buildPreviousDayTab() {
    return Obx(() {
      if (controller.isLoadingPrevious.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.previousError.value.isNotEmpty) {
        return _buildErrorState(controller.previousError.value, controller.loadPreviousDayAttendance);
      }

      return Column(
        children: [
          Expanded(
            child: _buildAttendanceList(
              controller.previousDayAttendance,
              isToday: false,
            ),
          ),
          _buildSaveButton(isToday: false),
        ],
      );
    });
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textStyle.copyWith(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(
    RxList<StudentAttendanceGroup> attendance, {
    required bool isToday,
  }) {
    if (attendance.isEmpty) {
      return const Center(
        child: Text('No attendance records'),
      );
    }

    // Check if any student has multiple slots
    final hasMultipleSlots = attendance.any((g) => g.totalSlots > 1);
    final maxSlots = attendance.isEmpty ? 1 : attendance.map((g) => g.totalSlots).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Select All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Obx(() {
            final allPresent = controller.areAllPresent(isToday: isToday);
            return Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (allPresent) {
                      controller.deselectAll(isToday: isToday);
                    } else {
                      controller.selectAllPresent(isToday: isToday);
                    }
                  },
                  icon: Icon(
                    allPresent ? Icons.deselect : Icons.select_all,
                    size: 16,
                  ),
                  label: Text(
                    allPresent ? "Deselect All" : "Select All Present",
                    style: textStyle.copyWith(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allPresent
                        ? Colors.grey
                        : Get.theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Student ID',
                        style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        hasMultipleSlots ? 'Present (0-$maxSlots)' : 'Present',
                        style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List.generate(
                    attendance.length,
                    (index) {
                      final group = attendance[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              group.studentId,
                              style: textStyle.copyWith(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                group.studentName,
                                style: textStyle.copyWith(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            group.totalSlots > 1
                                ? _buildDropdown(index, group, isToday)
                                : _buildCheckbox(index, group, isToday),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build dropdown for students with multiple slots
  Widget _buildDropdown(int index, StudentAttendanceGroup group, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: group.presentCount,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: List.generate(group.totalSlots + 1, (count) {
            return DropdownMenuItem<int>(
              value: count,
              child: Text(
                count == 0 ? '0 (Absent)' : '$count',
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: count == 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              if (isToday) {
                controller.updateTodayPresentCount(index, value);
              } else {
                controller.updatePreviousPresentCount(index, value);
              }
            }
          },
        ),
      ),
    );
  }

  /// Build checkbox for students with single slot
  Widget _buildCheckbox(int index, StudentAttendanceGroup group, bool isToday) {
    return Checkbox(
      value: group.presentCount > 0,
      activeColor: Get.theme.colorScheme.primary,
      onChanged: (_) {
        if (isToday) {
          controller.toggleTodayAttendance(index);
        } else {
          controller.togglePreviousAttendance(index);
        }
      },
    );
  }

  Widget _buildSaveButton({required bool isToday}) {
    return Obx(() {
      final hasChanges = isToday
          ? controller.hasChangesToday.value
          : controller.hasChangesPrevious.value;
      final isSaving = controller.isSaving.value;

      return Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasChanges && !isSaving
                ? () => _confirmAndSave(isToday: isToday)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    hasChanges ? 'Save Changes' : 'No Changes',
                    style: textStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
    });
  }

  void _confirmAndSave({required bool isToday}) {
    final dateLabel = isToday
        ? 'today (${controller.formatDate(controller.todayDate.value)})'
        : 'previous day (${controller.formatDate(controller.previousDate.value)})';

    Get.dialog(
      AlertDialog(
        title: Text(
          'Confirm Changes',
          style: textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to update attendance for $dateLabel?',
          style: textStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close confirmation dialog
              final success = await controller.saveChanges(isToday: isToday);
              if (success) {
                // Optionally close the main dialog after successful save
                // Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
