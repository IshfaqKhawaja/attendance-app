import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile implementation of file service
class FileServiceImpl {
  static bool get isAndroid => Platform.isAndroid;

  static Future<String?> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? directory,
  }) async {
    try {
      Directory? dir;

      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  static Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      print('Error opening file: $e');
      return false;
    }
  }

  static Future<void> shareFile(String filePath, {String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: text,
      );
    } catch (e) {
      print('Error sharing file: $e');
    }
  }
}
