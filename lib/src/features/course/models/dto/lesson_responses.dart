class QuizInVideoResponse {
  final String id;
  final String time; // timespan like "00:01:23"
  final String question;
  final List<String> options;

  QuizInVideoResponse({
    required this.id,
    required this.time,
    required this.question,
    required this.options,
  });

  factory QuizInVideoResponse.fromJson(Map<String, dynamic> json) {
    return QuizInVideoResponse(
      id: json['id'] as String? ?? '',
      time: json['time'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
    );
  }
}
