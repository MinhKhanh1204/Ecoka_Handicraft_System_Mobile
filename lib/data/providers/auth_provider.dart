import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/shared_prefs.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
      user: user ?? this.user,
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

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ref.read(authServiceProvider).login(username, password);
      await SharedPrefs.saveToken(res.accessToken);
      if (res.userId != null) {
        await SharedPrefs.saveUserId(res.userId!);
        print('--- [Auth] Login thành công, userId/customerId = ${res.userId} ---');
      }
      await SharedPrefs.setLoggedIn(true);

      // Fetch and save user profile
      try {
        final user = await ref.read(authServiceProvider).getProfile();
        await _saveUserInfo(user);
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      } catch (_) {
        // If profile fetch fails, still allow login
        state = state.copyWith(isLoading: false, isLoggedIn: true);
      }
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

  Future<void> getProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authServiceProvider).getProfile();
      await _saveUserInfo(user);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authServiceProvider).updateProfile(
            fullName: fullName,
            phone: phone,
            address: address,
            dateOfBirth: dateOfBirth,
            gender: gender,
            avatarPath: avatarPath,
          );
      await _saveUserInfo(user);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).resetPassword(
            token: token,
            newPassword: newPassword,
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
    state = AuthState(isLoggedIn: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _saveUserInfo(User user) async {
    await SharedPrefs.saveUserId(user.accountId);
    await SharedPrefs.saveUserName(user.username);
    await SharedPrefs.saveUserEmail(user.email);
    await SharedPrefs.saveUserFullName(user.fullName);
    await SharedPrefs.saveUserAvatar(user.avatar);
  }
}

