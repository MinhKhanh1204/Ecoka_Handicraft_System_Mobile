import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String username, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'username': username,
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

  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
    );
  }
}

