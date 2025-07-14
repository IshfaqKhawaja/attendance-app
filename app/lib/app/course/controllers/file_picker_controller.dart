import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class FilePickerController extends GetxController {
  /// Raw bytes of the picked file
  Rx<Uint8List?> fileBytes = Rx<Uint8List?>(null);

  /// Name of the picked file
  RxnString fileName = RxnString();

  /// Parsed CSV rows or Excel sheets
  Rx<dynamic> parsedData = Rx<dynamic>(null);

  /// True while loading/parsing
  RxBool isLoading = false.obs;

  Future<void> pickAndParse() async {
    isLoading.value = true;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true,
    );

    if (result == null) {
      isLoading.value = false;
      return; // user cancelled
    }

    final file = result.files.single;
    fileName.value = file.name;
    fileBytes.value = file.bytes;

    final name = file.name.toLowerCase();
    final bytes = file.bytes!;

    if (name.endsWith('.csv')) {
      final content = utf8.decode(bytes);
      parsedData.value = const CsvToListConverter().convert(content);
    } else {
      final excel = Excel.decodeBytes(bytes);
      final Map<String, List<List<Data?>>> sheets = {};
      for (final sheet in excel.sheets.keys) {
        sheets[sheet] = excel.sheets[sheet]!.rows;
      }
      parsedData.value = sheets;
    }

    isLoading.value = false;
  }
}
