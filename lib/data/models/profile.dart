class UserProfile {
  final String accountId;
  final String username;
  final String email;
  final String? avatar;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  UserProfile({
    required this.accountId,
    required this.username,
    required this.email,
    this.avatar,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
  });

  /// Builds full URL for avatar. API may return full URL or just path/filename (Cloudinary folder: account_avatars).
  String get fullAvatarUrl {
    final img = avatar;
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    final path = img.startsWith('account_avatars/') ? img : 'account_avatars/$img';
    return 'https://res.cloudinary.com/drqtjmvfc/image/upload/$path';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      accountId: (json['accountId'] ?? json['AccountId'] ?? '').toString(),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      fullName: json['fullName']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      gender: json['gender']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'username': username,
      'email': email,
      'avatar': avatar,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'address': address,
    };
  }

  UserProfile copyWith({
    String? accountId,
    String? username,
    String? email,
    String? avatar,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? address,
  }) {
    return UserProfile(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
