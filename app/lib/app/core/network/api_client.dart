import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

typedef UnauthorizedHandler = Future<bool> Function();

class ApiClient {
  final http.Client _client;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final Future<String?> Function()? tokenProvider;
  final UnauthorizedHandler? onUnauthorized;

  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.defaultHeaders = const {"Accept": "application/json"},
    this.tokenProvider,
    this.onUnauthorized,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders(Map<String, String> headers) async {
    final merged = {...defaultHeaders, ...headers};
    if (tokenProvider != null) {
      final token = await tokenProvider!.call();
      if (token != null && token.isNotEmpty) {
        merged['Authorization'] = 'Bearer ' + token;
      }
    }
    return merged;
  }

  Future<Map<String, dynamic>> getJson(String url, {Map<String, String>? headers}) async {
    final mergedHeaders = await _authHeaders(headers ?? const {});
    Future<http.Response> run() => _client.get(Uri.parse(url), headers: mergedHeaders).timeout(timeout);
    http.Response res = await run();
    if (res.statusCode == 401 && onUnauthorized != null) {
      if (await onUnauthorized!.call()) {
        final retryHeaders = await _authHeaders(headers ?? const {});
        res = await _client.get(Uri.parse(url), headers: retryHeaders).timeout(timeout);
      }
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(res.statusCode, res.body);
    }
    final json = jsonDecode(res.body);
    if (json is Map<String, dynamic>) return json;
    throw const FormatException('Invalid JSON payload: expected an object');
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final mergedHeaders = await _authHeaders({
      'Content-Type': 'application/json',
      ...?headers,
    });
    Future<http.Response> run() => _client
        .post(Uri.parse(url), headers: mergedHeaders, body: jsonEncode(body))
        .timeout(timeout);
    http.Response res = await run();

    if (res.statusCode == 401 && onUnauthorized != null) {
      if (await onUnauthorized!.call()) {
        final retryHeaders = await _authHeaders({
          'Content-Type': 'application/json',
          ...?headers,
        });
        res = await _client
            .post(Uri.parse(url), headers: retryHeaders, body: jsonEncode(body))
            .timeout(timeout);
      }
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(res.statusCode, res.body);
    }
    final json = jsonDecode(res.body);
    if (json is Map<String, dynamic>) return json;
    throw const FormatException('Invalid JSON payload: expected an object');
  }

  Future<Uint8List> postBytes(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final mergedHeaders = await _authHeaders({
      'Content-Type': 'application/json',
      ...?headers,
    });
    Future<http.Response> run() => _client
        .post(Uri.parse(url), headers: mergedHeaders, body: jsonEncode(body))
        .timeout(timeout);
    http.Response res = await run();
    if (res.statusCode == 401 && onUnauthorized != null) {
      if (await onUnauthorized!.call()) {
        final retryHeaders = await _authHeaders({
          'Content-Type': 'application/json',
          ...?headers,
        });
        res = await _client
            .post(Uri.parse(url), headers: retryHeaders, body: jsonEncode(body))
            .timeout(timeout);
      }
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(res.statusCode, 'Binary response status: ${res.statusCode}');
    }
    return res.bodyBytes;
  }

  

// Upload File to Server:
Future<Map<String, dynamic>> uploadFile(
  String url,
  File file,
  String fileName,
  Map<String, String> fields, {
  Map<String, String>? headers,
}) async {
  final mergedHeaders = await _authHeaders(headers ?? const {});
  try {
    // 1. Create a FormData object to hold multipart data.
    final formData = FormData.fromMap({
      ...fields,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    // 2. Send the request using Dio with merged headers.
    final dio = Dio();
    dio.options.headers = mergedHeaders;
    final response = await dio.post(
      url,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (total != 0) {
          print('Uploading... ${((sent / total) * 100).toStringAsFixed(0)}%');
        }
      },
    );

    // 3. Handle the response.
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      return Map<String, dynamic>.from(data);
    } else {
      throw HttpException(response.statusCode ?? 500, response.data.toString());
    }
  } on DioException catch (e) { // More specific error handling for Dio
    throw HttpException(e.response?.statusCode ?? 500, e.response?.data?.toString() ?? e.message ?? e.toString());
  } catch (e) {
    throw HttpException(500, 'An unexpected error occurred: $e');
  }
}


void close() => _client.close();
}


class HttpException implements Exception {
  final int statusCode;
  final String body;
  const HttpException(this.statusCode, this.body);

  @override
  String toString() => 'HttpException(status: $statusCode, body: $body)';
}
