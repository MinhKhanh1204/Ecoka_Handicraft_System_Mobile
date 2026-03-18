import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/shared_prefs.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final ProfileResponse? profile;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
    this.profile,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
    ProfileResponse? profile,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthState(isLoggedIn: SharedPrefs.isLoggedIn());
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ref.read(authServiceProvider).login(email, password);
      await SharedPrefs.saveToken(res.accessToken);
      await SharedPrefs.setLoggedIn(true);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).register(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
            address: address,
            dateOfBirth: dateOfBirth,
            gender: gender,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await SharedPrefs.logout();
    state = state.copyWith(isLoggedIn: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<ProfileResponse?> getProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await ref.read(authServiceProvider).getProfile();
      state = state.copyWith(isLoading: false, profile: profile);
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      await getProfile();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).changePassword(
        oldPassword,
        newPassword,
        newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

