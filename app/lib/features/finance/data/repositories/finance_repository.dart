import 'package:app/core/network/api_response.dart';
import 'package:app/core/network/api_service.dart';
import 'package:app/features/finance/data/models/savings_goal_model.dart';
import 'package:app/features/finance/data/models/thrift_model.dart';
import 'package:app/features/wallet/data/models/wallet_balance_model.dart';
import 'package:dio/dio.dart';

class FinanceRepository {
  final ApiService _apiService;

  FinanceRepository(this._apiService);

  Future<ApiResponse<WalletBalance>> getSummary() async {
    try {
      final response = await _apiService.get('/wallet/finance/summary');
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

  Future<ApiResponse<List<SavingsGoal>>> getSavingsGoals() async {
    try {
      final response = await _apiService.get('/wallet/finance/savings');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
            .toList(),
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

  Future<ApiResponse<SavingsGoal>> createSavingsGoal({
    required String name,
    required double targetAmount,
  }) async {
    try {
      final response = await _apiService.post(
        '/wallet/finance/savings',
        data: {'name': name, 'targetAmount': targetAmount},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<SavingsGoal>> updateSavingsGoal({
    required int id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (targetAmount != null) data['targetAmount'] = targetAmount;
      if (currentAmount != null) data['currentAmount'] = currentAmount;
      if (status != null) data['status'] = status;

      final response = await _apiService.put(
        '/wallet/finance/savings/$id',
        data: data,
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => SavingsGoal.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<void>> deleteSavingsGoal(int id) async {
    try {
      await _apiService.delete('/wallet/finance/savings/$id');
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

  Future<ApiResponse<List<Thrift>>> getThrifts() async {
    try {
      final response = await _apiService.get('/wallet/finance/thrifts');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => Thrift.fromJson(e as Map<String, dynamic>))
            .toList(),
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

  Future<ApiResponse<Thrift>> createThrift({
    required String name,
    String? description,
    required double contributionAmount,
    String contributionFrequency = 'monthly',
    int maxMembers = 0,
    bool isPublic = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/wallet/finance/thrifts',
        data: {
          'name': name,
          'description': description ?? '',
          'contributionAmount': contributionAmount,
          'contributionFrequency': contributionFrequency,
          'maxMembers': maxMembers,
          'isPublic': isPublic,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => Thrift.fromJson(json as Map<String, dynamic>),
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

  Future<ApiResponse<void>> joinThrift(int thriftId) async {
    try {
      await _apiService.post('/wallet/finance/thrifts/$thriftId/join');
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
