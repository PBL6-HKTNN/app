// lib/services/review_service.dart
import '../models/entities/review.dart';

class ReviewService {
  Future<List<Review>> fetchReviews(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Review(
        id: 'r1',
        userName: 'Alice Nguyen',
        rating: 5,
        comment: 'Khóa học rất hay, giảng viên giảng dễ hiểu ❤️',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'r2',
        userName: 'Minh Tran',
        rating: 4,
        comment: 'Nội dung ổn, có thể cải thiện phần bài tập thực hành.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> submitReview(String courseId, Review review) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Giả lập gửi thành công
  }
}
