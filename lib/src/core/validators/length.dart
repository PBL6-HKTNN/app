String? validateLength(
  String? value, {
  int min = 0,
  int max = 255,
  String fieldName = 'Field',
}) {
  if (value == null || value.isEmpty) {
    if (min > 0) {
      return '$fieldName is required';
    }
    return null;
  }
  if (value.length < min) {
    return '$fieldName must be at least $min characters long';
  }
  if (value.length > max) {
    return '$fieldName must be no more than $max characters long';
  }
  return null;
}
