import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: const Text('Page Not Found'))],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '404 - Page Not Found',
                    style: Theme.of(context).typography.h4,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The page you are looking for does not exist.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Button.primary(
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
