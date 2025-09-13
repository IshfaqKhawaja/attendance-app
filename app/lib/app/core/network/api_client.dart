import 'dart:convert';

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

  void close() => _client.close();
}

class HttpException implements Exception {
  final int statusCode;
  final String body;
  const HttpException(this.statusCode, this.body);

  @override
  String toString() => 'HttpException(status: $statusCode, body: $body)';
}
