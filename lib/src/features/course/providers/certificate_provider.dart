import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/certificate_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/certificate.dart';
import 'package:codemy_app/src/features/course/services/certificate_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final certificateServiceProvider = Provider<CertificateService>((ref) {
  return CertificateService();
});

final myCertificatesProvider = FutureProvider.autoDispose<List<Certificate>>((
  ref,
) async {
  final service = ref.read(certificateServiceProvider);
  final response = await service.getMyCerts();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load certificates',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final generateCertificateProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, enrollmentId) async {
      final service = ref.read(certificateServiceProvider);
      final response = await service.generateCert(enrollmentId);
      if (!response.isSuccess) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to generate certificate',
          statusCode: response.status,
          data: null,
        );
      }
      return true;
    });

final certStatusProvider = FutureProvider.autoDispose
    .family<CertStatusResponse, String>((ref, enrollmentId) async {
      final service = ref.read(certificateServiceProvider);
      final response = await service.getCertStatus(enrollmentId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to fetch certificate status',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final downloadCertificateProvider = FutureProvider.autoDispose
    .family<String, String>((ref, enrollmentId) async {
      final service = ref.read(certificateServiceProvider);
      final response = await service.downloadCert(enrollmentId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to download certificate',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!.downloadUrl ?? '';
    });
