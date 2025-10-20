// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'package:codemy_app/router/app_router.dart';

// void main() {
//   runApp(const ProviderScope(child: MyApp())); 
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/user/screens/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ProfileScreen(),
    );
  }
}
