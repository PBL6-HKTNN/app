import 'package:codemy_app/src/presentation/widgets/lang_btn.dart';
import 'package:codemy_app/src/presentation/widgets/theme_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/auth_providers.dart';
import '../../../presentation/layouts/main_navigation_bar.dart';
import '../../../locale/index.dart';

class UserMenuScreen extends ConsumerWidget {
  const UserMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    if (!authState.isAuthenticated || authState.user == null) {
      return MainNavigationBar(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.notAuthenticated),
              const SizedBox(height: 16),
              Button.primary(
                onPressed: () => context.go('/login'),
                child: Text(l10n.goToLogin),
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
                Text(l10n.userProfile, style: Theme.of(context).typography.h1),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture & Name
                    Row(
                      children: [
                        if (user.profilePicture.isNotEmpty)
                          Avatar(
                            initials: user.name[0].toUpperCase(),
                            provider: NetworkImage(user.profilePicture),
                          )
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
                              PrimaryBadge(
                                child: Text(_getRoleText(user.role)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Button to open Profile screen
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button.primary(
                  onPressed: () => context.go('/profile'),
                  child: const Text('View profile'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settings Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settings, style: Theme.of(context).typography.h4),
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
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 8),
                        Text(l10n.loggingOut),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text(l10n.logout),
                      ],
                    ),
            ),
          ],
        ),
      ),
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
}
