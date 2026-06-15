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
  final String? nin;
  final String address;
  final String bvn;
  final String? referralCode;
  final String gender;

  IndividualCompleteAccountRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    this.nin,
    required this.address,
    required this.bvn,
    this.referralCode,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'email': email,
        if (nin != null) 'nin': nin,
        'address': address,
        'bvn': bvn,
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
  final bool hasPin;

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
    this.hasPin = false,
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
      hasPin: json['hasPin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'accountType': accountType,
        'needsOnboarding': needsOnboarding,
        'requiredAction': requiredAction,
        'hasPin': hasPin,
      };
}

class BiometricRegisterRequest {
  final String biometricID;

  BiometricRegisterRequest({required this.biometricID});

  Map<String, dynamic> toJson() => {
        'biometricID': biometricID,
      };
}

class BiometricAuthRequest {
  final String biometricID;
  final String phone;

  BiometricAuthRequest({required this.biometricID, required this.phone});

  Map<String, dynamic> toJson() => {
        'biometricID': biometricID,
        'phone': phone,
      };
}
