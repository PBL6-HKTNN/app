String? validatePassword(String password) {
  if (password.length < 8) {
    return 'Password must be at least 8 characters long.';
  }
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasSpecialChar = RegExp(r'[!+-@#$%^&*(),.?":{}|<>]').hasMatch(password);
  if (!hasUppercase || !hasSpecialChar) {
    return 'Password must contain at least one uppercase letter and one special character.';
  }
  return null;
}
