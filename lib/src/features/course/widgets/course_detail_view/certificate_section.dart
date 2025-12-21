import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/dto/certificate_responses.dart';
import '../../providers/certificate_provider.dart';

class CertificateSection extends ConsumerWidget {
  final String? enrollmentId;
  final AsyncValue<CertStatusResponse>? certStatusAsync;

  const CertificateSection({
    super.key,
    this.enrollmentId,
    this.certStatusAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = (Theme.of(context));
    final status = certStatusAsync?.asData?.value.status;
    final certificateUrl = certStatusAsync?.asData?.value.certificateUrl;
    final isCertLoading = certStatusAsync == null || certStatusAsync!.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Certificate', style: theme.typography.small),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isCertLoading
                  ? 'Checking status...'
                  : (status == 'Available'
                        ? 'Ready for download'
                        : 'Get your certificate'),
              style: theme.typography.small,
            ),
            const Gap(8),
            if (isCertLoading)
              const Center(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(),
                ),
              )
            else if (status == 'Available' && certificateUrl != null)
              Column(
                children: [
                  Button.ghost(
                    onPressed: () async =>
                        await launchUrlString(certificateUrl),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.award, size: 18),
                        Gap(8),
                        Text('View'),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Button.primary(
                    onPressed: () async {
                      if (enrollmentId == null) return;
                      final response = await ref
                          .read(certificateServiceProvider)
                          .downloadCert(enrollmentId!);
                      if (response.isSuccess &&
                          response.data?.downloadUrl != null) {
                        await launchUrlString(response.data!.downloadUrl!);
                      } else {
                        showToast(
                          context: context,
                          builder: (ctx2, overlay) => Alert.destructive(
                            title: const Text('Download Failed'),
                            content: Text(
                              response.error?.toString() ??
                                  'Failed to download certificate',
                            ),
                            trailing: IconButton.ghost(
                              icon: const Icon(LucideIcons.x),
                              onPressed: overlay.close,
                            ),
                          ),
                          location: ToastLocation.bottomCenter,
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.download, size: 18),
                        Gap(8),
                        Text('Download'),
                      ],
                    ),
                  ),
                ],
              )
            else
              Button.primary(
                onPressed: enrollmentId != null
                    ? () async {
                        if (enrollmentId == null) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        final response = await ref
                            .read(certificateServiceProvider)
                            .generateCert(enrollmentId!);
                        if (context.mounted) Navigator.of(context).pop();
                        if (response.isSuccess) {
                          ref.invalidate(certStatusProvider(enrollmentId!));
                          showToast(
                            context: context,
                            builder: (ctx2, overlay) => Alert(
                              title: const Text('Success'),
                              content: const Text('Certificate generated'),
                              trailing: IconButton.ghost(
                                icon: const Icon(LucideIcons.x),
                                onPressed: overlay.close,
                              ),
                            ),
                            location: ToastLocation.bottomCenter,
                          );
                        } else {
                          showToast(
                            context: context,
                            builder: (ctx2, overlay) => Alert.destructive(
                              title: const Text('Generation Failed'),
                              content: Text(
                                response.error?.toString() ??
                                    'Failed to generate certificate',
                              ),
                              trailing: IconButton.ghost(
                                icon: const Icon(LucideIcons.x),
                                onPressed: overlay.close,
                              ),
                            ),
                            location: ToastLocation.bottomCenter,
                          );
                        }
                      }
                    : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.award, size: 18),
                    Gap(8),
                    Text('Generate'),
                  ],
                ),
              ),
          ],
        ),
        const Gap(12),
      ],
    );
  }
}
