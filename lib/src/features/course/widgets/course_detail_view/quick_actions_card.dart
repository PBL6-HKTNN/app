import 'package:codemy_app/src/features/course/enums/enrollment.dart';
import 'package:codemy_app/src/features/course/models/dto/certificate_responses.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/entities/module.dart';
import 'certificate_section.dart';

class QuickActionsCard extends StatelessWidget {
  final String courseId;
  final List<Module> modules;
  final ProgressStatus parsedProgress;
  final String? enrollmentId;
  final AsyncValue? certStatusAsync;
  final void Function(BuildContext, String, List<Module>) onStartLearning;

  const QuickActionsCard({
    super.key,
    required this.courseId,
    required this.modules,
    required this.parsedProgress,
    required this.enrollmentId,
    required this.certStatusAsync,
    required this.onStartLearning,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: theme.typography.h4),
            const Gap(12),
            Button.primary(
              onPressed: modules.isNotEmpty
                  ? () => onStartLearning(context, courseId, modules)
                  : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.play, size: 18),
                  Gap(8),
                  Text('Start Learning'),
                ],
              ),
            ),
            const Gap(12),
            Button.ghost(
              onPressed: () => context.push('/course/$courseId/reviews'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.messageSquare, size: 18),
                  Gap(8),
                  Text('View Reviews'),
                ],
              ),
            ),
            const Gap(12),
            if (parsedProgress == ProgressStatus.completed)
              CertificateSection(
                enrollmentId: enrollmentId,
                certStatusAsync:
                    certStatusAsync as AsyncValue<CertStatusResponse>?,
              ),
          ],
        ),
      ),
    );
  }
}
