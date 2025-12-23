import 'package:app/app/semester/controllers/edit_semester_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditSemesterButton extends StatefulWidget {
  final String semId;
  final String semName;
  final String progId;
  final DateTime startDate;
  final DateTime endDate;
  const EditSemesterButton({super.key, required this.semId, required this.semName, required this.progId, required this.startDate, required this.endDate});

  @override
  State<EditSemesterButton> createState() => _EditSemesterButtonState();
}

class _EditSemesterButtonState extends State<EditSemesterButton> {
  late EditSemesterController editSemesterController = Get.put(EditSemesterController());

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  @override
  void initState() {
    super.initState();
    editSemesterController.initializeFields(
      semId: widget.semId,
      semName: widget.semName,
      start: widget.startDate,
      end: widget.endDate,
      progId: widget.progId
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final startDate = editSemesterController.startDate.value.value ?? widget.startDate;
      final endDate = editSemesterController.endDate.value.value ?? widget.endDate;

      return Container(
        padding: const EdgeInsets.all(20.0),
        width: kIsWeb ? null : Get.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
          maxHeight: Get.size.height * 0.55,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.edit, color: Get.theme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Semester',
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
              controller: editSemesterController.semesterNameController.value,
              style: GoogleFonts.openSans(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Date display
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
                  Expanded(
                    child: Text(
                      'Start: ${DateFormat('dd/MM/yyyy').format(startDate)}',
                      style: GoogleFonts.openSans(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 16),

            // Date Selection Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await editSemesterController.selectStartDate(context);
                    },
                    icon: Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      "Change Start",
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
                      await editSemesterController.selectEndDate(context);
                    },
                    icon: Icon(Icons.event, size: 18),
                    label: Text(
                      "Change End",
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

            // Save Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: Get.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () async {
                final edited = await editSemesterController.editSemester();
                if (context.mounted) {
                  Navigator.of(context).pop(edited);
                }
              },
              label: Text(
                'Save Changes',
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
    });
  }
}
