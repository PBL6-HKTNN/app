import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';

class QuizAnswerPayload {
  final String? answerId;
  final String answerText;
  final bool isCorrect;

  QuizAnswerPayload({
    this.answerId,
    required this.answerText,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      if (answerId != null) 'answerId': answerId,
      'answerText': answerText,
      'isCorrect': isCorrect,
    };
  }
}

class QuizQuestionPayload {
  final String? id;
  final String questionText;
  final QuizQuestionType questionType;
  final int marks;
  final List<QuizAnswerPayload> answers;

  QuizQuestionPayload({
    this.id,
    required this.questionText,
    required this.questionType,
    required this.marks,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'questionId': id,
      'questionText': questionText,
      'questionType': questionType.index,
      'marks': marks,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class CreateQuizRequest {
  final String lessonId;
  final String title;
  final String description;
  final int passingMarks;
  final List<QuizQuestionPayload> questions;

  CreateQuizRequest({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.passingMarks,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'passingMarks': passingMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class UpdateQuizRequest extends CreateQuizRequest {
  UpdateQuizRequest({
    required super.lessonId,
    required super.title,
    required super.description,
    required super.passingMarks,
    required super.questions,
  });
}

class QuizSubmissionAnswerPayload {
  final String questionId;
  final String? answerText;
  final List<String> selectedAnswerIds;

  QuizSubmissionAnswerPayload({
    required this.questionId,
    this.answerText,
    required this.selectedAnswerIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answerText': answerText,
      'selectedAnswerIds': selectedAnswerIds,
    };
  }
}

class QuizSubmissionRequest {
  final String quizAttemptId;
  final List<QuizSubmissionAnswerPayload> answers;

  QuizSubmissionRequest({required this.quizAttemptId, required this.answers});

  Map<String, dynamic> toJson() {
    return {
      'quizAttemptId': quizAttemptId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}
