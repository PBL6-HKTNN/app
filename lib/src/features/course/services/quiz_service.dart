import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/quiz_requests.dart';
import 'package:codemy_app/src/features/course/models/dto/quiz_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_submission_result.dart';

class QuizService {
  QuizService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<Quiz>> createQuiz(CreateQuizRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.QUIZ.create,
        body: request.toJson(),
      );
      return ApiRes<Quiz>.fromJson(
        response,
        (data) => Quiz.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create quiz', tag: 'QUIZ', error: error);
      return ApiRes<Quiz>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Quiz>> getQuizById(String quizId) async {
    final url = ApiRoutes.QUIZ.byId(quizId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Quiz>.fromJson(
        response,
        (data) => Quiz.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to fetch quiz detail', tag: 'QUIZ', error: error);
      return ApiRes<Quiz>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Quiz>> getQuizByLessonId(String lessonId) async {
    final url = ApiRoutes.QUIZ.byLesson(lessonId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Quiz>.fromJson(
        response,
        (data) => Quiz.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to fetch quiz by lesson', tag: 'QUIZ', error: error);
      return ApiRes<Quiz>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Quiz>> updateQuiz(
    String quizId,
    UpdateQuizRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.QUIZ.update(quizId),
        body: request.toJson(),
      );
      return ApiRes<Quiz>.fromJson(
        response,
        (data) => Quiz.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to update quiz', tag: 'QUIZ', error: error);
      return ApiRes<Quiz>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<String>> deleteQuiz(String quizId) async {
    try {
      final response = await _apiClient.delete(ApiRoutes.QUIZ.delete(quizId));
      return ApiRes<String>.fromJson(
        response,
        (data) => data?.toString() ?? '',
      );
    } catch (error) {
      Logger.error('Failed to delete quiz', tag: 'QUIZ', error: error);
      return ApiRes<String>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<QuizSubmissionResult>> submitQuiz(
    QuizSubmissionRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.QUIZ.submit(),
        body: request.toJson(),
      );
      return ApiRes<QuizSubmissionResult>.fromJson(
        response,
        (data) => QuizSubmissionResult.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to submit quiz', tag: 'QUIZ', error: error);
      return ApiRes<QuizSubmissionResult>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<QuizStartAttempt>> beginQuizAttempt(String quizId) async {
    final url = ApiRoutes.QUIZ.attempts(quizId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<QuizStartAttempt>.fromJson(
        response,
        (data) => QuizStartAttempt.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to begin quiz attempt', tag: 'QUIZ', error: error);
      return ApiRes<QuizStartAttempt>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Map<String, dynamic>>> submitQuizInVideo(
    String videoCheckpointId,
    String answer,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.QUIZ.submitQuizInVideo(),
        body: {'videoCheckpointId': videoCheckpointId, 'answer': answer},
      );
      return ApiRes<Map<String, dynamic>>.fromJson(
        response,
        (data) => Map<String, dynamic>.from(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to submit quiz in video', tag: 'QUIZ', error: error);
      return ApiRes<Map<String, dynamic>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
