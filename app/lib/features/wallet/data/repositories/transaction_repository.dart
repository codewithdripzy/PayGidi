import 'package:app/core/network/api_response.dart';
import 'package:app/core/network/api_service.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:dio/dio.dart';

class TransactionRepository {
  final ApiService _apiService;

  TransactionRepository(this._apiService);

  Future<ApiResponse<List<Transaction>>> getTransactions() async {
    try {
      final response = await _apiService.get('/transactions');
      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => Transaction.fromJson(e)).toList();
          } else if (json is Map && json['transactions'] is List) {
            return (json['transactions'] as List)
                .map((e) => Transaction.fromJson(e))
                .toList();
          }
          return [];
        },
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
