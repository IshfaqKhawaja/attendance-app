/// Stub implementations for dart:io types on web
/// These are never actually used on web since teachers are blocked,
/// but they allow the code to compile
library;

class File {
  final String path;
  File(this.path);

  Future<File> writeAsBytes(List<int> bytes) async => this;
  Future<List<int>> readAsBytes() async => [];
}

class Directory {
  final String path;
  Directory(this.path);
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
}

class SocketException implements Exception {
  final String message;
  SocketException(this.message);
}
