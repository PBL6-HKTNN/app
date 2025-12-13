import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/payment/models/dto/payment_requests.dart';
import 'package:codemy_app/src/features/payment/models/entities/cart_item.dart';
import 'package:codemy_app/src/features/payment/models/entities/payment_data.dart';
import 'package:codemy_app/src/features/payment/models/entities/payment_intent_data.dart';

/// Service for payment-related API calls
class PaymentService {
  PaymentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  // ============ Cart Services ============

  /// Get user's cart items
  Future<ApiRes<List<CartItem>>> getCart() async {
    try {
      final response = await _apiClient.get(ApiRoutes.PAYMENT.getCart);
      return ApiRes<List<CartItem>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to fetch cart', tag: 'PAYMENT', error: error);
      return ApiRes<List<CartItem>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Add a course to cart
  Future<ApiRes<void>> addToCart(String courseId) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.PAYMENT.addToCart(courseId),
      );
      return ApiRes<void>.fromJson(response, null);
    } catch (error) {
      Logger.error('Failed to add to cart', tag: 'PAYMENT', error: error);
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Remove a course from cart
  Future<ApiRes<void>> removeFromCart(String courseId) async {
    try {
      final response = await _apiClient.delete(
        ApiRoutes.PAYMENT.removeFromCart(courseId),
      );
      return ApiRes<void>.fromJson(response, null);
    } catch (error) {
      Logger.error('Failed to remove from cart', tag: 'PAYMENT', error: error);
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  // ============ Payment Services ============

  /// Create a new payment
  Future<ApiRes<PaymentData>> createPayment(PaymentRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.PAYMENT.createPayment,
        body: request.toJson(),
      );
      return ApiRes<PaymentData>.fromJson(
        response,
        (data) => PaymentData.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create payment', tag: 'PAYMENT', error: error);
      return ApiRes<PaymentData>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Get current pending payment
  Future<ApiRes<PaymentData>> getPayment() async {
    try {
      final response = await _apiClient.get(ApiRoutes.PAYMENT.getPayment);
      return ApiRes<PaymentData>.fromJson(
        response,
        (data) => PaymentData.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to get payment', tag: 'PAYMENT', error: error);
      return ApiRes<PaymentData>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// List all user payments
  Future<ApiRes<List<PaymentData>>> listPayments() async {
    try {
      final response = await _apiClient.get(ApiRoutes.PAYMENT.listPayments);
      return ApiRes<List<PaymentData>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => PaymentData.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to list payments', tag: 'PAYMENT', error: error);
      return ApiRes<List<PaymentData>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Update payment status
  Future<ApiRes<PaymentData>> updatePayment(
    UpdatePaymentRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.PAYMENT.updatePayment,
        body: request.toJson(),
      );
      return ApiRes<PaymentData>.fromJson(
        response,
        (data) => PaymentData.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to update payment', tag: 'PAYMENT', error: error);
      return ApiRes<PaymentData>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Create Stripe payment intent
  Future<ApiRes<PaymentIntentData>> createPaymentIntent(
    PaymentIntentRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.PAYMENT.createPaymentIntent,
        body: request.toJson(),
      );
      return ApiRes<PaymentIntentData>.fromJson(
        response,
        (data) => PaymentIntentData.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to create payment intent',
        tag: 'PAYMENT',
        error: error,
      );
      return ApiRes<PaymentIntentData>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Process webhook (typically called by backend, but included for completeness)
  Future<ApiRes<void>> processWebhook(Map<String, dynamic> webhookData) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.PAYMENT.webhook,
        body: webhookData,
      );
      return ApiRes<void>.fromJson(response, null);
    } catch (error) {
      Logger.error('Failed to process webhook', tag: 'PAYMENT', error: error);
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
