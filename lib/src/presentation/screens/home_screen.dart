import 'package:shadcn_flutter/shadcn_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: const Text('CodeMy App'))],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to CodeMy App',
              style: Theme.of(context).typography.h3,
            ),
            const SizedBox(height: 24),

            // Hero section card using Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Getting Started',
                      style: Theme.of(context).typography.h4,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learn programming with interactive lessons and modern tools.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Button.outline(
                          child: const Text('Browse Courses'),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        Button.primary(
                          child: const Text('Start Learning'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('Features', style: Theme.of(context).typography.h4),
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
                  'Interactive Coding',
                  'Practice coding with real-time feedback and hints.',
                  Icons.code,
                ),
                _buildFeatureCard(
                  'Progress Tracking',
                  'Monitor your learning progress and achievements.',
                  Icons.trending_up,
                ),
                _buildFeatureCard(
                  'Community',
                  'Connect with other learners and get help.',
                  Icons.people,
                ),
                _buildFeatureCard(
                  'Certificates',
                  'Earn certificates upon course completion.',
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
                      'Quick Actions',
                      style: Theme.of(context).typography.h4,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAction(
                      context,
                      'Continue Last Lesson',
                      'Pick up where you left off',
                      Icons.play_arrow,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAction(
                      context,
                      'View Profile',
                      'Check your learning statistics',
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAction(
                      context,
                      'Browse Library',
                      'Explore our course library',
                      Icons.library_books,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    IconData icon,
  ) {
    return Button.outline(
      onPressed: () {},
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
