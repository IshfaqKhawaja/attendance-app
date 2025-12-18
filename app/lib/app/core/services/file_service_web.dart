import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Web implementation of file service
/// On web, files are downloaded to the user's default download location
class FileServiceImpl {
  static bool get isAndroid => false;

  static Future<String?> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? directory,
  }) async {
    try {
      // Create a data URL for download
      final base64Data = base64Encode(bytes);
      final mimeType = _getMimeType(fileName);
      final dataUrl = 'data:$mimeType;base64,$base64Data';

      // Create an anchor element and trigger download
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = dataUrl;
      anchor.download = fileName;
      anchor.style.display = 'none';
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();

      return fileName; // Return filename since we can't know actual path on web
    } catch (e) {
      // Log error silently on web
      return null;
    }
  }

  static Future<bool> openFile(String filePath) async {
    // On web, files are automatically downloaded, can't open them
    return false;
  }

  static Future<void> shareFile(String filePath, {String? text}) async {
    // On web, sharing is limited
  }

  static String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'csv':
        return 'text/csv';
      case 'pdf':
        return 'application/pdf';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }
}
