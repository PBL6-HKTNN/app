import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../locale/supported_lang.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en'); // default to English

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }

  void toggleLocale() {
    final currentIndex = SupportedLang.available.indexOf(state.languageCode);
    final nextIndex = (currentIndex + 1) % SupportedLang.available.length;
    setLocale(SupportedLang.available[nextIndex]);
  }
}
