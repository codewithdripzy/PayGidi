class WalletBalance {
  final double totalBalance;
  final double personalSavings;
  final double thriftSavings;

  WalletBalance({
    required this.totalBalance,
    required this.personalSavings,
    required this.thriftSavings,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      totalBalance: (json['totalBalance'] ?? json['balance'] ?? 0.0).toDouble(),
      personalSavings: (json['personalSavings'] ?? 0.0).toDouble(),
      thriftSavings: (json['thriftSavings'] ?? 0.0).toDouble(),
    );
  }
}
