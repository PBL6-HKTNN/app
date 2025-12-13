import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../features/user/providers/auth_providers.dart';
import '../../locale/index.dart';
import '../layouts/main_navigation_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);

    final welcomeText = authState.isAuthenticated && authState.user != null
        ? l10n.helloUser(authState.user!.name)
        : l10n.welcomeMessage;
    return MainNavigationBar(
      child: Scaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(welcomeText, style: Theme.of(context).typography.h3),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // LangBtn and ThemeDropdown removed - implemented elsewhere
                ],
              ),
              const SizedBox(height: 8),

              // Hero section card using Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gettingStarted,
                        style: Theme.of(context).typography.large,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.gettingStartedDescription),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Button.outline(
                            child: Text(l10n.browseCourses),
                            onPressed: () {
                              context.push('/courses');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick actions using Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickActions,
                        style: Theme.of(context).typography.large,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickAction(
                        context,
                        l10n.continueLastLesson,
                        l10n.continueLastLessonDescription,
                        Icons.play_arrow,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickAction(
                        context,
                        l10n.viewProfile,
                        l10n.viewProfileDescription,
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickAction(
                        context,
                        l10n.browseLibrary,
                        l10n.browseLibraryDescription,
                        Icons.library_books,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickAction(
                        context,
                        'Login', // TODO: Add to l10n
                        'Navigate to login screen for testing',
                        Icons.login,
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return Button.outline(
      onPressed: onPressed ?? () {},
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ],
      ),
    );
  }
}
