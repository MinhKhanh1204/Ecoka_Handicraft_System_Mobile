import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shared_prefs.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = ref.read(authProvider);
    if (authState.user == null && authState.isLoggedIn) {
      await ref.read(authProvider.notifier).getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user?.avatar == null || user!.avatar!.isEmpty
                            ? Text(
                                (SharedPrefs.getUserFullName() ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? SharedPrefs.getUserFullName() ?? 'Người dùng',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? SharedPrefs.getUserEmail() ?? SharedPrefs.getUserName() ?? '',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                      title: const Text('Chỉnh sửa hồ sơ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: AppTheme.primaryColor),
                      title: const Text('Đổi mật khẩu'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/change-password'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppTheme.primaryColor,
                      ),
                      title: const Text('Chế độ tối'),
                      trailing: Switch(
                        value: themeState.isDarkMode,
                        onChanged: (_) =>
                            ref.read(themeControllerProvider.notifier).toggleTheme(),
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                      title: const Text('Về ứng dụng'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (user != null) ...[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: Colors.grey),
                          title: const Text('Số điện thoại'),
                          subtitle: Text(user.phone!),
                        ),
                      if (user.address != null && user.address!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                          title: const Text('Địa chỉ'),
                          subtitle: Text(user.address!),
                        ),
                      if (user.dateOfBirth != null)
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                          title: const Text('Ngày sinh'),
                          subtitle: Text(
                            '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}',
                          ),
                        ),
                      if (user.gender != null && user.gender!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.wc_outlined, color: Colors.grey),
                          title: const Text('Giới tính'),
                          subtitle: Text(
                            user.gender == 'Male'
                                ? 'Nam'
                                : user.gender == 'Female'
                                    ? 'Nữ'
                                    : 'Khác',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Ecoka'),
          ],
        ),
        content: const Text('Ứng dụng mua sắm thủ công mỹ nghệ Lục Bình.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

