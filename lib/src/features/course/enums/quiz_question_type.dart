enum QuizQuestionType { singleChoice, multipleChoice, trueFalse, shortAnswer }

extension QuizQuestionTypeMapper on QuizQuestionType {
  int get value => index;
}

QuizQuestionType quizQuestionTypeFromValue(int value) {
  if (value < 0 || value >= QuizQuestionType.values.length) {
    throw ArgumentError('Invalid quiz question type value: $value');
  }
  return QuizQuestionType.values[value];
}
