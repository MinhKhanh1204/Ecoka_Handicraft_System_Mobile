class User {
  final String? accountId;
  final String? customerId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? gender;
  final String? avatar;
  final String? status;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;

  User({
    this.accountId,
    this.customerId,
    this.username,
    this.email,
    this.fullName,
    this.phone,
    this.address,
    this.gender,
    this.avatar,
    this.status,
    this.dateOfBirth,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final parsedCustomerId =
        json['customerId']?.toString() ?? json['customerID']?.toString();

    final parsedAccountId =
        json['accountId']?.toString() ??
            json['accountID']?.toString() ??
            parsedCustomerId;

    return User(
      accountId: parsedAccountId,
      customerId: parsedCustomerId,
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}