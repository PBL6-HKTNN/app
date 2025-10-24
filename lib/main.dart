// import 'package:codemy_app/src/locale/supported_lang.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'package:codemy_app/router/app_router.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'l10n/app_localizations.dart';
// import 'src/presentation/providers/locale_provider.dart';
// import 'src/presentation/providers/theme_provider.dart';
// import 'src/core/guards/auth_guard.dart';
// import 'src/core/conf/app_config.dart';
// import 'src/features/user/services/google_auth_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppConfig.load();
//   await GoogleAuthService.initialize();
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends ConsumerStatefulWidget {
//   const MyApp({super.key});

//   @override
//   ConsumerState<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends ConsumerState<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize auth state from persistent storage
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       initializeAuthState(ref);
//     });
//     // Initialize theme from persistent storage
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(themeModeProvider.notifier).initializeTheme();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider);
//     final themeMode = ref.watch(themeModeProvider);

//     // Convert ShadcnThemeMode to ThemeMode for ShadcnApp
//     ThemeMode appThemeMode;
//     switch (themeMode) {
//       case ShadcnThemeMode.light:
//         appThemeMode = ThemeMode.light;
//         break;
//       case ShadcnThemeMode.dark:
//         appThemeMode = ThemeMode.dark;
//         break;
//       case ShadcnThemeMode.system:
//         appThemeMode = ThemeMode.system;
//         break;
//     }

//     return ShadcnApp.router(
//       title: 'CodeMy App',
//       theme: ThemeData(
//         colorScheme: ColorSchemes.lightDefaultColor,
//         radius: 0.5,
//       ),
//       darkTheme: ThemeData(
//         colorScheme: ColorSchemes.darkDefaultColor,
//         radius: 0.5,
//       ),
//       themeMode: appThemeMode,
//       locale: locale,
//       routerConfig: appRouter,
//       localizationsDelegates: [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: SupportedLang().toLocaleList(),
//     );
//   }
// }

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/user/screens/user_profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Demo',
      theme: ThemeData(colorScheme: ColorSchemes.lightBlue, radius: 0.5),
      home: const ProfileScreen(),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return ShadcnApp.router(
//       title: 'CodeMy App',
//       theme: ThemeData(colorScheme: ColorSchemes.lightBlue, radius: 0.5),
//       darkTheme: ThemeData(colorScheme: ColorSchemes.darkBlue, radius: 0.5),
//       themeMode: ThemeMode.system,
//       routerConfig: appRouter,
//     );
//   }
// }