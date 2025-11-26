import 'app_config.dart';

class ApiRoutes {
  ApiRoutes._();

  // Base URL from AppConfig
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Structured route groups
  static final _AuthRoutes AUTH = _AuthRoutes._();
  static final _UserRoutes USER = _UserRoutes._();
  static final _StorageRoutes STORAGE = _StorageRoutes._();
  static final _CourseRoutes COURSE = _CourseRoutes._();
  static final _ModuleRoutes MODULE = _ModuleRoutes._();
  static final _LessonRoutes LESSON = _LessonRoutes._();
  static final _CategoryRoutes CATEGORY = _CategoryRoutes._();
  static final _QuizRoutes QUIZ = _QuizRoutes._();
  static final _WishlistRoutes WISHLIST = _WishlistRoutes._();
  static final _EnrollmentRoutes ENROLLMENT = _EnrollmentRoutes._();
  static final _PaymentRoutes PAYMENT = _PaymentRoutes._();

  // Legacy direct getters (backward compatibility)
  static String get login => AUTH.login;
  static String get register => AUTH.register;
  static String get verify => AUTH.verifyEmail;
  static String get oauth => AUTH.googleLogin;
  static String get resetPassword => AUTH.resetPassword;
  static String get resetPasswordToken => AUTH.requestResetPassword;
  static String get logout => AUTH.logout;
}

class _AuthRoutes {
  _AuthRoutes._();

  String get login => '${ApiRoutes.baseUrl}/Auth/login';
  String get register => '${ApiRoutes.baseUrl}/Auth/register';
  String get verifyEmail => '${ApiRoutes.baseUrl}/Auth/verify-email';
  String get googleLogin => '${ApiRoutes.baseUrl}/Auth/google-login';
  String get resetPassword => '${ApiRoutes.baseUrl}/Auth/reset-password';
  String get requestResetPassword =>
      '${ApiRoutes.baseUrl}/Auth/token-reset-password';
  String get logout => '${ApiRoutes.baseUrl}/Auth/logout';
}

class _UserRoutes {
  _UserRoutes._();

  String updateProfile(String userId) =>
      '${ApiRoutes.baseUrl}/User/$userId/profile';
  String changeAvatar(String userId) =>
      '${ApiRoutes.baseUrl}/User/$userId/avatar';
  // Auth related but user specific
  String changePassword(String userId) =>
      '${ApiRoutes.baseUrl}/Auth/change-password';
}

class _StorageRoutes {
  _StorageRoutes._();

  String upload(String type) => '${ApiRoutes.baseUrl}/api/files/$type';
  String delete(String fileId) => '${ApiRoutes.baseUrl}/api/files/$fileId';
}

class _CourseRoutes {
  _CourseRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Course';
  String get create => '${ApiRoutes.baseUrl}/Course/create';
  String byId(String courseId) => '${ApiRoutes.baseUrl}/Course/get/$courseId';
  String content(String courseId) =>
      '${ApiRoutes.baseUrl}/Course/getLessons/$courseId';
  String modules(String courseId) =>
      '${ApiRoutes.baseUrl}/Course/getModules/$courseId';
  String update(String courseId) =>
      '${ApiRoutes.baseUrl}/Course/update/$courseId';
  String delete(String courseId) => '${ApiRoutes.baseUrl}/Course/$courseId';
}

class _ModuleRoutes {
  _ModuleRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Module';
  String get create => '${ApiRoutes.baseUrl}/Module/create';
  String byId(String moduleId) => '${ApiRoutes.baseUrl}/Module/get/$moduleId';
  String lessons(String moduleId) => '${ApiRoutes.baseUrl}/Module/$moduleId';
  String update(String moduleId) =>
      '${ApiRoutes.baseUrl}/Module/update/$moduleId';
  String delete(String moduleId) => '${ApiRoutes.baseUrl}/Module/$moduleId';
}

class _LessonRoutes {
  _LessonRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Lesson';
  String get create => '${ApiRoutes.baseUrl}/Lesson/create';
  String byId(String lessonId) => '${ApiRoutes.baseUrl}/Lesson/get/$lessonId';
  String update(String lessonId) =>
      '${ApiRoutes.baseUrl}/Lesson/update/$lessonId';
  String delete(String lessonId) => '${ApiRoutes.baseUrl}/Lesson/$lessonId';
}

class _CategoryRoutes {
  _CategoryRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Category';
  String get create => '${ApiRoutes.baseUrl}/Category/create';
  String byId(String categoryId) => '${ApiRoutes.baseUrl}/Category/$categoryId';
}

class _QuizRoutes {
  _QuizRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Quiz';
  String get create => '${ApiRoutes.baseUrl}/Quiz/create';
  String byId(String quizId) => '${ApiRoutes.baseUrl}/Quiz/$quizId';
  String byLesson(String lessonId) =>
      '${ApiRoutes.baseUrl}/Quiz/lessonId/$lessonId';
  String submit() => '${ApiRoutes.baseUrl}/Quiz/submit';
  String attempts(String quizId) =>
      '${ApiRoutes.baseUrl}/Quiz/Attempts/$quizId';
  String update(String quizId) => '${ApiRoutes.baseUrl}/Quiz/update/$quizId';
  String delete(String quizId) => '${ApiRoutes.baseUrl}/Quiz/$quizId';
  String results(String lessonId) =>
      '${ApiRoutes.baseUrl}/Quiz/results/$lessonId';
  String begin(String quizId) => '${ApiRoutes.baseUrl}/Quiz/$quizId/begin';
}

class _WishlistRoutes {
  _WishlistRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Wishlist/get';
  String add(String courseId) => '${ApiRoutes.baseUrl}/Wishlist/add/$courseId';
  String remove(String courseId) =>
      '${ApiRoutes.baseUrl}/Wishlist/remove/$courseId';
}

class _EnrollmentRoutes {
  _EnrollmentRoutes._();

  String get list => '${ApiRoutes.baseUrl}/Enrollment/my-courses';
  String enroll(String courseId) =>
      '${ApiRoutes.baseUrl}/Enrollment/enroll/$courseId';
  String getCourse(String courseId) =>
      '${ApiRoutes.baseUrl}/Enrollment/getCourse/$courseId';
  String update() => '${ApiRoutes.baseUrl}/Enrollment/update';
  String updateProgress() => '${ApiRoutes.baseUrl}/Enrollment/update-progress';
  String updateCurrentView() =>
      '${ApiRoutes.baseUrl}/Enrollment/update-current-view';
  String completedLessons(String enrollmentId) =>
      '${ApiRoutes.baseUrl}/Enrollment/completed-lessons/$enrollmentId';
  String isEnrolled(String courseId) =>
      '${ApiRoutes.baseUrl}/Enrollment/is-enrolled/$courseId';
}

class _PaymentRoutes {
  _PaymentRoutes._();

  // Cart routes
  String get getCart => '${ApiRoutes.baseUrl}/Payment/getCart';
  String addToCart(String courseId) =>
      '${ApiRoutes.baseUrl}/Payment/addToCart/$courseId';
  String removeFromCart(String courseId) =>
      '${ApiRoutes.baseUrl}/Payment/removeFromCart/$courseId';

  // Payment routes
  String get createPayment => '${ApiRoutes.baseUrl}/Payment/createPayment';
  String get getPayment => '${ApiRoutes.baseUrl}/Payment/payment';
  String get listPayments => '${ApiRoutes.baseUrl}/Payment/list-payments';
  String get updatePayment => '${ApiRoutes.baseUrl}/Payment/update-payment';
  String get createPaymentIntent =>
      '${ApiRoutes.baseUrl}/Payment/create-payment-intent';
  String get webhook => '${ApiRoutes.baseUrl}/Payment/webhook';
}
