import 'package:codemy_app/src/presentation/widgets/lang_btn.dart';
import 'package:codemy_app/src/presentation/widgets/theme_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../locale/index.dart';
import '../layouts/main_navigation_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
                Text(l10n.settings, style: Theme.of(context).typography.h1),
                Button.ghost(
                  onPressed: () => context.pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                    const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
