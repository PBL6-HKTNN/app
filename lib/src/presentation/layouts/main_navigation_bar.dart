import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MainNavigationBar extends StatefulWidget {
  final Widget child;

  const MainNavigationBar({super.key, required this.child});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final currentIndex = switch (currentPath) {
      '/user' => 2,
      '/courses' => 1,
      _ => 0,
    };

    return SafeArea(
      child: Scaffold(
        footers: [
          const Divider(),
          NavigationBar(
            alignment: NavigationBarAlignment.spaceAround,
            labelType: NavigationLabelType.none,
            expanded: true,
            expands: true,
            index: currentIndex,
            onSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.push('/courses');
                  break;
                case 2:
                  context.push('/user');
                  break;
              }
            },
            children: [
              _buildNavigationItem('Home', LucideIcons.house),
              _buildNavigationItem('Courses', LucideIcons.graduationCap),
              _buildNavigationItem('Profile', LucideIcons.user),
            ],
          ),
        ],
        child: widget.child,
      ),
    );
  }

  NavigationItem _buildNavigationItem(String label, IconData icon) {
    return NavigationItem(
      style: const ButtonStyle.muted(density: ButtonDensity.icon),
      selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
      label: Text(label),
      child: Icon(icon),
    );
  }
}
