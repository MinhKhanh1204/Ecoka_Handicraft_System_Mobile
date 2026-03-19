import 'dart:convert';

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

