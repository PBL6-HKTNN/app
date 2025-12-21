import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({super.key});

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
                const Icon(LucideIcons.lock, size: 48),
                const Gap(16),
                Text('Access Denied', style: theme.typography.h3),
                const Gap(8),
                Text(
                  'You need to be logged in to access this course.',
                  style: theme.typography.small,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Button.primary(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
