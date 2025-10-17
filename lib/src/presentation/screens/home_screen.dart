import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../locale/index.dart';
import '../widgets/lang_btn.dart';
import '../widgets/theme_dropdown.dart';
import '../layouts/main_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainNavigationBar(
      child: Scaffold(
        headers: [AppBar(title: Text(l10n.appTitle))],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.welcomeMessage, style: Theme.of(context).typography.h3),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const ThemeDropdown(),
                  const SizedBox(width: 12),
                  const LangBtn(),
                ],
              ),
              const SizedBox(height: 8),

              // Hero section card using Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gettingStarted,
                        style: Theme.of(context).typography.h4,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.gettingStartedDescription),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Button.outline(
                            child: Text(l10n.browseCourses),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          Button.primary(
                            child: Text(l10n.startLearning),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(l10n.features, style: Theme.of(context).typography.h4),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildFeatureCard(
                    l10n.interactiveCoding,
                    l10n.interactiveCodingDescription,
                    Icons.code,
                  ),
                  _buildFeatureCard(
                    l10n.progressTracking,
                    l10n.progressTrackingDescription,
                    Icons.trending_up,
                  ),
                  _buildFeatureCard(
                    l10n.community,
                    l10n.communityDescription,
                    Icons.people,
                  ),
                  _buildFeatureCard(
                    l10n.certificates,
                    l10n.certificatesDescription,
                    Icons.workspace_premium,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick actions using Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickActions,
                        style: Theme.of(context).typography.h4,
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

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
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
