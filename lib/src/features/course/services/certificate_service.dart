import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/certificate_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/certificate.dart';

class CertificateService {
  CertificateService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<Certificate>> generateCert(String enrollmentId) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.CERTIFICATE.generate(enrollmentId),
      );
      return ApiRes<Certificate>.fromJson(
        response,
        (data) => Certificate.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to generate certificate',
        tag: 'CERTIFICATE',
        error: error,
      );
      return ApiRes<Certificate>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<List<Certificate>>> getMyCerts() async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.CERTIFICATE.myCertificates(),
      );
      return ApiRes<List<Certificate>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Certificate.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch certificates',
        tag: 'CERTIFICATE',
        error: error,
      );
      return ApiRes<List<Certificate>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<CertStatusResponse>> getCertStatus(String enrollmentId) async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.CERTIFICATE.status(enrollmentId),
      );
      return ApiRes<CertStatusResponse>.fromJson(
        response,
        (data) => CertStatusResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to get certificate status',
        tag: 'CERTIFICATE',
        error: error,
      );
      return ApiRes<CertStatusResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<DownloadCertResponse>> downloadCert(String enrollmentId) async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.CERTIFICATE.download(enrollmentId),
      );
      return ApiRes<DownloadCertResponse>.fromJson(
        response,
        (data) => DownloadCertResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to download certificate',
        tag: 'CERTIFICATE',
        error: error,
      );
      return ApiRes<DownloadCertResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
