import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Safely pops the current route if possible, with optional fallback behavior.
///
/// This utility helps prevent common issues with context popping:
/// - Checking if the context can pop before attempting to pop
/// - Handling disposed contexts gracefully
/// - Providing fallback navigation when popping is not possible
///
/// Usage examples:
/// ```dart
/// // Simple safe pop
/// safePop(context);
///
/// // Pop with fallback route
/// safePop(context, fallbackRoute: '/home');
///
/// // Pop with custom fallback action
/// safePop(context, onFallback: () => context.go('/dashboard'));
/// ```
void safePop(
  BuildContext context, {
  String? fallbackRoute,
  VoidCallback? onFallback,
  bool useGoInsteadOfPush = false,
}) {
  try {
    // Check if context is still mounted and can pop
    if (!context.mounted) {
      // Context is disposed, execute fallback if provided
      _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
      return;
    }

    // Check if we can pop
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    // Cannot pop, execute fallback
    _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
  } catch (e) {
    // If any error occurs during popping, execute fallback
    _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
  }
}

/// Executes fallback behavior when popping is not possible
void _executeFallback(
  BuildContext context,
  String? fallbackRoute,
  VoidCallback? onFallback,
  bool useGoInsteadOfPush,
) {
  if (onFallback != null) {
    onFallback();
  } else if (fallbackRoute != null && context.mounted) {
    if (useGoInsteadOfPush) {
      context.go(fallbackRoute);
    } else {
      context.push(fallbackRoute);
    }
  }
  // If no fallback provided, do nothing (stay on current screen)
}

/// Safely pops until a specific route is reached
///
/// This is useful for deep navigation stacks where you want to pop back
/// to a specific screen rather than just one level.
///
/// Returns true if the target route was found and popped to, false otherwise.
bool safePopUntil(
  BuildContext context,
  bool Function(Route<dynamic>) predicate, {
  String? fallbackRoute,
  VoidCallback? onFallback,
  bool useGoInsteadOfPush = false,
}) {
  try {
    if (!context.mounted) {
      _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
      return false;
    }

    // Try to pop until predicate is satisfied
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(predicate);
      return true;
    }

    // Cannot pop, execute fallback
    _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
    return false;
  } catch (e) {
    _executeFallback(context, fallbackRoute, onFallback, useGoInsteadOfPush);
    return false;
  }
}

/// Safely pops to a named route
///
/// This is a convenience method for popping to a specific named route
/// in the navigation stack.
bool safePopToNamed(
  BuildContext context,
  String routeName, {
  String? fallbackRoute,
  VoidCallback? onFallback,
  bool useGoInsteadOfPush = false,
}) {
  return safePopUntil(
    context,
    (route) => route.settings.name == routeName,
    fallbackRoute: fallbackRoute,
    onFallback: onFallback,
    useGoInsteadOfPush: useGoInsteadOfPush,
  );
}

/// Extension methods for BuildContext to provide safe pop functionality
extension SafePopExtension on BuildContext {
  /// Safely pops the current route with optional fallback
  void popSafely({
    String? fallbackRoute,
    VoidCallback? onFallback,
    bool useGoInsteadOfPush = false,
  }) {
    safePop(
      this,
      fallbackRoute: fallbackRoute,
      onFallback: onFallback,
      useGoInsteadOfPush: useGoInsteadOfPush,
    );
  }

  /// Safely pops until a predicate is satisfied
  bool popUntilSafely(
    bool Function(Route<dynamic>) predicate, {
    String? fallbackRoute,
    VoidCallback? onFallback,
    bool useGoInsteadOfPush = false,
  }) {
    return safePopUntil(
      this,
      predicate,
      fallbackRoute: fallbackRoute,
      onFallback: onFallback,
      useGoInsteadOfPush: useGoInsteadOfPush,
    );
  }

  /// Safely pops to a named route
  bool popToNamedSafely(
    String routeName, {
    String? fallbackRoute,
    VoidCallback? onFallback,
    bool useGoInsteadOfPush = false,
  }) {
    return safePopToNamed(
      this,
      routeName,
      fallbackRoute: fallbackRoute,
      onFallback: onFallback,
      useGoInsteadOfPush: useGoInsteadOfPush,
    );
  }
}
