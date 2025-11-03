// mock providers for learning lesson flow test with states handling for 3 kinds of lessons: markdown, video and quiz
import 'package:codemy_app/src/features/course/states/lesson_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonNotifier extends Notifier<LessonModel> {
  @override
  LessonModel build() {
    return const LessonModel(lesson: '', currentProgress: 0.0);
  }

  void setLesson(String lesson) {
    state = state.copyWith(lesson: lesson);
  }

  void setProgress(double progress) {
    state = state.copyWith(currentProgress: progress.clamp(0.0, 1.0));
  }

  void setCurrentPosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void saveProgress() {
    // Mock save progress - in real implementation, this would save to backend/database
    print('Mock saving progress: ${state.currentProgress}');
  }
}

final lessonProvider = NotifierProvider<LessonNotifier, LessonModel>(
  () => LessonNotifier(),
);
