import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/locale_provider.dart';

class LangBtn extends ConsumerWidget {
  const LangBtn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Button.outline(
      onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
      child: Text(locale.languageCode.toUpperCase()),
    );
  }
}
