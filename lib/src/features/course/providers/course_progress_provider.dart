import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/enrollment_service.dart';

/// Course progress provider for tracking lesson completion, video progress, and current view
final courseProgressProvider =
    NotifierProvider<CourseProgressNotifier, CourseProgressState>(() {
      return CourseProgressNotifier();
    });

/// Course progress state
class CourseProgressState {
  final Map<String, Set<String>>
  completedLessonsByEnrollment; // enrollmentId -> lesson IDs
  final Map<String, String?>
  currentViewByEnrollment; // enrollmentId -> current lesson ID
  final Map<String, Timer> debounceTimers; // for video progress debouncing
  final bool isLoading;
  final String? error;

  const CourseProgressState({
    this.completedLessonsByEnrollment = const {},
    this.currentViewByEnrollment = const {},
    this.debounceTimers = const {},
    this.isLoading = false,
    this.error,
  });

  CourseProgressState copyWith({
    Map<String, Set<String>>? completedLessonsByEnrollment,
    Map<String, String?>? currentViewByEnrollment,
    Map<String, Timer>? debounceTimers,
    bool? isLoading,
    String? error,
  }) {
    return CourseProgressState(
      completedLessonsByEnrollment:
          completedLessonsByEnrollment ?? this.completedLessonsByEnrollment,
      currentViewByEnrollment:
          currentViewByEnrollment ?? this.currentViewByEnrollment,
      debounceTimers: debounceTimers ?? this.debounceTimers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Course progress notifier
class CourseProgressNotifier extends Notifier<CourseProgressState> {
  late final EnrollmentService _enrollmentService;

  @override
  CourseProgressState build() {
    _enrollmentService = EnrollmentService();
    return const CourseProgressState();
  }

  /// Load completed lessons for an enrollment
  Future<void> loadCompletedLessons(String enrollmentId) async {
    if (state.completedLessonsByEnrollment.containsKey(enrollmentId)) {
      return; // Already loaded
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await _enrollmentService.getCompletedLessons(
        enrollmentId,
      );

      if (response.isSuccess && response.data != null) {
        final completedLessons = response.data!.toSet();
        final newCompletedLessons = Map<String, Set<String>>.from(
          state.completedLessonsByEnrollment,
        );
        newCompletedLessons[enrollmentId] = completedLessons;

        state = state.copyWith(
          completedLessonsByEnrollment: newCompletedLessons,
          isLoading: false,
        );

        // Debug logging removed for production
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load completed lessons: ${response.error}',
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load completed lessons: $error',
      );
    }
  }

  /// Check if a lesson is completed
  bool isLessonCompleted(String enrollmentId, String lessonId) {
    return state.completedLessonsByEnrollment[enrollmentId]?.contains(
          lessonId,
        ) ??
        false;
  }

  /// Get all completed lessons for an enrollment
  Set<String> getCompletedLessons(String enrollmentId) {
    return state.completedLessonsByEnrollment[enrollmentId] ?? {};
  }

  /// Mark a lesson as complete
  Future<void> markLessonComplete(
    String courseId,
    String lessonId,
    String enrollmentId,
  ) async {
    // Optimistically update local state
    final newCompletedLessons = Map<String, Set<String>>.from(
      state.completedLessonsByEnrollment,
    );
    newCompletedLessons[enrollmentId] =
        (newCompletedLessons[enrollmentId] ?? {})..add(lessonId);

    state = state.copyWith(completedLessonsByEnrollment: newCompletedLessons);

    try {
      final response = await _enrollmentService.updateEnrollmentProgress(
        courseId: courseId,
        lessonId: lessonId,
      );

      if (!response.isSuccess) {
        // Revert optimistic update on failure
        final revertedCompletedLessons = Map<String, Set<String>>.from(
          state.completedLessonsByEnrollment,
        );
        revertedCompletedLessons[enrollmentId]?.remove(lessonId);
        state = state.copyWith(
          completedLessonsByEnrollment: revertedCompletedLessons,
        );

        // Failed to mark lesson complete on server
      } else {
        // Successfully marked lesson complete
      }
    } catch (error) {
      // Revert optimistic update on error
      final revertedCompletedLessons = Map<String, Set<String>>.from(
        state.completedLessonsByEnrollment,
      );
      revertedCompletedLessons[enrollmentId]?.remove(lessonId);
      state = state.copyWith(
        completedLessonsByEnrollment: revertedCompletedLessons,
      );

      // Failed to mark lesson complete
    }
  }

  /// Update current view (which lesson user is currently viewing)
  Future<void> updateCurrentView(
    String courseId,
    String currentLessonId,
    String enrollmentId,
  ) async {
    // Optimistically update local state
    final newCurrentView = Map<String, String?>.from(
      state.currentViewByEnrollment,
    );
    newCurrentView[enrollmentId] = currentLessonId;

    state = state.copyWith(currentViewByEnrollment: newCurrentView);

    try {
      final response = await _enrollmentService.updateCurrentView(
        courseId: courseId,
        currentLessonId: currentLessonId,
      );

      if (!response.isSuccess) {
        // Failed to update current view on server
      } else {
        // Successfully updated current view
      }
    } catch (error) {
      // Failed to update current view
    }
  }

  /// Track markdown scroll progress (mark complete when scrolled to bottom)
  void trackMarkdownScroll(
    double scrollPercentage,
    String courseId,
    String lessonId,
    String enrollmentId,
  ) {
    if (scrollPercentage >= 0.9 && !isLessonCompleted(enrollmentId, lessonId)) {
      markLessonComplete(courseId, lessonId, enrollmentId);
    }
  }

  /// Track video progress with debouncing
  void trackVideoProgress(
    double currentTime,
    double duration,
    String courseId,
    String lessonId,
    String enrollmentId,
  ) {
    final progressKey = '$courseId-$lessonId';

    // Cancel existing timer
    state.debounceTimers[progressKey]?.cancel();

    // Create new debounced timer
    final timer = Timer(const Duration(seconds: 2), () {
      final watchedPercentage = duration > 0 ? currentTime / duration : 0;

      // Mark complete if watched 80% or more
      if (watchedPercentage >= 0.8 &&
          !isLessonCompleted(enrollmentId, lessonId)) {
        markLessonComplete(courseId, lessonId, enrollmentId);
      }
    });

    final newTimers = Map<String, Timer>.from(state.debounceTimers);
    newTimers[progressKey] = timer;
    state = state.copyWith(debounceTimers: newTimers);
  }

  /// Mark quiz complete
  Future<void> markQuizComplete(
    String courseId,
    String lessonId,
    String enrollmentId,
    bool passed,
  ) async {
    if (passed && !isLessonCompleted(enrollmentId, lessonId)) {
      await markLessonComplete(courseId, lessonId, enrollmentId);
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Dispose resources
  void dispose() {
    for (final timer in state.debounceTimers.values) {
      timer.cancel();
    }
  }
}

/// Provider for checking enrollment status
final enrollmentStatusProvider = FutureProvider.family<bool, String>((
  ref,
  courseId,
) async {
  final enrollmentService = EnrollmentService();
  final response = await enrollmentService.isEnrolled(courseId);
  return response.isSuccess && response.data?.success == true;
});

/// Provider for getting enrollment details
final enrollmentDetailsProvider = FutureProvider.family<String?, String>((
  ref,
  courseId,
) async {
  final enrollmentService = EnrollmentService();
  final response = await enrollmentService.isEnrolled(courseId);
  if (response.isSuccess && response.data?.success == true) {
    return response.data?.enrollment?.id;
  }
  return null;
});
