String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }
  if (value.length < 3) {
    return 'Username must be at least 3 characters long';
  }
  if (value.length > 20) {
    return 'Username must be no more than 20 characters long';
  }
  final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
  if (!usernameRegex.hasMatch(value)) {
    return 'Username can only contain letters, numbers, underscores, and dashes';
  }
  return null;
}
