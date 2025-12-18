import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'file_service_mobile.dart' if (dart.library.html) 'file_service_web.dart'
    as file_impl;

/// Cross-platform file service for saving and sharing files
class FileService {
  /// Save bytes to a file and return the file path
  /// On web, this triggers a download instead
  static Future<String?> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? directory,
  }) async {
    return await file_impl.FileServiceImpl.saveFile(
      bytes: bytes,
      fileName: fileName,
      directory: directory,
    );
  }

  /// Open a file with the default application
  /// Returns true if successful
  static Future<bool> openFile(String filePath) async {
    return await file_impl.FileServiceImpl.openFile(filePath);
  }

  /// Share a file using the system share dialog
  static Future<void> shareFile(String filePath, {String? text}) async {
    await file_impl.FileServiceImpl.shareFile(filePath, text: text);
  }

  /// Check if file operations are supported
  static bool get isSupported => !kIsWeb;

  /// Check if running on Android
  static bool get isAndroid => file_impl.FileServiceImpl.isAndroid;
}
