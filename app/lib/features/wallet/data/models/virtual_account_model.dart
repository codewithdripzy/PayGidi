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
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final name = '${firstName} ${lastName}'.trim();

    return VirtualAccount(
      accountNumber: json['virtual_account_number'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? json['bank_code'] as String? ?? '',
      accountName: name.isNotEmpty ? name : (json['account_name'] as String? ?? ''),
    );
  }
}
