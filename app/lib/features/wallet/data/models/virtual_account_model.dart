class VirtualAccount {
  final String accountNumber;
  final String bankName;
  final String accountName;

  VirtualAccount({
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountNumber: json['accountNumber'] ?? json['account_number'] ?? '',
      bankName: json['bankName'] ?? json['bank_name'] ?? '',
      accountName: json['accountName'] ?? json['account_name'] ?? '',
    );
  }
}
