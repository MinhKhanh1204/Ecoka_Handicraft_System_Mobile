import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/user.dart';
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

  Future<User> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return User.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Lấy thông tin hồ sơ thất bại');
    }
    throw Exception('Lấy thông tin hồ sơ thất bại');
  }

  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarPath,
  }) async {
    final formData = FormData();

    if (fullName != null && fullName.isNotEmpty) {
      formData.fields.add(MapEntry('fullName', fullName));
    }
    if (phone != null && phone.isNotEmpty) {
      formData.fields.add(MapEntry('phone', phone));
    }
    if (address != null && address.isNotEmpty) {
      formData.fields.add(MapEntry('address', address));
    }
    if (dateOfBirth != null) {
      formData.fields.add(MapEntry('dateOfBirth', dateOfBirth.toIso8601String()));
    }
    if (gender != null && gender.isNotEmpty) {
      formData.fields.add(MapEntry('gender', gender));
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(avatarPath),
      ));
    }

    final response = await _apiClient.put(
      ApiConstants.profile,
      data: formData,
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return User.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Cập nhật hồ sơ thất bại');
    }
    throw Exception('Cập nhật hồ sơ thất bại');
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
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

  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Gửi yêu cầu quên mật khẩu thất bại');
    }
    throw Exception('Gửi yêu cầu quên mật khẩu thất bại');
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
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
}

class LoginResponse {
  final String accessToken;
  final String? userId;

  LoginResponse({required this.accessToken, this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['accessToken'] ?? '').toString();
    String? userId;

    // Decode JWT to extract userId / customerId
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // payload la phan thu 2 cua JWT
        String payload = parts[1];
        // Pad base64 string
        switch (payload.length % 4) {
          case 2: payload += '=='; break;
          case 3: payload += '='; break;
        }
        final decoded = utf8.decode(base64Url.decode(payload));
        final Map<String, dynamic> claims = jsonDecode(decoded);
        // Thu tim cac claim pho bien chua userId
        userId = (claims['CustomerID'] ?? claims['customerId'] ?? claims['customerID']
            ?? claims['sub'] ?? claims['nameid'] ?? claims['UserId']
            ?? claims['userId'] ?? claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'])
            ?.toString();
      }
    } catch (_) {}

    return LoginResponse(
      accessToken: token,
      userId: userId,
    );
  }
}

