import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/file_picker_controller.dart';

class FilePickerWidget extends StatelessWidget {
  FilePickerWidget({super.key});
  final FilePickerController controller = Get.put(FilePickerController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.size.height * 0.3,
      child: Column(
        children: [
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.pickAndParse,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(controller.fileName.value ?? 'Pick CSV or Excel'),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final data = controller.parsedData.value;
              if (data == null) {
                return const Center(child: Text('No file loaded'));
              }
              if (data is List<List<dynamic>>) {
                return _buildTable(data);
              }

              // Excel: Map<String, List<List<Data?>>>
              final sheets = data as Map<String, List<List<Data?>>>;
              return DefaultTabController(
                length: sheets.length,
                child: Column(
                  children: [
                    TabBar(
                      tabs: sheets.keys.map((name) => Tab(text: name)).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: sheets.values.map(_buildTable).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('Empty sheet'));
    }
    // Show only first 3 rows for preview
    final preview = rows.take(20).toList();
    final headers = preview.first;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: headers
            .map((c) => DataColumn(label: Text(c.toString())))
            .toList(),
        rows: preview.skip(1).map((row) {
          return DataRow(
            cells: row
                .map((cell) => DataCell(Text(cell?.toString() ?? '')))
                .toList(),
          );
        }).toList(),
      ),
    );
  }
}
