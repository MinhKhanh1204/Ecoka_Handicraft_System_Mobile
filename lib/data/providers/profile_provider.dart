import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/shared_prefs.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

part 'profile_provider.g.dart';

class ProfileState {
  final bool isLoading;
  final UserProfile? profile;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

@riverpod
ProfileService profileService(ProfileServiceRef ref) => ProfileService();

@riverpod
class ProfileController extends _$ProfileController {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await ref.read(profileServiceProvider).getProfile();
      await _saveToSharedPrefs(profile);
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? address,
    File? avatar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(profileServiceProvider).updateProfile(
            fullName: fullName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            phone: phone,
            address: address,
            avatar: avatar,
          );
      await fetchProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(profileServiceProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> _saveToSharedPrefs(UserProfile profile) async {
    await SharedPrefs.saveUserId(profile.accountId);
    await SharedPrefs.saveUserName(profile.username);
    await SharedPrefs.saveUserEmail(profile.email);
    if (profile.fullName != null) {
      await SharedPrefs.saveUserFullName(profile.fullName!);
    }
    if (profile.avatar != null) {
      await SharedPrefs.saveUserAvatar(profile.avatar);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
