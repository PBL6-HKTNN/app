import 'package:shadcn_flutter/shadcn_flutter.dart';

class ModalLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ModalLayout({
    required this.title,
    required this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).typography.h3,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: Theme.of(context).typography.small,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
