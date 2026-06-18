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
  final String bvn;
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

// Person Model
class Person {
  final int id;
  final String firstName;
  final String lastName;
  final String middleName;
  final String address;
  final String? otherNames;
  final String gender;
  final String dateOfBirth;
  final String country;
  final String state;
  final String city;
  final String postalCode;
  final int userID;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.address,
    this.otherNames,
    required this.gender,
    required this.dateOfBirth,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.userID,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String,
      address: json['address'] as String,
      otherNames: json['otherNames'] as String?,
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      country: json['country'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      userID: json['UserID'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'middleName': middleName,
    'address': address,
    'otherNames': otherNames,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'country': country,
    'state': state,
    'city': city,
    'postalCode': postalCode,
    'UserID': userID,
  };
}

// AuthInfo Model
class AuthInfo {
  final int id;
  final int userID;
  final String lastLoginAt;
  final int loginAttempts;
  final int otpRequestCount;
  final String createdAt;
  final String updatedAt;

  AuthInfo({
    required this.id,
    required this.userID,
    required this.lastLoginAt,
    required this.loginAttempts,
    required this.otpRequestCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      id: json['id'] as int,
      userID: json['userID'] as int,
      lastLoginAt: json['lastLoginAt'] as String,
      loginAttempts: json['loginAttempts'] as int,
      otpRequestCount: json['otpRequestCount'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userID': userID,
    'lastLoginAt': lastLoginAt,
    'loginAttempts': loginAttempts,
    'otpRequestCount': otpRequestCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// Business Model
class Business {
  final int id;
  final int userId;
  final String name;
  final String registrationNumber;
  final String type;
  final String industry;
  final String? additionalDocs;
  final String createdAt;
  final String updatedAt;

  Business({
    required this.id,
    required this.userId,
    required this.name,
    required this.registrationNumber,
    required this.type,
    required this.industry,
    this.additionalDocs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      type: json['type'] as String,
      industry: json['industry'] as String,
      additionalDocs: json['additionalDocs'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'registrationNumber': registrationNumber,
    'type': type,
    'industry': industry,
    'additionalDocs': additionalDocs,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// Preferences Model
class Preferences {
  final int id;
  final int userId;
  final String theme;
  final String language;
  final String timezone;
  final bool notificationsEnabled;
  final String createdAt;
  final String updatedAt;

  Preferences({
    required this.id,
    required this.userId,
    required this.theme,
    required this.language,
    required this.timezone,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      id: json['id'] as int,
      userId: json['userId'] as int,
      theme: json['theme'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'theme': theme,
    'language': language,
    'timezone': timezone,
    'notificationsEnabled': notificationsEnabled,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// User Model (PgUser to avoid conflict with Flutter's User)
class PgUser {
  final int id;
  final String uid;
  final String phone;
  final String email;
  final String username;
  final Person? person;
  final String hashedNIN;
  final List<dynamic>? kycs; // Assuming dynamic for now, can be modeled later
  final List<dynamic>? contact; // Assuming dynamic for now
  final bool twoFactorEnabled;
  final bool isFirstTime;
  final bool emailVerified;
  final bool phoneVerified;
  final String accountType;
  final AuthInfo? authInfo;
  final Business? business;
  final List<dynamic>? sessions; // Assuming dynamic for now
  final List<dynamic>? activities; // Assuming dynamic for now
  final Preferences? preferences;
  final List<dynamic>? roles; // Assuming dynamic for now
  final bool biometricEnabled;
  final String biometricID;
  final String status;
  final List<dynamic>? otps; // Assuming dynamic for now
  final String createdAt;
  final String updatedAt;
  final bool? hasPin; // Added hasPin

  PgUser({
    required this.id,
    required this.uid,
    required this.phone,
    required this.email,
    required this.username,
    this.person,
    this.hashedNIN = '',
    this.kycs,
    this.contact,
    required this.twoFactorEnabled,
    required this.isFirstTime,
    required this.emailVerified,
    required this.phoneVerified,
    required this.accountType,
    this.authInfo,
    this.business,
    this.sessions,
    this.activities,
    this.preferences,
    this.roles,
    required this.biometricEnabled,
    this.biometricID = '',
    required this.status,
    this.otps,
    required this.createdAt,
    required this.updatedAt,
    this.hasPin, // Added hasPin to constructor
  });

  factory PgUser.fromJson(Map<String, dynamic> json) {
    return PgUser(
      id: json['id'] as int,
      uid: json['uid'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      person: json['Person'] != null ? Person.fromJson(json['Person']) : null,
      hashedNIN: json['hashedNIN'] as String? ?? '',
      kycs: json['kycs'] as List<dynamic>?,
      contact: json['contact'] as List<dynamic>?,
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      isFirstTime: json['isFirstTime'] as bool,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      accountType: json['accountType'] as String,
      authInfo:
      json['authInfo'] != null ? AuthInfo.fromJson(json['authInfo']) : null,
      business:
      json['business'] != null ? Business.fromJson(json['business']) : null,
      sessions: json['sessions'] as List<dynamic>?,
      activities: json['activities'] as List<dynamic>?,
      preferences: json['preferences'] != null
          ? Preferences.fromJson(json['preferences'])
          : null,
      roles: json['roles'] as List<dynamic>?,
      biometricEnabled: json['biometricEnabled'] as bool,
      biometricID: json['biometricID'] as String? ?? '',
      status: json['status'] as String,
      otps: json['otps'] as List<dynamic>?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      hasPin: json['hasPin'] as bool?, // Added hasPin to fromJson
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'phone': phone,
    'email': email,
    'username': username,
    'Person': person?.toJson(),
    'hashedNIN': hashedNIN,
    'kycs': kycs,
    'contact': contact,
    'twoFactorEnabled': twoFactorEnabled,
    'isFirstTime': isFirstTime,
    'emailVerified': emailVerified,
    'phoneVerified': phoneVerified,
    'accountType': accountType,
    'authInfo': authInfo?.toJson(),
    'business': business?.toJson(),
    'sessions': sessions,
    'activities': activities,
    'preferences': preferences?.toJson(),
    'roles': roles,
    'biometricEnabled': biometricEnabled,
    'biometricID': biometricID,
    'status': status,
    'otps': otps,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'hasPin': hasPin, // Added hasPin to toJson
  };
}

// Wallet Model - Basic structure for now, can be expanded
class Wallet {
  final int id;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String currency;
  final double availableBalance;
  final double ledgerBalance;
  final String status;
  final String createdAt;
  final String updatedAt;

  Wallet({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.currency,
    required this.availableBalance,
    required this.ledgerBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as int,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      currency: json['currency'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      ledgerBalance: (json['ledgerBalance'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'bankName': bankName,
    'currency': currency,
    'availableBalance': availableBalance,
    'ledgerBalance': ledgerBalance,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
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

// AccountResponse for /me endpoint
class AccountResponse {
  final AccountResponseData data;
  final String message;

  AccountResponse({required this.data, required this.message});

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      data: AccountResponseData.fromJson(json['data']),
      message: json['message'] as String,
    );
  }
}

class AccountResponseData {
  final PgUser user;
  final List<Wallet>? wallets;

  AccountResponseData({required this.user, this.wallets});

  factory AccountResponseData.fromJson(Map<String, dynamic> json) {
    return AccountResponseData(
      user: PgUser.fromJson(json['user']),
      wallets: (json['wallets'] as List<dynamic>?)
          ?.map((e) => Wallet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BiometricRegisterRequest {
  final String biometricID;

  BiometricRegisterRequest({required this.biometricID});

  Map<String, dynamic> toJson() => {'biometricID': biometricID};
}

class BiometricAuthRequest {
  final String biometricID;
  final String phone;

  BiometricAuthRequest({required this.biometricID, required this.phone});

  Map<String, dynamic> toJson() => {'biometricID': biometricID, 'phone': phone};
}
