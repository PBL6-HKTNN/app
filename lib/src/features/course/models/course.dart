class Course {
  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final double price;
  final double rating;
  final String category;
  final String duration;
  final String description;
  final bool isEnrolled;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.price,
    required this.rating,
    required this.category,
    required this.duration,
    this.description = '',
    this.isEnrolled = false,
    this.progress = 0,
  });
}