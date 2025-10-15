import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/theme_provider.dart';

class ThemeDropdown extends ConsumerWidget {
  const ThemeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Select<ShadcnThemeMode>(
      value: currentTheme,
      onChanged: (ShadcnThemeMode? newTheme) {
        if (newTheme != null) {
          ref.read(themeModeProvider.notifier).setThemeMode(newTheme);
        }
      },
      placeholder: const Text('Select Theme'),
      popup: SelectPopup(
        items: SelectItemList(
          children: ShadcnThemeMode.values.map((themeMode) {
            return SelectItem(
              value: themeMode,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(themeMode.displayName),
              ),
            );
          }).toList(),
        ),
      ).call,
      itemBuilder: (context, value) => Text(value.displayName),
    );
  }
}
