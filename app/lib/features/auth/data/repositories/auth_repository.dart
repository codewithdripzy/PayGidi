// import 'package:app/core/config/app_config.dart';
import 'package:app/core/network/api_response.dart';
import 'package:app/core/network/api_service.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<ApiResponse<void>> requestOtp({
    required String phone,
    required String forWhat,
  }) async {
    try {
      await _apiService.post('/auth/otp/request/phone', data: {
        'phone': phone,
        'forWhat': forWhat,
      });
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

  Future<ApiResponse<void>> setPin({
    required String pin,
    required String confirmPin,
  }) async {
    try {
      await _apiService.post('/account/pin', data: {
        'pin': pin,
        'confirmPin': confirmPin,
      });
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

  Future<ApiResponse<void>> updatePin({
    required String oldPin,
    required String newPin,
    required String confirmPin,
  }) async {
    try {
      await _apiService.put('/account/pin', data: {
        'oldPin': oldPin,
        'newPin': newPin,
        'confirmPin': confirmPin,
      });
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

  Future<ApiResponse<void>> blockAccount() async {
    try {
      await _apiService.post('/account/block');
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

  Future<ApiResponse<void>> unblockAccount() async {
    try {
      await _apiService.post('/account/unblock');
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

  Future<ApiResponse<void>> reportIssue({
    required String subject,
    required String message,
  }) async {
    try {
      await _apiService.post('/account/report', data: {
        'subject': subject,
        'message': message,
      });
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

  Future<ApiResponse<void>> verifyIdentity({
    required String phone,
    required String code,
  }) async {
    try {
      await _apiService.post('/auth/verify', data: {
        'phone': phone,
        'otp': code,
        'forWhat': 'updatePin',
      });
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

  Future<ApiResponse<AccountResponse>> fetchCurrentUser() async {
    try {
      final response = await _apiService.get('/account/me');
      return ApiResponse.fromJson(
        response.data,
        (json) => AccountResponse.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<List<DeviceInfoModel>>> fetchDevices() async {
    try {
      final response = await _apiService.get('/account/devices');
      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => DeviceInfoModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <DeviceInfoModel>[];
        },
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        (json) => <DeviceInfoModel>[],
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<ReferralInfo>> fetchReferralInfo() async {
    try {
      final response = await _apiService.get('/account/referral');
      return ApiResponse.fromJson(
        response.data,
        (json) => ReferralInfo.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        (e.response?.data is Map)
            ? e.response?.data
            : {'error': e.response?.data.toString()},
        (json) => ReferralInfo.empty(),
      );
    } catch (e) {
      return ApiResponse(error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> removeDevice(int deviceId) async {
    try {
      await _apiService.delete('/account/devices/$deviceId');
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
}
