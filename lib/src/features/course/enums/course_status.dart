enum CourseStatus { draft, published, archived }

extension CourseStatusMapper on CourseStatus {
  int get value => index;
}

CourseStatus courseStatusFromValue(int value) {
  if (value < 0 || value >= CourseStatus.values.length) {
    throw ArgumentError('Invalid course status value: $value');
  }
  return CourseStatus.values[value];
}
