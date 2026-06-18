class Bank {
  final String name;
  final String code;
  final String? icon;

  Bank({
    required this.name,
    required this.code,
    this.icon,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'icon': icon,
    };
  }
}
