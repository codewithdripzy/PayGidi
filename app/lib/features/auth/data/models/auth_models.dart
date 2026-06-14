class AuthRequest {
  final String phone;
  final String? accountType;

  AuthRequest({required this.phone, this.accountType});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        if (accountType != null) 'accountType': accountType,
      };
}

class VerifyOtpRequest {
  final String phone;
  final String code;

  VerifyOtpRequest({required this.phone, required this.code});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': code,
      };
}

class IndividualCompleteAccountRequest {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String email;
  final String nin;
  final String address;
  final String? bvn;
  final String? referralCode;
  final String gender;

  IndividualCompleteAccountRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.nin,
    required this.address,
    this.bvn,
    this.referralCode,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'email': email,
        'nin': nin,
        'address': address,
        if (bvn != null) 'bvn': bvn,
        if (referralCode != null) 'referralCode': referralCode,
        'gender': gender,
      };
}

class AuthResponseData {
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? accountType;
  final bool? needsOnboarding;
  final String? requiredAction;

  AuthResponseData({
    this.token,
    this.refreshToken,
    this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.accountType,
    this.needsOnboarding,
    this.requiredAction,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      accountType: json['accountType'] as String?,
      needsOnboarding: json['needsOnboarding'] as bool?,
      requiredAction: json['requiredAction'] as String?,
    );
  }
}
