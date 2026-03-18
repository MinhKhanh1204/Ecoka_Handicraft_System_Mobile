import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/profile.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return UserProfile.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Không thể tải thông tin hồ sơ');
    }
    throw Exception('Không thể tải thông tin hồ sơ');
  }

  Future<void> updateProfile({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? address,
    File? avatar,
  }) async {
    final formData = FormData();

    if (fullName != null) {
      formData.fields.add(MapEntry('FullName', fullName));
    }
    if (dateOfBirth != null) {
      formData.fields.add(MapEntry('DateOfBirth', dateOfBirth.toIso8601String()));
    }
    if (gender != null) {
      formData.fields.add(MapEntry('Gender', gender));
    }
    if (phone != null) {
      formData.fields.add(MapEntry('Phone', phone));
    }
    if (address != null) {
      formData.fields.add(MapEntry('Address', address));
    }

    if (avatar != null) {
      formData.files.add(MapEntry(
        'Avatar',
        await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        ),
      ));
    }

    final response = await _apiClient.put(
      ApiConstants.profile,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return;
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
        'OldPassword': oldPassword,
        'NewPassword': newPassword,
        'ConfirmPassword': confirmPassword,
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
}
