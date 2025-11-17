enum ProgressStatus { notStarted, inProgress, completed }

enum EnrollmentStatus { inactive, active, completed }

extension ProgressStatusMapper on ProgressStatus {
  int get value => index;
}

extension EnrollmentStatusMapper on EnrollmentStatus {
  int get value => index;
}
