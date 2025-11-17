enum CourseLevel { beginner, intermediate, advanced }

extension CourseLevelMapper on CourseLevel {
  int get value => index;
}

CourseLevel courseLevelFromValue(int value) {
  if (value < 0 || value >= CourseLevel.values.length) {
    throw ArgumentError('Invalid course level value: $value');
  }
  return CourseLevel.values[value];
}
