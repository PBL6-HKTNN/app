class LessonModel {
  final String lesson;
  final double currentProgress;
  final Duration? currentPosition;
  const LessonModel({
    required this.lesson,
    required this.currentProgress,
    this.currentPosition,
  });

  LessonModel copyWith({
    String? lesson,
    double? currentProgress,
    Duration? currentPosition,
  }) {
    return LessonModel(
      lesson: lesson ?? this.lesson,
      currentProgress: currentProgress ?? this.currentProgress,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
