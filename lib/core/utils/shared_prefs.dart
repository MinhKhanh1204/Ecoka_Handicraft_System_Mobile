import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw Exception(
        'SharedPreferences chưa được khởi tạo. Gọi SharedPrefs.init() trong main()',
      );
    }
    return p;
  }

  // Token
  static Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() => prefs.getString(AppConstants.tokenKey);

  static Future<void> clearToken() async {
    await prefs.remove(AppConstants.tokenKey);
  }

  // Login Status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await prefs.setBool(AppConstants.isLoggedInKey, isLoggedIn);
  }

  static bool isLoggedIn() => prefs.getBool(AppConstants.isLoggedInKey) ?? false;

  // Theme
  static Future<void> saveThemeMode(String mode) async {
    await prefs.setString(AppConstants.themeKey, mode);
  }

  static String getThemeMode() =>
      prefs.getString(AppConstants.themeKey) ?? 'light';

  // User Info
  static Future<void> saveUserId(String userId) async {
    await prefs.setString(AppConstants.userIdKey, userId);
  }

  static String? getUserId() => prefs.getString(AppConstants.userIdKey);

  static Future<void> saveUserName(String userName) async {
    await prefs.setString(AppConstants.userNameKey, userName);
  }

  static String? getUserName() => prefs.getString(AppConstants.userNameKey);

  static Future<void> saveUserEmail(String email) async {
    await prefs.setString(AppConstants.userEmailKey, email);
  }

  static String? getUserEmail() => prefs.getString(AppConstants.userEmailKey);

  static Future<void> saveUserFullName(String fullName) async {
    await prefs.setString(AppConstants.userFullNameKey, fullName);
  }

  static String? getUserFullName() =>
      prefs.getString(AppConstants.userFullNameKey);

  static Future<void> saveUserAvatar(String? avatar) async {
    if (avatar != null) {
      await prefs.setString(AppConstants.userAvatarKey, avatar);
    } else {
      await prefs.remove(AppConstants.userAvatarKey);
    }
  }

  static String? getUserAvatar() => prefs.getString(AppConstants.userAvatarKey);

  // Cart (JSON)
  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    await prefs.setString(AppConstants.cartKey, jsonEncode(cartItems));
  }

  static List<Map<String, dynamic>> getCart() {
    final cartJson = prefs.getString(AppConstants.cartKey);
    if (cartJson == null || cartJson.isEmpty) return [];
    final decoded = jsonDecode(cartJson);
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> clearCart() async {
    await prefs.remove(AppConstants.cartKey);
  }

  // Logout - clear user data but keep theme
  static Future<void> logout() async {
    final theme = getThemeMode();
    await prefs.clear();
    await saveThemeMode(theme);
  }
}

