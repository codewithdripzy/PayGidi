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

  Map<String, dynamic> toJson() => {'phone': phone, 'otp': code};
}

class IndividualCompleteAccountRequest {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String email;
  final String? nin;
  final String address;
  final String? bvn;
  final String? referralCode;
  final String gender;
  final String? country;

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
    this.country,
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
        if (country != null) 'country': country,
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

class AutocompletePrediction {
  final String? description;
  final StructuredFormatting? structuredFormatting;
  final String? placeId;
  final String? reference;
  final List<dynamic> types;

  AutocompletePrediction({
    this.description,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    required this.types,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json["description"] as String?,
      placeId: json["place_id"] as String?,
      reference: json["reference"] as String?,
      structuredFormatting: json["structured_formatting"] != null
          ? StructuredFormatting.fromJson(json["structured_formatting"])
          : null,
      types: json['types'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "place_id": placeId,
      "reference": reference,
      "structured_formatting": structuredFormatting?.toJson(),
      "types": types,
    };
  }
}

class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json["main_text"] as String?,
      secondaryText: json["secondary_text"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {"main_text": mainText, "secondary_text": secondaryText};
  }
}

class MyPlacesAutocompleteResponse {
  final String? status;
  final List<AutocompletePrediction>? predictions;

  MyPlacesAutocompleteResponse({this.predictions, this.status});

  factory MyPlacesAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return MyPlacesAutocompleteResponse(
      status: json["status"] as String?,
      predictions: json["predictions"]
          ?.map<AutocompletePrediction>(
            (json) => AutocompletePrediction.fromJson(json),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "predictions": predictions?.map((e) => e.toJson()).toList(),
    };
  }
}
