class Thrift {
  final int id;
  final int creatorId;
  final String name;
  final String description;
  final double contributionAmount;
  final String contributionFrequency;
  final int maxMembers;
  final int currentMembers;
  final bool isPublic;
  final bool isMember;
  final String status;
  final String createdAt;

  Thrift({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description = '',
    required this.contributionAmount,
    this.contributionFrequency = 'monthly',
    this.maxMembers = 0,
    this.currentMembers = 1,
    this.isPublic = false,
    this.isMember = false,
    this.status = 'active',
    required this.createdAt,
  });

  factory Thrift.fromJson(Map<String, dynamic> json) {
    return Thrift(
      id: json['id'] as int? ?? 0,
      creatorId: json['creatorId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contributionAmount: (json['contributionAmount'] as num?)?.toDouble() ?? 0.0,
      contributionFrequency: json['contributionFrequency'] as String? ?? 'monthly',
      maxMembers: json['maxMembers'] as int? ?? 0,
      currentMembers: json['currentMembers'] as int? ?? 1,
      isPublic: json['isPublic'] as bool? ?? false,
      isMember: json['isMember'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
