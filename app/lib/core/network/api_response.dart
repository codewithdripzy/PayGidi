class ApiResponse<T> {
  final String? message;
  final T? data;
  final String? code;
  final String? error;

  ApiResponse({this.message, this.data, this.code, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      message: json['message'] as String?,
      code: json['code']?.toString(),
      error: json['error'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  bool get isSuccess => error == null && code == null;
}
