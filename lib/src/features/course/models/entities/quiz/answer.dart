class Answer {
  final String? id;
  final String answerText;
  final bool isCorrect;

  Answer({this.id, required this.answerText, required this.isCorrect});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['answerId'] as String?,
      answerText: json['answerText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'answerId': id,
      'answerText': answerText,
      'isCorrect': isCorrect,
    };
  }
}
