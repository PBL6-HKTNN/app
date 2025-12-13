import 'package:codemy_app/src/features/course/models/entities/category.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/entities/enrollment.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_attempt.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_submission_result.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/user_answer.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/answer.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_responses.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_requests.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';
import 'package:codemy_app/src/features/course/enums/course_status.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:decimal/decimal.dart';

// ==================== CATEGORY ====================
final testCategory = Category(
  id: 'cat-1',
  name: 'Programming',
  description: 'Learn programming and software development',
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'system',
  updatedAt: DateTime(2024, 1, 1),
  updatedBy: 'system',
  isDeleted: false,
);

final testCategoryList = [
  testCategory,
  Category(
    id: 'cat-2',
    name: 'Design',
    description: 'UI/UX Design courses',
    createdAt: DateTime(2024, 1, 1),
    createdBy: 'system',
  ),
];

// ==================== COURSE ====================
final testCourse = Course(
  id: 'course-1',
  instructorId: 'instructor-1',
  categoryId: 'cat-1',
  title: 'Flutter Complete Guide',
  description: 'Master Flutter development from scratch',
  thumbnail: 'https://example.com/flutter.jpg',
  status: CourseStatus.published,
  duration: '120', // 120 minutes as string
  price: Decimal.parse('99.99'),
  level: CourseLevel.beginner,
  language: 'English',
  numberOfModules: 5,
  numberOfReviews: 200,
  averageRating: 4.5,
  modules: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  updatedAt: DateTime(2024, 1, 15),
  updatedBy: 'instructor-1',
  isDeleted: false,
);

final testCourseAdvanced = Course(
  id: 'course-2',
  instructorId: 'instructor-1',
  categoryId: 'cat-1',
  title: 'Advanced Flutter',
  description: 'Advanced Flutter patterns and architecture',
  thumbnail: 'https://example.com/advanced-flutter.jpg',
  status: CourseStatus.published,
  duration: '180',
  price: Decimal.parse('149.99'),
  level: CourseLevel.advanced,
  language: 'English',
  numberOfModules: 8,
  numberOfReviews: 150,
  averageRating: 4.7,
  modules: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
);

final testCourseBeginner = Course(
  id: 'course-3',
  instructorId: 'instructor-2',
  categoryId: 'cat-1',
  title: 'Flutter for Beginners',
  description: 'Start your Flutter journey',
  thumbnail: 'https://example.com/beginner-flutter.jpg',
  status: CourseStatus.published,
  duration: '60',
  price: Decimal.parse('49.99'),
  level: CourseLevel.beginner,
  language: 'English',
  numberOfModules: 3,
  numberOfReviews: 50,
  averageRating: 4.2,
  modules: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-2',
);

final testCourseList = [testCourse, testCourseAdvanced, testCourseBeginner];

// ==================== MODULE ====================
final testModule = Module(
  id: 'module-1',
  courseId: 'course-1',
  title: 'Introduction to Flutter',
  durationMinutes: '30', // 30 minutes as string
  numberOfLessons: 3,
  order: 1,
  lessons: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  updatedAt: DateTime(2024, 1, 1),
  isDeleted: false,
);

final testModule2 = Module(
  id: 'module-2',
  courseId: 'course-1',
  title: 'Flutter Widgets',
  durationMinutes: '45',
  numberOfLessons: 5,
  order: 2,
  lessons: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
);

final testModuleList = [testModule, testModule2];

// ==================== ANSWERS ====================
final testAnswerCorrect = Answer(
  id: 'ans-1',
  answerText: 'A mobile UI framework',
  isCorrect: true,
);

final testAnswerWrong1 = Answer(
  id: 'ans-2',
  answerText: 'A programming language',
  isCorrect: false,
);

final testAnswerWrong2 = Answer(
  id: 'ans-3',
  answerText: 'A database',
  isCorrect: false,
);

final testAnswerWrong3 = Answer(
  id: 'ans-4',
  answerText: 'An operating system',
  isCorrect: false,
);

// ==================== QUIZ QUESTIONS ====================
final testMultipleChoiceQuestion = QuizQuestion(
  id: 'q1',
  questionText: 'What is Flutter?',
  questionType: QuizQuestionType.multipleChoice,
  marks: 10,
  answers: [
    testAnswerCorrect,
    testAnswerWrong1,
    testAnswerWrong2,
    testAnswerWrong3,
  ],
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  isDeleted: false,
);

final testTrueFalseQuestion = QuizQuestion(
  id: 'q2',
  questionText: 'Flutter uses Dart programming language',
  questionType: QuizQuestionType.trueFalse,
  marks: 5,
  answers: [
    Answer(id: 'ans-5', answerText: 'True', isCorrect: true),
    Answer(id: 'ans-6', answerText: 'False', isCorrect: false),
  ],
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  isDeleted: false,
);

final testShortAnswerQuestion = QuizQuestion(
  id: 'q3',
  questionText: 'What widget creates a scrollable list?',
  questionType: QuizQuestionType.shortAnswer,
  marks: 15,
  answers: [Answer(id: 'ans-7', answerText: 'ListView', isCorrect: true)],
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  isDeleted: false,
);

final testQuizQuestions = [
  testMultipleChoiceQuestion,
  testTrueFalseQuestion,
  testShortAnswerQuestion,
];

// ==================== QUIZ ====================
final testQuiz = Quiz(
  lessonId: 'lesson-2',
  id: 'quiz-1',
  title: 'Flutter Basics Quiz',
  description: 'Test your knowledge of Flutter basics',
  passingMarks: 70,
  totalMarks: 100,
  questions: testQuizQuestions,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  isDeleted: false,
);

// ==================== LESSONS ====================
final testVideoLesson = Lesson(
  id: 'lesson-1',
  moduleId: 'module-1',
  title: 'What is Flutter?',
  contentUrl: 'https://example.com/videos/intro.mp4',
  duration: '10', // 10 minutes as string
  lessonType: LessonType.video,
  orderIndex: 1,
  isPreview: true,
  quiz: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  updatedAt: DateTime(2024, 1, 1),
  isDeleted: false,
);

final testQuizLesson = Lesson(
  id: 'lesson-2',
  moduleId: 'module-1',
  title: 'Flutter Basics Quiz',
  contentUrl: null,
  duration: '5',
  lessonType: LessonType.quiz,
  orderIndex: 2,
  isPreview: false,
  quiz: testQuiz,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  updatedAt: DateTime(2024, 1, 1),
  isDeleted: false,
);

final testMarkdownLesson = Lesson(
  id: 'lesson-3',
  moduleId: 'module-1',
  title: 'Flutter Setup Guide',
  contentUrl: 'https://example.com/markdown/setup.md',
  duration: '3',
  lessonType: LessonType.markdown,
  orderIndex: 3,
  isPreview: true,
  quiz: null,
  createdAt: DateTime(2024, 1, 1),
  createdBy: 'instructor-1',
  isDeleted: false,
);

final testLessonList = [testVideoLesson, testQuizLesson, testMarkdownLesson];

// ==================== USER ANSWERS ====================
final testUserAnswerCorrect = UserAnswer(
  id: 'ua-1',
  attemptId: 'attempt-1',
  questionId: 'q1',
  answerId: 'ans-1',
  answerText: null,
  markObtained: 10,
  createdAt: DateTime(2024, 1, 10, 10, 5),
  createdBy: 'user-1',
  isDeleted: false,
);

final testUserAnswerWrong = UserAnswer(
  id: 'ua-2',
  attemptId: 'attempt-1',
  questionId: 'q2',
  answerId: 'ans-6',
  answerText: null,
  markObtained: 0,
  createdAt: DateTime(2024, 1, 10, 10, 7),
  createdBy: 'user-1',
  isDeleted: false,
);

final testUserAnswerShortAnswer = UserAnswer(
  id: 'ua-3',
  attemptId: 'attempt-1',
  questionId: 'q3',
  answerId: null,
  answerText: 'ListView',
  markObtained: 15,
  createdAt: DateTime(2024, 1, 10, 10, 10),
  createdBy: 'user-1',
  isDeleted: false,
);

// ==================== QUIZ SUBMISSION RESULT ====================
final testQuizResultPassed = QuizSubmissionResult(
  quizId: 'quiz-1',
  score: 25, // 10 + 0 + 15
  passed: true,
  userAnswers: [
    testUserAnswerCorrect,
    testUserAnswerWrong,
    testUserAnswerShortAnswer,
  ],
);

final testQuizResultFailed = QuizSubmissionResult(
  quizId: 'quiz-1',
  score: 10, // Only q1 correct
  passed: false,
  userAnswers: [
    testUserAnswerCorrect,
    testUserAnswerWrong,
    UserAnswer(
      id: 'ua-4',
      attemptId: 'attempt-2',
      questionId: 'q3',
      answerId: null,
      answerText: 'RecyclerView',
      markObtained: 0,
      createdAt: DateTime(2024, 1, 10, 11, 10),
      createdBy: 'user-1',
    ),
  ],
);

// ==================== QUIZ ATTEMPT ====================
final testQuizAttempt = QuizAttempt(
  id: 'attempt-1',
  userId: 'user-1',
  quizId: 'quiz-1',
  score: 25,
  passed: true,
  status: 1, // Completed
  attemptedAt: DateTime(2024, 1, 10, 10, 0),
  completedAt: DateTime(2024, 1, 10, 10, 15),
  userAnswers: [
    testUserAnswerCorrect,
    testUserAnswerWrong,
    testUserAnswerShortAnswer,
  ],
  createdAt: DateTime(2024, 1, 10, 10, 0),
  createdBy: 'user-1',
  isDeleted: false,
);

final testQuizAttemptFailed = QuizAttempt(
  id: 'attempt-2',
  userId: 'user-1',
  quizId: 'quiz-1',
  score: 10,
  passed: false,
  status: 1,
  attemptedAt: DateTime(2024, 1, 10, 11, 0),
  completedAt: DateTime(2024, 1, 10, 11, 15),
  userAnswers: [
    testUserAnswerCorrect,
    testUserAnswerWrong,
    UserAnswer(
      id: 'ua-4',
      attemptId: 'attempt-2',
      questionId: 'q3',
      answerId: null,
      answerText: 'RecyclerView',
      markObtained: 0,
      createdAt: DateTime(2024, 1, 10, 11, 10),
      createdBy: 'user-1',
    ),
  ],
  createdAt: DateTime(2024, 1, 10, 11, 0),
  createdBy: 'user-1',
  isDeleted: false,
);

final testQuizAttemptList = [testQuizAttempt, testQuizAttemptFailed];

// ==================== JOINED COURSES ====================
final testJoinedCourse1 = JoinedCourse(
  'course-1',
  'Flutter Complete Guide',
  'Master Flutter development from scratch',
  'https://example.com/flutter.jpg',
  Decimal.parse('99.99'),
  'instructor-1',
);

final testJoinedCourse2 = JoinedCourse(
  'course-2',
  'Advanced Dart Programming',
  'Deep dive into Dart language features',
  'https://example.com/dart.jpg',
  Decimal.parse('79.99'),
  'instructor-2',
);

final testJoinedCourse3 = JoinedCourse(
  'course-3',
  'Firebase for Flutter',
  'Build apps with Firebase backend',
  'https://example.com/firebase.jpg',
  Decimal.parse('89.99'),
  'instructor-1',
);

final testJoinedCourseList = [
  testJoinedCourse1,
  testJoinedCourse2,
  testJoinedCourse3,
];

// ==================== ENROLLMENT CHECK RESPONSE ====================
final testEnrollmentCheckSuccess = EnrollmentCheckResponse(
  success: true,
  message: 'User is enrolled in this course',
);

final testEnrollmentCheckNotEnrolled = EnrollmentCheckResponse(
  success: false,
  message: 'User is not enrolled in this course',
);

// ==================== ENROLLMENT ====================
final testEnrollment = Enrollment(
  'enrollment-1',
  1, // progressStatus: in progress
  'lesson-1',
  DateTime(2024, 12, 31),
  'https://example.com/cert.pdf',
  DateTime(2025, 12, 31),
  1, // enrollmentStatus: active
  id: 'enroll-id-1',
  createdAt: DateTime(2024, 1, 15),
);

final testEnrollmentNotStarted = Enrollment(
  'enrollment-2',
  0, // progressStatus: not started
  null,
  DateTime(2024, 12, 31),
  '',
  DateTime(2025, 12, 31),
  1, // enrollmentStatus: active
  id: 'enroll-id-2',
  createdAt: DateTime(2024, 2, 1),
);

final testEnrollmentCompleted = Enrollment(
  'enrollment-3',
  2, // progressStatus: completed
  'lesson-10',
  DateTime(2024, 6, 30),
  'https://example.com/cert-completed.pdf',
  DateTime(2025, 6, 30),
  2, // enrollmentStatus: completed
  id: 'enroll-id-3',
  createdAt: DateTime(2024, 1, 1),
);

final testEnrollmentList = [
  testEnrollment,
  testEnrollmentNotStarted,
  testEnrollmentCompleted,
];

// ==================== UPDATE ENROLLMENT REQUEST ====================
final testUpdateEnrollmentRequest = UpdateEnrollmentRequest(
  enrollmentId: 'enrollment-1',
  progressStatus: 1,
  lessonId: 'lesson-2',
  completionDate: null,
  certificateUrl: null,
  certificateExpiryDate: null,
);

final testUpdateEnrollmentRequestCompleted = UpdateEnrollmentRequest(
  enrollmentId: 'enrollment-1',
  progressStatus: 2,
  lessonId: 'lesson-10',
  completionDate: DateTime(2024, 12, 31).toIso8601String(),
  certificateUrl: 'https://example.com/cert.pdf',
  certificateExpiryDate: DateTime(2025, 12, 31).toIso8601String(),
);

// ==================== HELPER FUNCTIONS ====================

/// Get course by ID
Course? getCourseById(String id) {
  try {
    return testCourseList.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
}

/// Get enrollment by ID
Enrollment? getEnrollmentById(String id) {
  try {
    return testEnrollmentList.firstWhere((e) => e.id == id);
  } catch (e) {
    return null;
  }
}

/// Get joined course by ID
JoinedCourse? getJoinedCourseById(String id) {
  try {
    return testJoinedCourseList.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
}

/// Get quiz attempt by ID
QuizAttempt? getQuizAttemptById(String id) {
  try {
    return testQuizAttemptList.firstWhere((a) => a.id == id);
  } catch (e) {
    return null;
  }
}

/// Get module by ID
Module? getModuleById(String id) {
  try {
    return testModuleList.firstWhere((m) => m.id == id);
  } catch (e) {
    return null;
  }
}

/// Get lesson by ID
Lesson? getLessonById(String id) {
  try {
    return testLessonList.firstWhere((l) => l.id == id);
  } catch (e) {
    return null;
  }
}

/// Get category by ID
Category? getCategoryById(String id) {
  try {
    return testCategoryList.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
}

/// Filter courses by level
List<Course> getCoursesByLevel(CourseLevel level) {
  return testCourseList.where((c) => c.level == level).toList();
}

/// Filter courses by category
List<Course> getCoursesByCategory(String categoryId) {
  return testCourseList.where((c) => c.categoryId == categoryId).toList();
}

/// Get active enrollments
List<Enrollment> getActiveEnrollments() {
  return testEnrollmentList.where((e) => e.enrollmentStatus == 1).toList();
}

/// Get completed enrollments
List<Enrollment> getCompletedEnrollments() {
  return testEnrollmentList.where((e) => e.enrollmentStatus == 2).toList();
}
