class SavingsGoal {
  final int id;
  final int userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final String status;
  final String createdAt;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.currency = 'NGN',
    this.status = 'active',
    required this.createdAt,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
}
