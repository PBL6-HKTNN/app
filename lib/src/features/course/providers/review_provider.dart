// lib/providers/review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/review_service.dart';
import '../models/entities/review.dart';

final reviewProvider =
    StateNotifierProvider.family<
      ReviewNotifier,
      AsyncValue<List<Review>>,
      String
    >((ref, courseId) => ReviewNotifier(courseId, ReviewService()));

class ReviewNotifier extends StateNotifier<AsyncValue<List<Review>>> {
  final ReviewService _service;
  final String _courseId;

  ReviewNotifier(this._courseId, this._service) : super(const AsyncLoading()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      final reviews = await _service.fetchReviews(_courseId);
      state = AsyncData(reviews);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> submitReview(Review review) async {
    await _service.submitReview(_courseId, review);
    final current = state.value ?? [];
    state = AsyncData([review, ...current]);
  }
}
