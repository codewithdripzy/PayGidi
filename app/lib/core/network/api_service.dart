import 'dart:ui';
import 'package:flutter/foundation.dart';

import 'package:app/core/config/app_config.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  VoidCallback? onUnauthorized;
  final AuthStorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and auth
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("--- ApiService: Requesting token from storage ---");
          final token = await _storageService.getToken();
          if (token != null) {
            debugPrint("--- ApiService: Token found: ${token.substring(0, 10)}... ---");
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint("--- ApiService: No token found in storage ---");
          }
          debugPrint("--- ApiService: Headers: ${options.headers} ---");
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint("--- ApiService: Error Response: ${e.response?.statusCode} - ${e.response?.data} ---");
          // Handle global errors like 401 Unauthorized
          if (e.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );

    // Optional: Add LogInterceptor for development
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
