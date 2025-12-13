enum ProgressStatus { notStarted, inProgress, completed }

enum EnrollmentStatus { inactive, active, completed }

extension ProgressStatusMapper on ProgressStatus {
  int get value => index;
}

extension EnrollmentStatusMapper on EnrollmentStatus {
  int get value => index;
}

ProgressStatus progressStatusFromValue(int value) {
  if (value < 0 || value >= ProgressStatus.values.length) {
    throw ArgumentError('Invalid progress status value: $value');
  }
  return ProgressStatus.values[value];
}

EnrollmentStatus enrollmentStatusFromValue(int value) {
  if (value < 0 || value >= EnrollmentStatus.values.length) {
    throw ArgumentError('Invalid enrollment status value: $value');
  }
  return EnrollmentStatus.values[value];
}
