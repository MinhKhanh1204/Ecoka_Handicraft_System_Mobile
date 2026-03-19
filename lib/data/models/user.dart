class User {
  final String accountId;
  final String username;
  final String email;
  final String? avatar;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  User({
    required this.accountId,
    required this.username,
    required this.email,
    this.avatar,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accountId: (json['accountId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
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

  User copyWith({
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
    return User(
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
