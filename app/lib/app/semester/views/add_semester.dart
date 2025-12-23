import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../semester/controllers/add_semester_controller.dart';

class AddSemester extends StatefulWidget {
  final String progId;
  const AddSemester({super.key, required this.progId});

  @override
  State<AddSemester> createState() => _AddSemesterState();
}

class _AddSemesterState extends State<AddSemester> {
  final AddSemesterController addSemesterController = Get.put(AddSemesterController());

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  @override
  void initState() {
    super.initState();
    addSemesterController.emptyFields();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.size.height * 0.55,
      ),
      child: Obx(() {
        final startDate = addSemesterController.startDate.value;
        final endDate = addSemesterController.endDate.value;
        return Form(
          child: ListView(
            shrinkWrap: true,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.add_circle, color: Get.theme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add New Semester',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Semester Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Semester Name *',
                  hintText: 'e.g., Fall 2024, Spring 2025',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: addSemesterController.semesterNameController.value,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Date display
              if (startDate != null || endDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range, color: Get.theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      if (startDate != null)
                        Expanded(
                          child: Text(
                            'Start: ${DateFormat('dd/MM/yyyy').format(startDate)}',
                            style: GoogleFonts.openSans(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (startDate != null && endDate != null)
                        const SizedBox(width: 8),
                      if (endDate != null)
                        Expanded(
                          child: Text(
                            'End: ${DateFormat('dd/MM/yyyy').format(endDate)}',
                            style: GoogleFonts.openSans(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              if (startDate != null || endDate != null)
                const SizedBox(height: 16),

              // Date Selection Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await addSemesterController.selectStartDate(context);
                      },
                      icon: Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        startDate == null ? "Select Start Date *" : "Change Start",
                        style: GoogleFonts.openSans(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await addSemesterController.selectEndDate(context);
                      },
                      icon: Icon(Icons.event, size: 18),
                      label: Text(
                        endDate == null ? "Select End Date *" : "Change End",
                        style: GoogleFonts.openSans(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final added = await addSemesterController.addSemester(widget.progId);
                  if (context.mounted) {
                    Navigator.of(context).pop(added);
                  }
                },
                label: Text(
                  'Add Semester',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
