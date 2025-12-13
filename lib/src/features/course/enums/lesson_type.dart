enum LessonType { markdown, video, quiz }

extension LessonTypeMapper on LessonType {
  int get value => index;
}

LessonType lessonTypeFromValue(int value) {
  if (value < 0 || value >= LessonType.values.length) {
    throw ArgumentError('Invalid lesson type value: $value');
  }
  return LessonType.values[value];
}
