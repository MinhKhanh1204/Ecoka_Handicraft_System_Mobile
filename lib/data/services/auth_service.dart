import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return LoginResponse.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Đăng nhập thất bại');
    }
    throw Exception('Đăng nhập thất bại');
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    // Backend expects [FromForm]
    final formData = {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };
    final response = await _apiClient.post(
      ApiConstants.register,
      data: FormData.fromMap(formData),
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Đăng ký thất bại');
    }
    throw Exception('Đăng ký thất bại');
  }

  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Gửi yêu cầu thất bại');
    }
    throw Exception('Gửi yêu cầu thất bại');
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Đặt lại mật khẩu thất bại');
    }
    throw Exception('Đặt lại mật khẩu thất bại');
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    final response = await _apiClient.post(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Đổi mật khẩu thất bại');
    }
    throw Exception('Đổi mật khẩu thất bại');
  }

  Future<ProfileResponse> getProfile() async {
    final response = await _apiClient.get('/auth/profile');

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return ProfileResponse.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Lấy thông tin thất bại');
    }
    throw Exception('Lấy thông tin thất bại');
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final formData = {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      if (gender != null) 'gender': gender,
    };
    
    final response = await _apiClient.put(
      '/auth/profile',
      data: FormData.fromMap(formData),
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    }
    throw Exception('Cập nhật thất bại');
  }
}

class LoginResponse {
  final String accessToken;

  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
    );
  }
}

class ProfileResponse {
  final String accountId;
  final String username;
  final String email;
  final String? avatar;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;

  ProfileResponse({
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

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
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
}

