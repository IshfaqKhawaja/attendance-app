import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import 'endpoints.dart';

typedef UnauthorizedHandler = Future<bool> Function();

class ApiClient {
  late final Dio _dio;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final Future<String?> Function()? tokenProvider;
  final UnauthorizedHandler? onUnauthorized;

  ApiClient({
    Dio? dio,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {"Accept": "application/json"},
    this.tokenProvider,
    this.onUnauthorized,
  }) {
    _dio = dio ?? Dio(BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      // sendTimeout causes issues on web for GET requests without body
      sendTimeout: kIsWeb ? null : timeout,
      headers: defaultHeaders,
      // Important for web CORS
      extra: {'withCredentials': false},
    ));
  }

  /// Normalize URL to ensure it's absolute
  String _normalizeUrl(String url) {
    return Endpoints.fullUrl(url);
  }

  Future<Map<String, String>> _authHeaders(Map<String, String> headers) async {
    final merged = {...defaultHeaders, ...headers};
    if (tokenProvider != null) {
      final token = await tokenProvider!.call();
      if (token != null && token.isNotEmpty) {
        merged['Authorization'] = 'Bearer $token';
      }
    }
    return merged;
  }

  Future<Map<String, dynamic>> getJson(String url, {Map<String, String>? headers}) async {
    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders(headers ?? const {});

    try {
      Response response = await _dio.get(
        normalizedUrl,
        options: Options(headers: mergedHeaders),
      );

      if (response.statusCode == 401 && onUnauthorized != null) {
        if (await onUnauthorized!.call()) {
          final retryHeaders = await _authHeaders(headers ?? const {});
          response = await _dio.get(
            normalizedUrl,
            options: Options(headers: retryHeaders),
          );
        }
      }

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      throw const FormatException('Invalid JSON payload: expected an object');
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders({
      'Content-Type': 'application/json',
      ...?headers,
    });

    try {
      Response response = await _dio.post(
        normalizedUrl,
        data: body,
        options: Options(headers: mergedHeaders),
      );

      if (response.statusCode == 401 && onUnauthorized != null) {
        if (await onUnauthorized!.call()) {
          final retryHeaders = await _authHeaders({
            'Content-Type': 'application/json',
            ...?headers,
          });
          response = await _dio.post(
            normalizedUrl,
            data: body,
            options: Options(headers: retryHeaders),
          );
        }
      }

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      throw const FormatException('Invalid JSON payload: expected an object');
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  Future<Map<String, dynamic>> putJson(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders({
      'Content-Type': 'application/json',
      ...?headers,
    });

    try {
      Response response = await _dio.put(
        normalizedUrl,
        data: body,
        options: Options(headers: mergedHeaders),
      );

      if (response.statusCode == 401 && onUnauthorized != null) {
        if (await onUnauthorized!.call()) {
          final retryHeaders = await _authHeaders({
            'Content-Type': 'application/json',
            ...?headers,
          });
          response = await _dio.put(
            normalizedUrl,
            data: body,
            options: Options(headers: retryHeaders),
          );
        }
      }

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      throw const FormatException('Invalid JSON payload: expected an object');
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  Future<Uint8List> postBytes(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders({
      'Content-Type': 'application/json',
      ...?headers,
    });

    try {
      Response<List<int>> response = await _dio.post(
        normalizedUrl,
        data: body,
        options: Options(
          headers: mergedHeaders,
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 401 && onUnauthorized != null) {
        if (await onUnauthorized!.call()) {
          final retryHeaders = await _authHeaders({
            'Content-Type': 'application/json',
            ...?headers,
          });
          response = await _dio.post(
            normalizedUrl,
            data: body,
            options: Options(
              headers: retryHeaders,
              responseType: ResponseType.bytes,
            ),
          );
        }
      }

      return Uint8List.fromList(response.data ?? []);
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  /// Upload File to Server (mobile only - web uses different approach)
  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String fileName,
    Map<String, String> fields, {
    String url = '',
    Map<String, String>? headers,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('File upload from path not supported on web. Use uploadFileBytes instead.');
    }

    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders(headers ?? const {});

    try {
      final formData = FormData.fromMap({
        ...fields,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        normalizedUrl,
        data: formData,
        options: Options(headers: mergedHeaders),
        onSendProgress: (int sent, int total) {
          if (total != 0) {
            debugPrint('Uploading... ${((sent / total) * 100).toStringAsFixed(0)}%');
          }
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Upload failed',
      );
    }
  }

  /// Upload file bytes (works on both web and mobile)
  Future<Map<String, dynamic>> uploadFileBytes(
    Uint8List bytes,
    String fileName,
    Map<String, String> fields, {
    String url = '',
    Map<String, String>? headers,
  }) async {
    final normalizedUrl = _normalizeUrl(url);
    final mergedHeaders = await _authHeaders(headers ?? const {});

    try {
      final formData = FormData.fromMap({
        ...fields,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        normalizedUrl,
        data: formData,
        options: Options(headers: mergedHeaders),
        onSendProgress: (int sent, int total) {
          if (total != 0) {
            debugPrint('Uploading... ${((sent / total) * 100).toStringAsFixed(0)}%');
          }
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw HttpException(
        e.response?.statusCode ?? 500,
        e.response?.data?.toString() ?? e.message ?? 'Upload failed',
      );
    }
  }

  void close() => _dio.close();
}

class HttpException implements Exception {
  final int statusCode;
  final String body;
  const HttpException(this.statusCode, this.body);

  @override
  String toString() => 'HttpException(status: $statusCode, body: $body)';
}
