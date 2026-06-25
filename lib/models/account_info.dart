class AccountInfo {
  final String userId, name, email, phoneNumber, role, joinedOn, avatar;

  const AccountInfo({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.joinedOn,
    required this.avatar,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> j) {
    final a = (j['account'] as Map<String, dynamic>?) ?? {};

    return AccountInfo(
      userId: a['user_id']?.toString() ?? '',
      name: a['name']?.toString() ?? '',
      email: a['email']?.toString() ?? '',
      phoneNumber: a['phone_number']?.toString() ?? '',
      role: a['role']?.toString() ?? '',
      joinedOn: a['joined_on']?.toString() ?? '',
      avatar: a['avatar']?.toString() ?? '',
    );
  }
}
