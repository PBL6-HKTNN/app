import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';
import '../utils/persistence.dart';
import 'exception.dart';

class ApiInterceptor {
  final http.Client _client;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiInterceptor({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> interceptRequest(
    String url,
    String method, {
    Map<String, String>? headers,
    dynamic body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    // Add authorization if available
    final token = await _getAuthToken();
    if (token != null) {
      mergedHeaders['Authorization'] = 'Bearer $token';
    }

    Logger.log('Request: $method $url', tag: 'API');
    if (body != null) Logger.log('Body: $body', tag: 'API');

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(Uri.parse(url), headers: mergedHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                Uri.parse(url),
                headers: mergedHeaders,
                body: jsonEncode(body),
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                Uri.parse(url),
                headers: mergedHeaders,
                body: jsonEncode(body),
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(Uri.parse(url), headers: mergedHeaders)
              .timeout(timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      Logger.log('Response: ${response.statusCode}', tag: 'API');

      return response;
    } catch (e) {
      Logger.error('Request failed', tag: 'API', error: e);
      if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      } else if (e is TimeoutException) {
        throw TimeoutException('Request timeout');
      } else {
        throw ApiException('Unknown error: $e');
      }
    }
  }

  Future<String?> _getAuthToken() async {
    return await PersistenceUtils.readSecureString('auth_token');
  }
}
