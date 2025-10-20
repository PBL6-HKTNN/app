String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  // Remove all non-digit characters for validation
  final cleaned = value.replaceAll(RegExp(r'\D'), '');
  // Vietnamese phone numbers: 10 digits starting with 0, or international format
  final phoneRegex = RegExp(r'^(?:\+84|0)[3-9]\d{8}$');
  if (!phoneRegex.hasMatch(cleaned)) {
    return 'Please enter a valid phone number';
  }
  return null;
}
