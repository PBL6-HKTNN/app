import 'dart:ui';

class SupportedLang {
  static const available = ['en', 'vi'];

  List<Locale> toLocaleList() {
    return available.map((lang) => Locale(lang)).toList();
  }
}
