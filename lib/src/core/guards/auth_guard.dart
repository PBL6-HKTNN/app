import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/providers/auth_providers.dart';

/// Auth guard redirect function for GoRouter
/// Checks authentication status and redirects to login if not authenticated
String? authGuardRedirect(BuildContext context, GoRouterState state) {
  // Skip auth check for auth routes
  final authRoutes = ['/login', '/register', '/oauth', '/verify'];
  if (authRoutes.contains(state.matchedLocation)) {
    return null;
  }

  // Get auth state from Riverpod
  final container = ProviderScope.containerOf(context, listen: false);
  final authState = container.read(authStateProvider);

  // If not authenticated, redirect to login
  if (!authState.isAuthenticated) {
    return '/login';
  }

  if (!authState.user!.emailVerified) {
    return '/verify';
  }

  // User is authenticated, allow access
  return null;
}

/// Initialize auth state from persistent storage on app start
Future<void> initializeAuthState(WidgetRef ref) async {
  await ref.read(authStateProvider.notifier).initializeAuthState();
}

/// Save auth state to persistent storage
Future<void> saveAuthState(
  WidgetRef ref,
  String token,
  Map<String, dynamic> userData,
) async {
  await ref.read(authStateProvider.notifier).saveAuthState(token, userData);
}

/// Clear auth state from persistent storage
Future<void> clearAuthState(WidgetRef ref) async {
  await ref.read(authStateProvider.notifier).clearAuthState();
}
