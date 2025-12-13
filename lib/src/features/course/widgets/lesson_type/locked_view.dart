import 'package:shadcn_flutter/shadcn_flutter.dart';

class LockedLessonView extends StatelessWidget {
  final String lessonTitle;
  final String? message;

  const LockedLessonView({super.key, required this.lessonTitle, this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7), // orange[100] equivalent
                shape: BoxShape.circle,
              ),
              child: const Icon(
                BootstrapIcons.lock,
                size: 32,
                color: Color(0xFFEA580C), // orange[600] equivalent
              ),
            ),
            const Gap(24),
            Text(
              'Lesson Locked',
              style: Theme.of(context).typography.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC2410C), // orange[700] equivalent
              ),
            ),
            const Gap(12),
            Text(
              message ?? 'Complete previous lessons to unlock "$lessonTitle"',
              style: Theme.of(context).typography.p.copyWith(
                color: const Color(0xFF6B7280), // grey[600] equivalent
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // orange[50] equivalent
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFED7AA),
                ), // orange[200] equivalent
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    BootstrapIcons.infoCircle,
                    size: 16,
                    color: Color(0xFFEA580C), // orange[600] equivalent
                  ),
                  Gap(8),
                  Text(
                    'Sequential learning is enabled',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFC2410C), // orange[700] equivalent
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
