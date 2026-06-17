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
    String? errorMessage = json['error'] as String?;
    if (errorMessage == null && json['errors'] != null) {
      if (json['errors'] is List) {
        errorMessage = (json['errors'] as List).join(', ');
      } else if (json['errors'] is Map) {
        errorMessage = (json['errors'] as Map).values.join(', ');
      } else {
        errorMessage = json['errors'].toString();
      }
    }

    return ApiResponse<T>(
      message: json['message'] as String?,
      code: json['code']?.toString() ??
          (json['status'] == false ? 'ERROR' : null),
      error: errorMessage,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  bool get isSuccess => error == null && (code == null || code == '200');
}
