import 'package:shadcn_flutter/shadcn_flutter.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback onBack;
  final String message;
  const ErrorView({super.key, required this.onBack, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.triangleAlert, size: 48),
                const Gap(16),
                Text('Error Loading Course', style: theme.typography.h3),
                const Gap(8),
                Text(
                  message,
                  style: theme.typography.small,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Button.primary(
                  onPressed: onBack,
                  child: const Text('Back to Courses'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
