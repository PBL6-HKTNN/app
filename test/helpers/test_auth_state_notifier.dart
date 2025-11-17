import 'package:codemy_app/src/features/user/providers/auth_providers.dart';

/// Test double that avoids hitting secure storage while letting tests observe
/// persistence calls made by [AuthStateNotifier].
class TestAuthStateNotifier extends AuthStateNotifier {
  TestAuthStateNotifier({this.onSave, this.onClear});

  final Future<void> Function(String token, Map<String, dynamic> userData)?
  onSave;
  final Future<void> Function()? onClear;

  @override
  Future<void> saveAuthState(
    String token,
    Map<String, dynamic> userData,
  ) async {
    if (onSave != null) {
      await onSave!(token, userData);
    }
  }

  @override
  Future<void> clearAuthState() async {
    if (onClear != null) {
      await onClear!();
    }
  }
}
