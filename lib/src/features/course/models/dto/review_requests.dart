class CreateReviewRequest {
  final String courseId;
  final int rating;
  final String comment;

  CreateReviewRequest({
    required this.courseId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {'courseId': courseId, 'rating': rating, 'comment': comment};
  }
}
