import 'package:app/core/network/api_response.dart';
import 'package:app/core/network/api_service.dart';
import 'package:app/features/wallet/data/models/bank_model.dart';
import 'package:app/features/wallet/data/models/virtual_account_model.dart';
import 'package:app/features/wallet/data/models/wallet_balance_model.dart';
import 'package:dio/dio.dart';

class WalletRepository {
  final ApiService _apiService;

  WalletRepository(this._apiService);

  Future<ApiResponse<WalletBalance>> getBalance() async {
    try {
      final response = await _apiService.get('/wallet');
      return ApiResponse.fromJson(
        response.data,
        (json) => WalletBalance.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<List<Bank>>> getBanks() async {
    try {
      final response = await _apiService.get('/wallet/banks');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => Bank.fromJson(e)).toList(),
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

  Future<ApiResponse<VirtualAccount>> getVirtualAccount() async {
    try {
      final response = await _apiService.get('/wallet/virtual-account');
      return ApiResponse.fromJson(
        response.data,
        (json) => VirtualAccount.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<Map<String, dynamic>>> verifyAccountNumber({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await _apiService.post(
        '/wallet/verify-account',
        data: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
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

  Future<ApiResponse<void>> transfer({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String pin,
    String? narration,
  }) async {
    try {
      await _apiService.post(
        '/wallet/transfer',
        data: {
          'amount': amount,
          'accountNumber': accountNumber,
          'bankCode': bankCode,
          'pin': pin,
          'narration': narration,
        },
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
}
