import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';

import '../../core/conf/api_routes.dart';
import '../../core/networks/api_client.dart';
import '../../core/networks/models/api_res.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/persistence.dart';
import 'storage_dto.dart';

class StorageService {
  StorageService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Upload a file to the storage service
  Future<ApiRes<UploadFileResponse>> uploadFile(
    UploadFileRequest request,
  ) async {
    try {
      final url = ApiRoutes.STORAGE.upload(request.type.value);

      // Prepare multipart request
      final uri = Uri.parse(url);
      final multipartRequest = http.MultipartRequest('POST', uri);

      // Add authorization header if token is available
      final token = await PersistenceUtils.readSecureString('auth_token');
      if (token?.isNotEmpty == true) {
        multipartRequest.headers['Authorization'] = 'Bearer $token';
      }

      // Add file to request
      final fileName = request.fileName ?? request.file.path.split('/').last;
      final mimeType =
          lookupMimeType(request.file.path) ?? 'application/octet-stream';

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        request.file.path,
        filename: fileName,
        contentType: http_parser.MediaType.parse(mimeType),
      );

      multipartRequest.files.add(multipartFile);

      Logger.info(
        'Uploading file: $fileName (${request.type.value})',
        tag: 'STORAGE',
      );

      // Send request
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response using ApiRes
      final apiResponse = ApiRes<UploadFileResponse>.fromJson(
        {
          'status': response.statusCode,
          'data': response.statusCode == 200 ? response.body : null,
          'error': response.statusCode != 200 ? response.body : null,
        },
        (data) {
          if (data is String) {
            // Parse JSON string
            final json = jsonDecode(data) as Map<String, dynamic>;
            return UploadFileResponse.fromJson(json);
          }
          return UploadFileResponse.fromJson(data as Map<String, dynamic>);
        },
      );

      if (apiResponse.isSuccess) {
        Logger.info('File uploaded successfully', tag: 'STORAGE');
      } else {
        Logger.error(
          'File upload failed',
          tag: 'STORAGE',
          error: apiResponse.error,
        );
      }

      return apiResponse;
    } catch (error) {
      Logger.error('Failed to upload file', tag: 'STORAGE', error: error);
      return ApiRes<UploadFileResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Delete a file from storage
  Future<ApiRes<void>> deleteFile(String publicId) async {
    try {
      final url = ApiRoutes.STORAGE.delete(publicId);
      final response = await _apiClient.delete(url);

      return ApiRes<void>.fromJson(response, (data) => data);
    } catch (error) {
      Logger.error('Failed to delete file', tag: 'STORAGE', error: error);
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
