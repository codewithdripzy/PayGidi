// import 'package:app/core/config/app_config.dart';
import 'package:app/core/network/api_response.dart';
import 'package:app/core/network/api_service.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<ApiResponse<AuthResponseData>> initiateAuth(
    AuthRequest request,
  ) async {
    try {
      // debugPrint("$request");
      final response = await _apiService.post('/auth', data: request.toJson());
      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<AuthResponseData>> verifyOTP(
    VerifyOtpRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/verify',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<AuthResponseData>> completeIndividualAccount(
    IndividualCompleteAccountRequest request, {
    String? token,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/complete',
        data: request.toJson(),
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> registerBiometric(
    BiometricRegisterRequest request,
  ) async {
    try {
      await _apiService.post(
        '/auth/biometric/register',
        data: request.toJson(),
      );
      return ApiResponse(data: null);
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<AuthResponseData>> fetchCurrentUser() async {
    try {
      final response = await _apiService.get('/account/me');
      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<AuthResponseData>> authenticateBiometric(
    BiometricAuthRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/biometric/login',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => AuthResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        null,
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }
}
