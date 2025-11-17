import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptor.dart';
import 'exception.dart';
import '../utils/logger.dart';

class ApiClient {
  final ApiInterceptor _interceptor;
  final http.Client _client;

  ApiClient._(this._client) : _interceptor = ApiInterceptor(client: _client);

  /// Creates an [ApiClient]
  /// Set [allowSelfSigned] to true to allow invalid/self-signed certificates
  factory ApiClient({bool? allowSelfSigned, http.Client? client}) {
    final effectiveAllowSelfSigned =
        allowSelfSigned ??
        (dotenv.env['ALLOW_SELF_SIGNED_CERTS']?.toLowerCase() == 'true');
    final http.Client resolvedClient =
        client ?? _buildClient(effectiveAllowSelfSigned);
    return ApiClient._(resolvedClient);
  }

  static http.Client _buildClient(bool allowSelfSigned) {
    // On web, IOClient / dart:io isn't supported
    if (kIsWeb) return http.Client();

    if (allowSelfSigned) {
      final ioc = io.HttpClient();
      ioc.badCertificateCallback = (cert, host, port) => true;
      return IOClient(ioc);
    }
    return http.Client();
  }

  Future<void> close() async {
    _client.close();
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _interceptor.interceptRequest(
      url,
      'GET',
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final response = await _interceptor.interceptRequest(
      url,
      'POST',
      headers: headers,
      body: body,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final response = await _interceptor.interceptRequest(
      url,
      'PUT',
      headers: headers,
      body: body,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _interceptor.interceptRequest(
      url,
      'DELETE',
      headers: headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        Logger.error('Failed to parse response JSON', tag: 'API', error: e);
        throw ApiException('Invalid response format');
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access');
    } else {
      final message = _extractErrorMessage(response);
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
    } catch (_) {}
    return 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
  }
}
