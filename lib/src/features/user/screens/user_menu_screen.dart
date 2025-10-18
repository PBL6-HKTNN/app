import 'package:codemy_app/src/presentation/widgets/lang_btn.dart';
import 'package:codemy_app/src/presentation/widgets/theme_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/auth_providers.dart';
import '../../../presentation/providers/theme_provider.dart';
import '../../../presentation/layouts/main_navigation_bar.dart';

class UserMenuScreen extends ConsumerWidget {
  const UserMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final currentTheme = ref.watch(themeModeProvider);

    if (!authState.isAuthenticated || authState.user == null) {
      return MainNavigationBar(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not authenticated'),
              const SizedBox(height: 16),
              Button.primary(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final user = authState.user!;

    return MainNavigationBar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User Profile', style: Theme.of(context).typography.h1),
                Button.ghost(
                  onPressed: () => context.go('/'),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture & Name
                    Row(
                      children: [
                        if (user.profilePicture.isNotEmpty)
                          Avatar(initials: user.name[0].toUpperCase(), size: 64)
                        else
                          Avatar(
                            initials: user.name[0].toUpperCase(),
                            size: 64,
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: Theme.of(context).typography.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // User Details
                    _buildInfoRow(context, 'Role', _getRoleText(user.role)),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Email Verified',
                      user.emailVerified ? 'Yes' : 'No',
                      valueColor: user.emailVerified
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.destructive,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Total Courses',
                      user.totalCourses.toString(),
                    ),
                    if (user.rating != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Rating',
                        user.rating!.toStringAsFixed(1),
                      ),
                    ],
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      Text('Bio', style: Theme.of(context).typography.semiBold),
                      const SizedBox(height: 8),
                      Text(
                        user.bio!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: Theme.of(context).typography.h4),
                    const SizedBox(height: 16),

                    // Theme Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(BootstrapIcons.lightbulbFill, size: 20),
                            const SizedBox(width: 12),
                            const Text('Theme'),
                          ],
                        ),
                        const ThemeDropdown(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.languages, size: 20),
                            const SizedBox(width: 12),
                            const Text('Language'),
                          ],
                        ),
                        const LangBtn(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Button.destructive(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      await authNotifier.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
              child: authState.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 8),
                        Text('Logging out...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).typography.semiBold.copyWith(color: valueColor),
        ),
      ],
    );
  }

  String _getRoleText(int role) {
    switch (role) {
      case 0:
        return 'Admin';
      case 1:
        return 'Instructor';
      case 2:
        return 'Student';
      default:
        return 'Unknown';
    }
  }

  IconData _getThemeIcon(ShadcnThemeMode themeMode) {
    switch (themeMode) {
      case ShadcnThemeMode.light:
        return Icons.wb_sunny;
      case ShadcnThemeMode.dark:
        return Icons.nightlight_round;
      case ShadcnThemeMode.system:
        return Icons.settings_brightness;
    }
  }
}
